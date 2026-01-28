local dfhack = require('dfhack')

--add the current path to the package path so we can load other local scripts
local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/'
package.path = script_dir .. '?.lua;' .. script_dir .. '?/init.lua;' .. package.path
local LogHandler = require('LogHandler')
local Helper = require('Helper')


local artifacts = df.global.world.artifacts.all

print("Total artifacts: " .. tostring(#artifacts))

local artifact = artifacts[#artifacts-1]
 --Helper.print(artifact)

local site =df.global.plotinfo.main.fortress_site
Helper.printTable(site)