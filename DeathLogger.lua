
--add the current path to the package path so we can load other local scripts
local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/?.lua'
package.path = script_dir .. ';' .. package.path

local LogHandler = require('LogHandler')
local Helper = require('Helper')
local Json = require('Json')

local DeathLogger = {}

function DeathLogger.log(unit_id)
	local unit = df.unit.find(unit_id)
	if not unit then return end

	local unit_race = dfhack.units.getRaceName(unit) or 'unknown'
	local unit_age = dfhack.units.getAge(unit) or 'unknown'
	local unit_name = dfhack.units.getVisibleName(unit) or 'unknown'
	local unit_id_str = tostring(unit_id)
	local unit_death_cause = Helper.resolveEnum("death_type", Helper.getIncidentDeathCauseByVictimId(unit_id))
    local killerId = Helper.getKillerIdbyVictimId(unit_id)
    local killer_race = dfhack.units.getRaceName(Helper.getUnitById(killerId)) or 'unknown'
	local killer = Helper.getNameOfKillerByVictimId(unit_id)
	local killedByCitizen = Helper.isUnitCitizen(killer)       
	local name = dfhack.translation.translateName(unit.name) or 'unknown'
	local msg = {
		victim_id = unit_id_str,
		victim_name = name,
		victim_race = unit_race,
		victim_age = unit_age,
		victim_death_cause = unit_death_cause,
		killer = killer,
		killed_by_citizen = tostring(killedByCitizen),
        killer_race = killer_race
	}

	
	LogHandler.write_log("UnitDeath", msg)

end

return DeathLogger
