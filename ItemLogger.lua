--add the current path to the package path so we can load other local scripts
local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/?.lua'
package.path = script_dir .. ';' .. package.path

local LogHandler = require('LogHandler')
local Helper = require('Helper')

local ItemLogger = {}




function ItemLogger.log(item_id)
	local item = df.item.find(item_id)
	if not item then return end

	local item_name = dfhack.items.getDescription(item, 0)
	local item_type = df.item_type[item:getType()]
	local mat = dfhack.matinfo.decode(item)
	local mat_name = mat and mat:toString() or 'unknown material'

	local makerId = item.maker
	local maker = Helper.getMakerName(makerId)

	local item_descr = dfhack.items.getReadableDescription(item)
	local msg = string.format(
		'[ItemCreated],id,%d,type,%s,material,%s,name,%s,desc,%s,maker,%s',
		item_id,
		item_type,
		mat_name,
		item_name,
		item_descr,
		maker
	)

	msg = filterAnnouncement(msg, {"type=REMAINS", "name=magma", "type=SEEDS"})

	LogHandler.write_log(msg)
end

return ItemLogger
