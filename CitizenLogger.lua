local dfhack = require('dfhack')

--add the current path to the package path so we can load other local scripts
local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/'
package.path = script_dir .. '?.lua;' .. script_dir .. '?/init.lua;' .. package.path
local LogHandler = require('LogHandler')
local Helper = require('Helper')
local Json = require('Json')

local citizens = {}

local lastCount = 0
local known_citizens = {}

function citizens.getCurrentCitizens()
    local current_citizens = {}
        for _, unit in ipairs(df.global.world.units.active) do
            if dfhack.units.isCitizen(unit) then
                table.insert(current_citizens, unit)
            end
        end
        return current_citizens
    end

local watcher = Helper.watch(citizens.getCurrentCitizens,
        function(unit) 
            return dfhack.translation.translateName(unit.name)
        end,
        function(oldCount, newCount)
            if oldCount ~= newCount then
                local msgJson = { type = "countchange", from = oldCount, to = newCount}
                LogHandler.write_log("Citizen", msgJson)
            end
        end,
        function(unit)
            local msgJson = { type = "newcitizen", citizen = Helper.parseUnit(unit)}
            LogHandler.write_log("Citizen", msgJson)
        end,
        function(x,z)
            return false
        end
    )


local firstCall = true
function citizens.watch()
    watcher()
    -- on the 1.1 of every year, log all citizens to a list (first month is 0 in df)
    local date = Helper.date()
    if(date.day == 1 and date.month == 0) or firstCall then
        firstCall = false
        local allCitizens = citizens.getCurrentCitizens()
        local allParsedCitizens = {}
        for _, citizen in ipairs(allCitizens) do
            table.insert(allParsedCitizens, Helper.parseUnit(citizen))
        end
        LogHandler.write_log("AllCitizens", allParsedCitizens)
    end
end


return citizens