local dfhack = require('dfhack')

--add the current path to the package path so we can load other local scripts
local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/?.lua'
package.path = script_dir .. ';' .. package.path

local Helper = require('Helper')
local LogHandler = require('LogHandler')




local petitions = df.global.world.agreements.all

local PetitionLogger = {}

local watcher = Helper.watch(
        function()
            return df.global.world.agreements.all
        end,
        function(petition)
            local serializedString = ""
            return Helper.parseTable(petition, serializedString)
        end,
        function(oldCount, newCount)
            if oldCount ~= newCount then
                dfhack.gui.showAnnouncement(string.format("Petition count changed, from %d to %d\n", oldCount, newCount))
            end
        end,
        function(petition)
            local serializedString = Helper.parseTable(petition)
            LogHandler.write_log("[PetitionChange],"..serializedString)
        end,
        function(lastValue, petition2)
            local serializedString2 = Helper.parseTable(petition2)
            local value2 = Helper.getValueFromSerializedString(serializedString2, "petition_not_accepted")
            local cond = (lastValue ~= value2)
            if cond then dfhack.gui.showAnnouncement("Petition change detected") end

            return cond,lastValue,value2
        end
    )

function PetitionLogger.watch()
    watcher()
end







function PetitionLogger.findEntityById(id)
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

return PetitionLogger