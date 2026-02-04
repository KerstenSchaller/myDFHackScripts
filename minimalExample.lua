local dfhack = require('dfhack')
local eventful = require('plugins.eventful')

function appendToFile(filePath, message)
    local path = string.format("dfhack-config/%s", filePath)
    local file = io.open(path, "a")
    if file then
        file:write(message .. "\n")
        file:flush()
        file:close()
    else
        dfhack.printerr("Failed to open " .. filePath .. " for appending.")
    end
end

local function startLogging()
    local function tick()
            dfhack.timeout(500, 'ticks', tick)
            dfhack.gui.showAnnouncement("Tick", COLOR_WHITE)
    end
    tick()
end


startLogging()
