local dfhack = require('dfhack')

--add the current path to the package path so we can load other local scripts
local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/'
package.path = script_dir .. '?.lua;' .. script_dir .. '?/init.lua;' .. package.path
local LogHandler = require('LogHandler')

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

function citizens.watch()
    local newCount = 0
    current_citizens = citizens.getCurrentCitizens()
    newCount = #current_citizens
    if newCount ~= lastCount then
        LogHandler.write_log(string.format("Citizen count changed,from,%d,to,%d", lastCount, newCount))
        local known_names = {}
        for _, citizen in ipairs(known_citizens) do
            known_names[dfhack.translation.translateName(citizen.name)] = true
        end

        for _, unit in ipairs(current_citizens) do
            local name = dfhack.translation.translateName(unit.name)
            if not known_names[name] then
                LogHandler.write_log(string.format("New citizen: id,%d,name,%s,race,%s,", unit.id, name, dfhack.units.getRaceName(unit)))
            end
        end

        known_citizens = current_citizens
        lastCount = newCount
    end
    return newCount
end

return citizens