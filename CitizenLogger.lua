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
                dfhack.gui.showAnnouncement(string.format("Citizen count changed,from,%d,to,%d", oldCount, newCount), COLOR_WHITE)
                local msgJson = { type = "countchange", from = oldCount, to = newCount}
                LogHandler.write_log("Citizen", msgJson)
            end
        end,
        function(unit)
            local male = dfhack.units.isMale(unit)
            local sex = male and "male" or "female"
            local msgJson = { type = "newcitizen", id = unit.id, name = dfhack.translation.translateName(unit.name), race = dfhack.units.getRaceName(unit), age = dfhack.units.getAge(unit), sex = sex}
            LogHandler.write_log("Citizen", msgJson)
        end,
        function(x,z)
            return false
        end
    )

function citizens.watch()
    watcher()
end


return citizens