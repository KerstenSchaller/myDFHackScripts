--AnnouncementWatcher
local AnnouncementWatcher = {}

local dfhack = require('dfhack')

--add the current path to the package path so we can load other local scripts
local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/?.lua'
package.path = script_dir .. ';' .. package.path

local last_announcement_msg = ""
local LogHandler = require('LogHandler')
local Json = require('Json')

local modId = "DF_CHRONICHLE"

function AnnouncementWatcher.filterAnnouncement(announcement, exclude_keywords)
    --filter for certain keywords to exclude
    for _, keyword in ipairs(exclude_keywords) do
        if string.find(announcement.text, keyword) then
            return ""
        end
    end
    return announcement
end


function AnnouncementWatcher.parseAnnouncements(announcement)
    -- Here you can add more complex parsing logic if needed
    -- For now, we just log the announcement directly
    announcement = AnnouncementWatcher.filterAnnouncement(announcement,{ "has been completed", modId, "ignore" })
    
    if announcement ~= "" then
        LogHandler.write_log("Announcement",announcement)
    end
    
end


AnnouncementWatcher.lastLoggedId = -1

function AnnouncementWatcher.watch()
    local reports = df.global.world.status.reports
    if AnnouncementWatcher.lastLoggedId == -1 then
        if #reports > 0 then
            AnnouncementWatcher.lastLoggedId = reports[#reports-1].id
        end
        return
    end

    if #reports == 0 then 
        return 
    end

    -- Find the index of the last logged announcement
    local start_idx = 1
    for i = #reports-1, 1, -1 do
        if reports[i].id == AnnouncementWatcher.lastLoggedId then
            start_idx = i + 1
            break
        end
    end

    if start_idx > #reports then
        return -- nothing new
    end

    -- Log all new announcements from start_idx to #reports
    for i = start_idx, #reports-1 do
        local msg = reports[i]
        last_announcement_msg = msg
        AnnouncementWatcher.lastLoggedId = msg.id
        local msgJson = {
            type = msg.type,
            text = msg.text,
            id = msg.id,
            continuation = msg.flags.continuation,
            unconscious = msg.flags.unconscious,
            announcement = msg.flags.announcement,
            pos1 = {
                zoom_type = msg.zoom_type,
                x = msg.pos.x,
                y = msg.pos.y,
                z = msg.pos.z,
            },
            pos2 = {
                zoom_type = msg.zoom_type2,
                x = msg.pos2.x,
                y = msg.pos2.y,
                z = msg.pos2.z,
            },
            year = msg.year,
            time = msg.time,
            activity_id = msg.activity_id,
            activity_event_id = msg.activity_event_id,
            speaker_id = msg.speaker_id,
        }
        LogHandler.write_log("Announcement", msgJson)
    end
    if #reports >= start_idx then
        return reports[#reports-1].text
    end
end

return AnnouncementWatcher