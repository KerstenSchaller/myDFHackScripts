local dfhack = require('dfhack')

--add the current path to the package path so we can load other local scripts
local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/?.lua'
package.path = script_dir .. ';' .. package.path

local Helper = require('Helper')
local LogHandler = require('LogHandler')




local petitions = df.global.world.agreements.all

local PetitionLogger = {}

    local function getDataTypeName(_data)
        for k, v in pairs(_data) do
            return tostring(k)
        end
    end


    local names = {}

    function get_petition_age(agr)
    local agr_year_tick = agr.details[0].year_tick
    local agr_year = agr.details[0].year
    local cur_year_tick = df.global.cur_year_tick
    local cur_year = df.global.cur_year
    local del_year = cur_year - agr_year
    local del_year_tick = cur_year_tick - agr_year_tick
    if del_year_tick < 0 then
        del_year = del_year - 1
        del_year_tick = del_year_tick + 403200
    end
    -- Round up to the nearest day, since we don't do fractions
    local julian_day = math.ceil(del_year_tick / 1200)
    local del_month = math.floor(julian_day / 28)
    local del_day = julian_day % 28
    return {del_year,del_month,del_day}
    end


    function Helper.logResidencyPetition(petition,newstring)
        local histFigId = petition.parties[0].histfig_ids[0]
        local unit_id = df.global.world.history.figures[histFigId].unit_id

        local unit = df.unit.find(unit_id)
        if not unit then
            return
        end
        local reason = df.history_event_reason[petition.details[0].data.Residency.reason]
        local msg = {
            id = petition.id,
            PetitionType = "Residency",
            unit = Helper.parseUnit(unit),
            reason = reason,
        }
        LogHandler.write_log(newstring .. "PetitionResidency", msg)
    end

    function Helper.logGuildhallPetition(petition,newstring)
        local allEntities = df.global.world.entities.all
        local entityId = petition.parties[0].entity_ids[0]
        local entity = allEntities[entityId]

        local msg = {
            id = petition.id,
            PetitionType = "Guildhall",
            profession =  df.profession[petition.details[0].data.Location.profession],
            tier = petition.details[0].data.Location.tier,
            guild=dfhack.translation.translateName(entity.name,true)
        }
        LogHandler.write_log(newstring .. "PetitionGuildhall", msg)
    end

    function Helper.logTemplePetition(petition,newstring)
        -- to be implemented when we have a temple petition to analyze
         LogHandler.write_log(newstring .. "PetitionTemple", {id = petition.id})
    end

    function Helper.logPetition(petition,newstring)
        newstring = newstring or ""
        local dataTypeName = getDataTypeName(petition.details[0].data)
        names[dataTypeName] = petition.id

        if dataTypeName == "Residency" then
            Helper.logResidencyPetition(petition,newstring)
        elseif dataTypeName == "Location" then
            if petition.details[0].data.Location.type == 11 then -- 11 is guildhall
                Helper.logGuildhallPetition(petition,newstring)
            elseif petition.details[0].data.Location.type == 2 then -- 2 is temple
                Helper.logTemplePetition(petition,newstring)
            end
        end
    end




    -- State for watcher
    local nPreviousPetitions = {}
    local loggedPetitions = {}
    local playerfortid = df.global.plotinfo.site_id -- Player fortress id

    local function _watcher()
        local petitions = df.global.world.agreements.all

        -- watch the number of petitions and log when it changes
        if #petitions ~= nPreviousPetitions then
            local petition = petitions[#petitions-1] -- get the most recent petition, which is the one that changed the count
            if petition.flags.petition_not_accepted == true and not get_petition_age(petition)[1] ~= 0 then -- second condition means not expired
                Helper.logPetition(petitions[#petitions-1])
            end
        end

        nPreviousPetitions = #petitions

    end
      


function PetitionLogger.watch()
    _watcher()
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