
--add the current path to the package path so we can load other local scripts
local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/?.lua'
package.path = script_dir .. ';' .. package.path

local LogHandler = require('LogHandler')
local Helper = require('Helper')

local DeathLogger = {}


function DeathLogger.log(unit_id)
	local unit = df.unit.find(unit_id)
	if not unit then return end

	local unit_race = dfhack.units.getRaceName(unit) or 'unknown'
	local unit_name = dfhack.units.getVisibleName(unit) or 'unknown'
	local unit_id_str = tostring(unit_id)

	local name = dfhack.units.getReadableName(unit) or 'unknown'
	local msg = string.format(
		'[UnitDeath],id,%s,name,"%s",race,"%s"', 
		unit_id_str,
		name,
		unit_race
	)

	LogHandler.write_log(msg)
end

return DeathLogger
