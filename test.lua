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

Helper.printTable(pet)
local parsedPetition = Helper.parseTable(petitions[#petitions - 1])
local details = pet.details[0]
local type = details.type
print("type:", df.agreement_details_type[type])
print("     ")

function findEntityById(id)
    if #df.global.world.entities.all == 0 then
        return nil
    end
    for _, entity in pairs(df.global.world.entities.all) do
        if entity.id == id then
            return entity
        end
    end
    return nil
end


function log(unit_id)
	local unit = df.unit.find(unit_id)
	if not unit then return end

	local unit_race = dfhack.units.getRaceName(unit) or 'unknown'
	local unit_name = dfhack.units.getVisibleName(unit) or 'unknown'
	local unit_id_str = tostring(unit_id)
	local unit_death_cause = Helper.resolveEnum("death_type", Helper.getIncidentDeathCauseByVictimId(unit_id))
    local killerId = Helper.getKillerIdbyVictimId(unit_id)
    local killer_race = dfhack.units.getRaceName(Helper.getUnitById(killerId)) or 'unknown'
	local killer = Helper.getNameOfKillerByVictimId(unit_id)
	local killedByCitizen = Helper.isUnitCitizen(killer)       
	local name = dfhack.units.getReadableName(unit) or 'unknown'
	local msg = string.format(
		'[UnitDeath],id,%s,name,%s,race,%s,death_cause,%s,killer,%s,killed_by_citizen,%s,killer_race,%s',
		unit_id_str,
		name,
		unit_race,
		unit_death_cause,
		killer,
		tostring(killedByCitizen),
        killer_race
		
	)
	
	print(msg)

end

log(12318)

function printUnitName(unit)
    local name = dfhack.translation.translateName(unit.name)
    if name == "" then
        name = dfhack.units.getReadableName(unit)
    end
    print("Unit Name:", name)
end

