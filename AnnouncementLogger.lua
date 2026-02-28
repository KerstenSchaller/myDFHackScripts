--AnnouncementWatcher
local AnnouncementWatcher = {}

--add the current path to the package path so we can load other local scripts
local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/?.lua'
package.path = script_dir .. ';' .. package.path

local last_announcement_msg = ""
local LogHandler = require('LogHandler')
local Json = require('Json')


function parseAnnouncements(announcement)
    -- Here you can add more complex parsing logic if needed
    -- For now, we just log the announcement directly
    announcement = filterAnnouncement(announcement,{ "has been completed", modId, "ignore" })
    
    if announcement ~= "" then
        LogHandler.write_log("Announcement",announcement)
    end
    
end

function filterAnnouncement(announcement, exclude_keywords)
    --filter for certain keywords to exclude
    for _, keyword in ipairs(exclude_keywords) do
        if string.find(announcement.text, keyword) then
            return ""
        end
    end
    return announcement
end

AnnouncementWatcher.lastLoggedId = -1

function AnnouncementWatcher.watch()
    local reports = df.global.world.status.reports

    if #reports == 0 then 
        return 
    end
    if last_announcement_msg == reports[#reports - 1].text or AnnouncementWatcher.lastLoggedId == reports[#reports - 1].id then
        --dfhack.gui.showAnnouncement("Duplicate announcement skipped."..last_announcement_msg..reports[#reports - 1].id, COLOR_WHITE)
        return -- already logged
    end

    if #reports < 2 then
        return
    end

    AnnouncementWatcher.lastLoggedId = reports[#reports - 1].id
    last_announcement_msg = reports[#reports - 1]




        local msgJson = {
        type = last_announcement_msg.type,
        text = last_announcement_msg.text,
        id = last_announcement_msg.id,
        continuation = last_announcement_msg.flags.continuation,
        unconscious = last_announcement_msg.flags.unconscious,
        announcement = last_announcement_msg.flags.announcement,
        pos1 = {
            zoom_type = last_announcement_msg.zoom_type,
            x = last_announcement_msg.pos.x,
            y = last_announcement_msg.pos.y,
            z = last_announcement_msg.pos.z,
        },
        pos2 = {
            zoom_type = last_announcement_msg.zoom_type2,
            x = last_announcement_msg.pos2.x,
            y = last_announcement_msg.pos2.y,
            z = last_announcement_msg.pos2.z,
        },
        year = last_announcement_msg.year,
        time = last_announcement_msg.time,
        activity_id = last_announcement_msg.activity_id,
        activity_event_id = last_announcement_msg.activity_event_id,
        speaker_id = last_announcement_msg.speaker_id,

        }



    LogHandler.write_log("Announcement",msgJson)
end

return AnnouncementWatcher