local dfhack = require('dfhack')

--add the current path to the package path so we can load other local scripts
local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/'
package.path = script_dir .. '?.lua;' .. script_dir .. '?/init.lua;' .. package.path
local LogHandler = require('LogHandler')
local Helper = require('Helper')

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
                LogHandler.write_log(string.format("Citizen count changed,from,%d,to,%d", oldCount, newCount))
            end
        end,
        function(unit)
            LogHandler.write_log(string.format("New citizen: id,%d,name,%s,race,%s,", unit.id,
                dfhack.translation.translateName(unit.name), dfhack.units.getRaceName(unit)))
        end,
        function(x,z)
            return false
        end
    )

function citizens.watch()
    watcher()
end


return citizens