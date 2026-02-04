local dfhack = require('dfhack')
local eventful = require('plugins.eventful')

local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/'
package.path = script_dir .. '?.lua;' .. script_dir .. '?/init.lua;' .. package.path

local Helper = require('Helper')

local allUnits = df.global.world.units.all
local animals = {}
local merchants = {}
local guests = {}
local ghosts = {}

for _, unit in ipairs(allUnits) do
    if unit.flags3.ghostly then
        print("Ghostly unit found: ID "..unit.id.." Name: "..dfhack.translation.translateName(unit.name))
    end

    if dfhack.units.isVisible(unit) then
        local race = dfhack.units.getRaceReadableName(unit)
            if unit.flags4.counts_as_animal then
                --print("Animal unit found: ID "..unit.id.." race: "..race)
            end

            local isGhost = unit.ghost_info ~= nil or unit.flags3.ghostly
            local isBuried = unit.ghost_info ~= nil and unit.ghost_info.flags.was_at_rest or false
            local isCitizen = dfhack.units.isCitizen(unit)
            local isResident = unit.flags2.resident
            local isGroup = dfhack.units.isOwnGroup(unit)
            local isAnimal = unit.flags4.counts_as_animal
            local isFortControlled = dfhack.units.isFortControlled(unit)
            local isHidden = dfhack.units.isHidden(unit)
            local isGuest = unit.flags3.guest
            local isMerchant = unit.flags1.merchant
            local isAnimal = unit.flags4.counts_as_animal
            local isTame = unit.flags1.tame
            local inActive = unit.flags1.inactive or unit.flags2.killed 
            



            if not isCitizen and not isResident and not isAnimal and not isGhost and not isBuried then
                --print("Non Citizen unit found: ID "..unit.id.." race: "..race.." Name: "..dfhack.translation.translateName(unit.name))

            end
            if isAnimal and not isTame and not inActive and not isMerchant then
                animals[#animals+1] = unit
            end
            if isMerchant then
                merchants[#merchants+1] = unit
            end
            if isGuest then
                guests[#guests+1] = unit
            end
            if isGhost then
                ghosts[#ghosts+1] = unit   
            end
        end
    end
    print("-----Animals-------")
    for _, unit in ipairs(animals) do
        local name = dfhack.translation.translateName(unit.name)
        local strName = ""
        if name == "" then
            strName = " Name:" .. dfhack.units.getReadableName(unit)
        end
        
        print("ID:", unit.id, " Race:", dfhack.units.getRaceReadableName(unit), strName )
    end
    print("-----Merchants-------")
    for _, unit in ipairs(merchants) do
        local strName = " Name:" .. dfhack.translation.translateName(unit.name)
        print("ID:", unit.id, " Race:", dfhack.units.getRaceReadableName(unit), strName )
    end
    print("-----Guests-------")
    for _, unit in ipairs(guests) do
        print("ID:", unit.id, " Race:", dfhack.units.getRaceReadableName(unit), " Name:", dfhack.translation.translateName(unit.name) )
    end
    print("-----Ghosts-------")
    for _, unit in ipairs(ghosts) do
        print("ID:", unit.id, " Race:", dfhack.units.getRaceReadableName(unit), " Name:", dfhack.translation.translateName(unit.name) )
    end