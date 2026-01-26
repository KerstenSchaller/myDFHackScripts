local dfhack = require('dfhack')

local lastCount = 0

local citizens = {}

function watchNumberOfCitizens()
    local newCount = 0
    citizens = {}
    for _, unit in ipairs(df.global.world.units.active) do
        if dfhack.units.isCitizen(unit) then
            table.insert(citizens, unit)
            newCount = newCount + 1
        end
    end
    if newCount ~= lastCount then
        dfhack.gui.showAnnouncement('Number of citizens s from ' .. tostring(lastCount) .. ' to ' .. tostring(newCount))
        -- Log names of new citizens, exlude the ones we already knew about
        -- Find new citizens not present in previous list
        local prev_ids = {}
        for _, unit in ipairs(citizens) do
            prev_ids[unit.id] = true
        end
        -- Compare with previous citizens
        for _, unit in ipairs(citizens) do
            if not prev_ids[unit.id] then
                dfhack.gui.showAnnouncement('New citizen: ' .. (dfhack.units.getReadableName(unit) or tostring(unit.id)))
            end
        end
        lastCount = newCount
    end
    return newCount
end

local function timer_callback()
    watchNumberOfCitizens()
    dfhack.timeout(500, 'frames', timer_callback)
end

-- Start the timer
dfhack.timeout(500, 'frames', timer_callback)