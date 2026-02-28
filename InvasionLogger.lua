local dfhack = require('dfhack')

--add the current path to the package path so we can load other local scripts
local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/?.lua'
package.path = script_dir .. ';' .. package.path
local LogHandler = require('LogHandler')
local Helper = require('Helper')

local InvasionLogger = {}


    function InvasionLogger.findControllerById(id)
        local armyControllers = df.global.world.army_controllers.all
        for i = 0, #armyControllers - 1 do
            local controller = armyControllers[i]
            if controller.id == id then
                return controller
            end
        end
        return nil
    end

function InvasionLogger.parseHistFigById(id)
        local master_histfig = Helper.getHistoricalFigureByid(id)
        if master_histfig then
            return {
                id = master_histfig.id,
                sex = master_histfig.sex == 1 and "male" or "female",
                name = dfhack.translation.translateName(master_histfig.name),
                name_english = dfhack.translation.translateName(master_histfig.name, true),
                race = dfhack.units.getRaceReadableNameById(master_histfig.race),
                
            }
        else
            return nil
        end
    end

    function InvasionLogger.parseArmyControllerById(id)
        local controller = InvasionLogger.findControllerById(id)
        local commanderMasterId = controller.commander_hf
        if commanderMasterId == -1 then
            commanderMasterId = controller.master_hf
        end
        if controller then
            return {
                id = controller.id,
                commander_hist = InvasionLogger.parseHistFigById(commanderMasterId),
            }
        else
            return nil
        end
    end
    
    function InvasionLogger.logInvasion(invasion)
        dfhack.gui.showAnnouncement("Starting Logging Invasion", COLOR_RED)
        local invasionData = {
            year = invasion.created_year,
            duration = invasion.duration_counter,
            civ_id = invasion.civ_id,
            size = invasion.size,
            flags = {
                active = invasion.flags.active,
                siege = invasion.flags.siege,
                wants_parley = invasion.flags.want_parley,
                undead = invasion.flags.undead_source,
                parley = invasion.flags.parley,
                planless = invasion.flags.planless,
                handed_over_artifact = invasion.flags.handed_over_artifact
            },
            army_controller = InvasionLogger.parseArmyControllerById(invasion.origin_master_army_controller_id),
            mission = df.mission_type[invasion.mission],



        }
        LogHandler.write_log("Invasion", invasionData)
        dfhack.gui.showAnnouncement("Logging Invasion", COLOR_RED)
    end

    local InvasionActive = false
    local currentInvasion = nil
    function InvasionLogger.setInvasionActive(active, invasion)
        InvasionActive = active
        currentInvasion = invasion
    end

    function InvasionLogger.setInvasionInactive()
        InvasionActive = false
        currentInvasion = nil
    end

    function InvasionLogger.watch()
        if InvasionActive then
            if currentInvasion.active_size1 == 0 then
                InvasionLogger.logInvasion(currentInvasion)
                InvasionLogger.setInvasionInactive()
            end
        end
    end



return InvasionLogger