local dfhack = require('dfhack')

local lastCount = 0

local citizens = {}
local known_citizens = {}

function getCurrentCitizens()
    local current_citizens = {}
    for _, unit in ipairs(df.global.world.units.active) do
        if dfhack.units.isCitizen(unit) then
            table.insert(current_citizens, unit)
        end
    end
    return current_citizens
end

function citizens.watchNumberOfCitizens()
    local newCount = 0
    local current_citizens = getCurrentCitizens()
    newCount = #current_citizens

    print("Current number of citizens: " .. tostring(newCount))

    local known_names = {}
    for _, citizen in ipairs(known_citizens) do
        known_names[dfhack.translation.translateName(citizen.name)] = true
    end

    for _, unit in ipairs(current_citizens) do
        local name = dfhack.translation.translateName(unit.name)
            print('New citizen: ' .. name .." ".. dfhack.units.getRaceName(unit))
    end

    known_citizens = current_citizens


end

citizens.watchNumberOfCitizens()