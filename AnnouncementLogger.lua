--AnnouncementWatcher
local AnnouncementWatcher = {}

--add the current path to the package path so we can load other local scripts
local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/?.lua'
package.path = script_dir .. ';' .. package.path

local last_announcement_msg = ""
local LogHandler = require('LogHandler')


function parseAnnouncements(announcement)
    -- Here you can add more complex parsing logic if needed
    -- For now, we just log the announcement directly
    announcement = filterAnnouncement(announcement,{ "has been completed", modId, "ignore" })

    if announcement ~= "" then
        LogHandler.write_log(announcement)
    end
    
end

function filterAnnouncement(announcement, exclude_keywords)
    --filter for certain keywords to exclude
    for _, keyword in ipairs(exclude_keywords) do
        if string.find(announcement, keyword) then
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
    AnnouncementWatcher.lastLoggedId = reports[#reports - 1].id
    last_announcement_msg = reports[#reports - 1].text

    -- check if announcement contains [Announcement] and skip if  yes
    if string.find(reports[#reports - 1].text, "Announcement")  then
        return
    end
    local msg = string.format("[Announcement],id,%d,text,%s,repeat_count,%d",reports[#reports - 1].id, reports[#reports - 1].text, reports[#reports - 1].repeat_count)
    parseAnnouncements(msg)
end

return AnnouncementWatcher