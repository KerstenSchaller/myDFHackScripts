--add the current path to the package path so we can load other local scripts
local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/?.lua'
package.path = script_dir .. ';' .. package.path

local LogHandler = require('LogHandler')
local Helper = require('Helper')
local Json = require('Json')
local MaterialHelper = require('MaterialHelper')

local ItemLogger = {}




function ItemLogger.log(item_id)
	local item = df.item.find(item_id)
	if not item then return end

	local item_name = dfhack.items.getDescription(item, 0)
	local item_type = df.item_type[item:getType()]
	local mat = dfhack.matinfo.decode(item)
	local mat_name = mat and mat:toString() or 'unknown material'

	local makerId = item.maker
	local quality = item:getQuality()
	local value = dfhack.items.getValue(item)
	local isArtifact = item.flags.artifact


	local item_descr = dfhack.items.getReadableDescription(item)
	local msg = {
		item_id = item_id,
		item_type = item_type,
		material = mat_name,
		item_name = item_name,
		item_descr = item_descr,
		maker = Helper.parseUnit(Helper.getUnitByHistFigureId(makerId)),
		quality = quality,
		value = value,
		is_artifact = isArtifact,
		mat_index = item.mat_index,
		mat_type = item.mat_type,
		material_category = MaterialHelper.typeInfoByItemId(item)
	}


	if msg.name == "magma" or msg.type == "REMAINS" or msg.type == "SEEDS" then
		return
	end

	LogHandler.write_log("ItemCreated", msg)
end

return ItemLogger
