--LogHandler

local LogHandler = {}

local dfhack = require('dfhack')

--add the current path to the package path so we can load other local scripts
local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/?.lua'
package.path = script_dir .. ';' .. package.path

package.loaded["Helper"] = nil
local Helper = require('Helper')
local Json = require('Json')


local fortressName = dfhack.df2console(dfhack.translation.translateName(df.global.plotinfo.main.fortress_site.name, true))
local worldName = dfhack.df2console(dfhack.translation.translateName(df.global.world.world_data.name, true))
local CHRONICLE_LOG_PATH = string.format("DF_Chronicle_%s_%s_.log", worldName, fortressName)
print("Logpath: "..CHRONICLE_LOG_PATH)
if not dfhack.filesystem.exists("dfhack-config/df_chronicle") then
    dfhack.filesystem.mkdir("dfhack-config/df_chronicle")
end
      LOG_PATH = string.format("dfhack-config/df_chronicle/%s", CHRONICLE_LOG_PATH)


function LogHandler.appendToFile( message)
    local file = io.open(LOG_PATH, "a")
    if file then
        file:write(message .. "\n")
        file:flush()
        file:close()
    else
        dfhack.printerr("Failed to open " .. LOG_PATH .. " for appending.")
    end
end

function LogHandler.write_log(messageType,message,filename)
    if filename then
        LOG_PATH = string.format("dfhack-config/df_chronicle/%s", filename)
    else
        LOG_PATH = string.format("dfhack-config/df_chronicle/%s", CHRONICLE_LOG_PATH)
    end
    if message == "" then
        return
    end
    if last_logged_message == message then
        return -- Don't log duplicate message
    end
    local date = Helper.date()
    local msg = {date = date, type = messageType, data = message}
    local logEntry = Json.table_to_json(msg)
    
    last_logged_message = message
    LogHandler.appendToFile( dfhack.df2utf(logEntry)) 

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

function LogHandler.readAllLogLines()
    local lines = {}
    local file = io.open(LOG_PATH, "r")
    if not file then
        dfhack.printerr("Failed to open " .. LOG_PATH .. " for reading.")
        return ""
    end
    local cnt = 0
    for line in file:lines() do
        lines[cnt] = line
        cnt = cnt + 1
    end
    file:close()
    return lines
end    

function LogHandler.compareDate(date1, date2)
    -- returns 0 if equa, 1 if first is newer, 2 if second is newer
    print(string.format("Comparing dates: %d.%d vs %d.%d", date1.year, date1.ticks, date2.year, date2.ticks))
    if date1.year < date2.year then
        return 2
    elseif date1.year > date2.year then
        return 1
    elseif date1.year == date2.year and date1.ticks < date2.ticks then
        return 2
    elseif date1.year == date2.year and date1.ticks > date2.ticks then
        return 1
    end
    return 0
end

function LogHandler.clearNewerEntriesInLog()
    --local date = Helper.date()
    local date = Helper.date()
    date.year = 110
    date.ticks = 15599

    local lines = LogHandler.readAllLogLines()
    --gather lines older than the current date and rewrite the log with only those lines to clear newer entries
    local newLogContent = {}
    for _, line in pairs(lines) do
        if lintee == ""  or line == nil then
            print("Empty line in log, skipping.")
            goto continue
        end
        local logEntry = Json.json_to_table(line)
        if logEntry and logEntry.date and LogHandler.compareDate(logEntry.date, date) == 2 then
            table.insert(newLogContent, line)
        end
        ::continue::
    end
    local file = io.open(LOG_PATH, "w")
    if file then
        for _, line in pairs(newLogContent) do
            file:write(line .. "\n")
        end
        file:flush()
        file:close()
    else
        dfhack.printerr("Failed to open " .. LOG_PATH .. " for writing.")
    end
end

return LogHandler