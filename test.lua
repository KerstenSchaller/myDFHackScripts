local dfhack = require('dfhack')
local eventful = require('plugins.eventful')

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





local petitions = df.global.world.agreements.all
print("number of petitions:", #petitions)

local pet = petitions[#petitions-1]




function log(item_id)
    
    for i, item in ipairs(df.global.world.items.all) do
        if item.id == 2774 then
            print("Found item with ID 2774 "..i)
            local item_quality = item:getQuality()
            print("quality:", item_quality)
            local item_value = dfhack.items.getValue(item)
            print("value:", item_value)
        end
    end

    local item = df.global.world.items.all[item_id]
    print("quality:", item:getQuality())
    print("type:", df.item_type[item:getType()])
    print("subtype:", df.item_subtype[item:getSubtype()])  
end


log(2774)

function printUnitName(unit)
    local name = dfhack.translation.translateName(unit.name)
    if name == "" then
        name = dfhack.units.getReadableName(unit)
    end
    print("Unit Name:", name)
end




Helper.printTable(pet)
local parsedPetition = Helper.parseTable(petitions[#petitions - 1])
local details = pet.details[0]
local type = details.type
print("type:", df.agreement_details_type[type])
print("     ")
