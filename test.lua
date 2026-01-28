local dfhack = require('dfhack')

local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/'
package.path = script_dir .. '?.lua;' .. script_dir .. '?/init.lua;' .. package.path

local Helper = require('Helper')

local petitions = df.global.world.agreements.all
print("Total petitions: " .. tostring(#petitions))
local serializedString = ""
serializedString = Helper.parseTable(petitions)
print("Serialized petitions:")
print(serializedString)
print("///////////////////////////////////////")
print("///////////////////////////////////////")
print("///////////////////////////////////////")
print("///////////////////////////////////////")
Helper.print(petitions)