local dfhack = require('dfhack')

local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/'
package.path = script_dir .. '?.lua;' .. script_dir .. '?/init.lua;' .. package.path

local Helper = require('Helper')


--local cond = (Helper.parseTable(petition1) ~= Helper.parseTable(petition2))
--if cond then dfhack.gui.showAnnouncement("Petition change detected") end
--return cond


local petitions = df.global.world.agreements.all
print("Total petitions: " .. tostring(#petitions))
local serializedString = ""
serializedString = Helper.parseTable(petitions[#petitions-1])
print("Serialized petitions:")
print(serializedString)


print("--------------------------------------------------")
local value = Helper.getValueFromSerializedString(serializedString, "petition_not_accepted")
print("Value for key 'petition_not_accepted': " .. tostring(value))
print(petitions[#petitions-1])
--Helper.print(petitions)