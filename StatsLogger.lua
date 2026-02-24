local dfhack = require('dfhack')
local eventful = require('plugins.eventful')

local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/'
package.path = script_dir .. '?.lua;' .. script_dir .. '?/init.lua;' .. package.path

local Helper = require('Helper')
local LogHandler = require('LogHandler')


local StatisticsLogger = {}


local lastLoggedMonth = -1

function StatisticsLogger.logVisitorsAndOthers()
    
    local date = Helper.date()
    -- Check if the month has changed since the last log
    if date.month == lastLoggedMonth then 
        return
    end
    lastLoggedMonth = date.month

    local allUnits = df.global.world.units.all
    local lifestock = {}
    local merchants = {}
    local guests = {}
    local ghosts = {}
    local pets = {}



    for _, unit in ipairs(allUnits) do
        if unit.flags3.ghostly then
            print("Ghostly unit found: ID "..unit.id.." Name: "..dfhack.translation.translateName(unit.name))
        end

        if dfhack.units.isVisible(unit) then
                local race = dfhack.units.getRaceReadableName(unit)


                local isBuried = unit.ghost_info ~= nil and unit.ghost_info.flags.was_at_rest or false
                local isCitizen = dfhack.units.isCitizen(unit)
                local isResident = unit.flags2.resident
                local isGroup = dfhack.units.isOwnGroup(unit)
                local isGhost = unit.ghost_info ~= nil or unit.flags3.ghostly
                local isAnimal = unit.flags4.counts_as_animal
                local isMerchant = unit.flags1.merchant
                local isTame = unit.flags1.tame
                local isGuest = unit.flags3.guest
                local isFortControlled = dfhack.units.isFortControlled(unit)
                local isHidden = dfhack.units.isHidden(unit)
                local inActive = unit.flags1.inactive or unit.flags2.killed 
                local isPet = dfhack.units.isPet(unit)
                
                if not isCitizen and not isResident and not isAnimal and not isGhost and not isBuried then
                    --print("Non Citizen unit found: ID "..unit.id.." race: "..race.." Name: "..dfhack.translation.translateName(unit.name))

                end
                if isAnimal and isTame and not inActive and not isMerchant  and not isPet then
                    table.insert(lifestock, Helper.parseUnit(unit))
                    goto continue
                end
                if isMerchant then
                    table.insert(merchants, Helper.parseUnit(unit))
                    goto continue
                end
                if isGuest then
                    table.insert(guests, Helper.parseUnit(unit))
                    goto continue
                end
                if isGhost then
                    table.insert(ghosts, Helper.parseUnit(unit))   
                    goto continue
                end
                if isPet then
                    table.insert(pets, Helper.parseUnit(unit))
                    goto continue
                end

                ::continue::
            end
        end

        local msg = {
            lifestock = lifestock,
            merchants = merchants,
            guests = guests,
            ghosts = ghosts,
            pets = pets
        }

        LogHandler.write_log("VisitorsAndOthers", msg)

end

function StatisticsLogger.logAll()
    StatisticsLogger.logVisitorsAndOthers()
end

return StatisticsLogger