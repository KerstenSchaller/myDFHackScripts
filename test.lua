local dfhack = require('dfhack')

local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/'
package.path = script_dir .. '?.lua;' .. script_dir .. '?/init.lua;' .. package.path

local Helper = require('Helper')


--local cond = (Helper.parseTable(petition1) ~= Helper.parseTable(petition2))
--if cond then dfhack.gui.showAnnouncement("Petition change detected") end
--return cond

function getDeathCauses(id)
    local deathCauses = {}
    return ""
end


goto next

print("number of incidents:", #df.global.world.incidents.all)

for _, incident in ipairs(df.global.world.incidents.all) do
    if incident.type == df.incident_type.Death then
        local death_incident = incident --:df.incident_deathst
        Helper.printTable(death_incident)
        return
    end
end

::next::

local artifacts = df.global.world.artifacts.all
print("number of items:", #artifacts)
print("Artifacts:")

for _, artifact in ipairs(artifacts) do
    --if item.flags.artifact == false then
        local pos = artifact.item.pos
        if pos.x ~= -30000 and dfhack.items.getBookTitle(artifact.item) ~= "" then
            print("x "..pos.x.." y "..pos.y.." z "..pos.z)
        end
        
        --Helper.printTable(artifact)
    --end
end

function getHistFigName(histFigId)
    print("active units n:"..#df.global.world.units.active)
    for _, unit in ipairs(df.global.world.units.active) do
        print("unit id "..unit.id)
        if histFigId == unit.id then
            return dfhack.units.getReadableName(unit)
        end
    end
end

function printDeathIncidentByVictimId(victimId)
    local incidents = df.global.world.incidents.all
    for _, incident in ipairs(incidents) do
        if incident.type == df.incident_type.Death and incident.victim == victimId then
            local death_incident = incident --:df.incident_deathst
            Helper.printTable(death_incident)
        end
    end
    return nil
end



local petitions = df.global.world.agreements.all
print("number of petitions:", #petitions)

--Helper.printTable(petitions[#petitions - 1])
local parsedPetition = Helper.parseTable(petitions[#petitions - 1])
local type = Helper.getValueFromSerializedString(parsedPetition, "type")
print("type:", type)
print("     ")

            function getUnitById(id)
                for _, unit in ipairs(df.global.world.units.active) do
                    if unit.id == id then
                        return unit
                    end
                end
                return nil
            end

            function getUnitNameById(id)
                local unit = getUnitById(id)
                if unit then
                    local unitname = dfhack.translation.translateName(unit.name) 
                    if unitname == "" then
                        unitname = dfhack.units.getReadableName(unit)
                    end
                    return unitname
                else
                    return "unknown_unit"
                end
            end

function getNameOfKillerByVictimId(victimId)
    local incidents = df.global.world.incidents.all
    for _, incident in ipairs(incidents) do
        if incident.type == df.incident_type.Death and incident.victim == victimId then
            local death_incident = incident --:df.incident_deathst
            local killerId = death_incident.criminal
            return getUnitNameById(killerId)
        end
    end
    return "unknown_killer"
end

function isUnitCitizen(unitId)
    for _, unit in ipairs(df.global.world.units.active) do
        if unit.id == unitId then
            print("found unit id "..unitId)
            if dfhack.units.isCitizen(unit) then
                return true
            end
        end
    end
    return false
end

print("Victim")
print(Helper.getUnitNameById(13097))
print("    ")
print("Killer")
print(Helper.getNameOfKillerByVictimId(13097))

print(Helper.isUnitCitizen(13056))
print("    ")

printDeathIncidentByVictimId(13097)


print(Helper.getUnitNameById(13056))

local killedByCitizenStr =  true and "true1" or "false2"
print("killedByCitizenStr:", killedByCitizenStr)

print("active units n:"..#df.global.world.units.active)
    for _, unit in ipairs(df.global.world.units.active) do
        if dfhack.units.isCitizen(unit) then
            print("citizen:"..dfhack.units.getReadableName(unit).."unitId"..unit.id)
        end
    end

