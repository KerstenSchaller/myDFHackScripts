--LogHandler

local LogHandler = {}

local dfhack = require('dfhack')

--add the current path to the package path so we can load other local scripts
local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/?.lua'
package.path = script_dir .. ';' .. package.path

package.loaded["Helper"] = nil
local Helper = require('Helper')


local fortressName = dfhack.translation.translateName(df.global.plotinfo.main.fortress_site.name)
local worldName = dfhack.translation.translateName(df.global.world.world_data.name)
local LOG_PATH = string.format("DFStats_%s_%s_.log", worldName, fortressName)

function LogHandler.appendToFile(filePath, message)
    local path = string.format("dfhack-config/%s", filePath)
    local file = io.open(path, "a")
    if file then
        file:write(message .. "\n")
        file:close()
    else
        dfhack.printerr("Failed to open " .. filePath .. " for appending.")
    end
end

function LogHandler.write_log(message)
    if message == "" then
        return
    end
    if last_logged_message == message then
        return -- Don't log duplicate message
    end
    last_logged_message = message
    local datestr = Helper.date()
    message = string.format('%s,%s' ,datestr, message)
    message = dfhack.df2utf(message)
    LogHandler.appendToFile(LOG_PATH, message)

end

-- Function to read the last line from the log file
function LogHandler.read_last_log_line()
    local file = io.open(LOG_PATH, "r")
    if not file then
        dfhack.printerr("Failed to open " .. LOG_PATH .. " for reading.")
        return ""
    end
    local last_line = nil
    for line in file:lines() do
        last_line = line
    end
    file:close()
    return last_line
end

return LogHandler