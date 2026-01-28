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

