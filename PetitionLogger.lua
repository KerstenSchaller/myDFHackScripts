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
             Helper.parseTable(petition, serializedString)
            return serializedString
        end,
        function(oldCount, newCount)
            if oldCount ~= newCount then
                dfhack.gui.showAnnouncement(string.format("Petition count changed, from %d to %d\n", oldCount, newCount))
            end
        end,
        function(petition)
            local serializedString = Helper.parseTable(petition)
            LogHandler.write_log(serializedString)
            print(serializedString)
        end
    )

function PetitionLogger.watch()
    watcher()
end





if true then
    for id, petition in pairs(petitions) do
        if petition.flags.petition_not_accepted  then
            print("------------------------------------------------------")
            print("------------------------------------------------------")
            print("------------------------------------------------------")
            print(string.format("Petition %d not accepted. Full details:", id))
            printPetitionDetails(petition)
            print("--- End of petition " .. id .. " ---")
        end
    end

end

function PetitionLogger.findEntityById(id)
    for _, entity in pairs(df.global.world.entities.all) do
        if entity.id == id then
            return entity
        end
    end
    return nil
end

return PetitionLogger