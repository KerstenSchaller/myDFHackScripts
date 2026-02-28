--Helper

local Helper = {}

local dfhack = require('dfhack')

-- Function to get the current date in day, month, year format
function Helper.date()
    local day = dfhack.world.ReadCurrentDay()
    local month = dfhack.world.ReadCurrentMonth()
    local year = dfhack.world.ReadCurrentYear()
    local ticks = dfhack.world.ReadCurrentTick()
    return {day = day, month = month, year = year, ticks = ticks}
end

function Helper.getUnitByHistFigureId(makerId)
    if makerId ~= -1 and makerId ~= nil then
        for _, unit in ipairs(df.global.world.units.all) do
            if unit.hist_figure_id == makerId then
                return unit
            end
        end
    end
    return nil
end

function Helper.getHistoricalFigureByid(id)
    for _, histfig in ipairs(df.global.world.history.figures) do
        if histfig.id == id then
            return histfig
        end
    end
    return nil
end


-- Generalized watcher function
function Helper.watch(getCurrentList, getKey, logChange, logNew, secondCondition) 
    local lastCount = 0
    local lastItemValues = {}
    local known_items = {}
    local firstCall = true

-- doesnt always work, if theres more than one petition it might fail because only the last one is changed

    return function()
            if firstCall then
                known_items = getCurrentList()
                dfhack.gui.showAnnouncement(string.format("Initial count: %d", #known_items))
                lastCount = #known_items
                firstCall = false
                if secondCondition ~= nil then
                    for id, item in ipairs(known_items) do
                        local _,_,val = secondCondition(lastItemValues[id],item)
                        lastItemValues[id] = val
                    end
                end
                return lastCount
            end
        local current_items = getCurrentList()
        local newCount = #current_items
        -- Check if count of items has changed and log changes
        if newCount ~= lastCount then
            logChange(lastCount, newCount)
            local known_keys = {}
            for _, item in ipairs(known_items) do
                known_keys[getKey(item)] = true
            end
            for _, item in ipairs(current_items) do
                local key = getKey(item)
                if not known_keys[key] then
                    logNew(item)
                end
            end
            known_items = current_items
            lastCount = newCount
        end
        --check if the last item has changed
        for id, item in ipairs(current_items) do
            local cond, value1, value2 = secondCondition(lastItemValues[id], item)
            if cond then
                logNew(item)
                known_items = current_items
                lastItemValues[id] = value2
            end
        end
        return newCount
    end
end

-- Helper function to resolve enum values to strings
function Helper.resolveEnum(k,v)
    if tostring(k) == nil or tostring(v) == nil then
        return "error_nil_key_or_value"
    end
    local d = df[k]
    if d == nil then
        return tostring(v)
    else
        local dv = d[v]
        if dv == nil then
            return "unknown_enum_value"
        end
        return d[v]
    end

end



function Helper.is_number(str)
    return tonumber(str) ~= nil and tostring(tonumber(str)) == str
end

local maxDepth = 6
local currentParseDepth = 0

-- Helper function to recursively print table contents
function Helper.parseTable(t, serializedString, parentPath)
    serializedString = serializedString or ""
    parentPath = parentPath or ""
    if type(t) ~= "table" and type(t) ~= "userdata" then
        -- header line
        serializedString = serializedString .. parentPath .. tostring(t) .. ","
        return serializedString
    end
    for k, v in pairs(t) do
        local fullPath = parentPath ~= "" and (parentPath .. "." .. tostring(k)) or tostring(k)
        if type(v) == "table" or type(v) == "userdata" then
            if currentParseDepth < maxDepth then
                currentParseDepth = currentParseDepth + 1
                serializedString = Helper.parseTable(v, serializedString, fullPath)
            end
        else
            if Helper.is_number(tostring(k)) and v == false then
                goto continue
            end
            serializedString = serializedString .. fullPath .. "," .. tostring(v) .. ","
            ::continue::
        end
    end
    currentParseDepth = currentParseDepth - 1
    return serializedString
end

function Helper.getValueFromSerializedString(serializedString, key)
    --- Constructs a Lua pattern string for matching a value between two delimiters.
    --- The pattern looks for the key followed by a comma, captures everything up to the next comma.
    --- @param key string The key or prefix to search for before the first comma
    --- @return string A Lua pattern string that captures content between commas in the format "key,(...),""
    local pattern = key .. ",([^,]*),?"
    local value = serializedString:match(pattern)
    if value == nil then
        local pattern = key .. ",(.-),"
        value = serializedString:match(pattern)
        if value == nil then
            return "value_not_found"
        end
    end
    return value
end

local maxDepth = 6
local currentPrintDepth = -1
local maxLines = 50
local currentLines = 0
-- Helper function to recursively print table contents
function Helper.printTable(t, indent, parentPath)
    currentPrintDepth = currentPrintDepth + 1
    indent = indent or ""
    parentPath = parentPath or ""
    if type(t) ~= "table" and type(t) ~= "userdata" then
        -- header line
        print(indent .. parentPath .. tostring(t))
        currentLines = currentLines + 1
        if currentLines >= maxLines then
            print("Max lines reached, stopping print.")
            return
        end
        return
    end
    for k, v in pairs(t) do
        local fullPath = parentPath ~= "" and (parentPath .. "." .. tostring(k)) or tostring(k)
        if type(v) == "table" or type(v) == "userdata" then
            print( " " .. indent .. fullPath .. ":")
            if currentPrintDepth < maxDepth then
                Helper.printTable(v, indent .. "  ", fullPath)
            end
        else
            if Helper.is_number(tostring(k)) and v == false then
                goto continue
            end
            print( indent .. fullPath .. ": " .. Helper.resolveEnum(k,v).. " (" .. tostring(v) .. ")")
            ::continue::
        end
    end
    currentPrintDepth = currentPrintDepth - 1
end

function Helper.getUnitById(id)
    for _, unit in ipairs(df.global.world.units.active) do
        if unit.id == id then
            return unit
        end
    end
    return nil
end

function Helper.getUnitNameById(id)
    local unit = Helper.getUnitById(id)
    if unit then
        local unitname = dfhack.translation.translateName(unit.name)
        if unitname == "" then
            unitname = dfhack.translation.translateName(unit.name)
        end
        return unitname
    else
        return "unknown_unit"
    end
end

function Helper.isUnitCitizen(unitId)
    for _, unit in ipairs(df.global.world.units.all) do
        if unit.id == unitId then
            if dfhack.units.isCitizen(unit) then
                return true
            end
        end
    end
    return false
end

function getKillerIdByVictimId(victimId)
    local incidents = df.global.world.incidents.all
    for _, incident in ipairs(incidents) do
        if incident.type == df.incident_type.Death and incident.victim == victimId then
            local death_incident = incident --:df.incident_deathst
            return death_incident.criminal
        end
    end
    return -1
end

function Helper.getNameOfKillerByVictimId(victimId)
            local killerId = getKillerIdByVictimId(victimId)
            if killerId ~= -1 then
                return Helper.getUnitNameById(killerId)
            end
    return "unknown_killer"
end

function Helper.getKillerIdbyVictimId(victimId)
    local incidents = df.global.world.incidents.all
    for _, incident in ipairs(incidents) do
        if incident.type == df.incident_type.Death then
            local death_incident = incident --:df.incident_deathst
            if death_incident.victim == victimId then
                return death_incident.criminal
            end
        end
    end
    return nil
end

function Helper.getIncidentDeathCauseByVictimId(victimId)
    local incidents = df.global.world.incidents.all
    for _, incident in ipairs(incidents) do
        if incident.type == df.incident_type.Death then
            local death_incident = incident --:df.incident_deathst
            if death_incident.victim == victimId then
                return death_incident.death_cause
            end
        end
    end
    return nil
end

function Helper.parsePerson(unit)
    local male = dfhack.units.isMale(unit)
	local sex = male and "male" or "female"
    local unit_histfig = Helper.getHistoricalFigureByid(unit.hist_figure_id)

    local profession = dfhack.units.getProfessionName(unit)

	return {
		id = unit.id,
		name = dfhack.translation.translateName(unit.name),
		name_english = dfhack.translation.translateName(unit.name,true),
		race = dfhack.units.getRaceReadableName(unit),
		age = dfhack.units.getAge(unit),
		isCitizen = Helper.isUnitCitizen(unit.id),
        isResident = unit.flags2.resident,
        isAnimal = unit.flags4.counts_as_animal,
        isMerchant = unit.flags1.merchant,
        isGuest = unit.flags3.guest,
		sex = sex,
        isPet = dfhack.units.isPet(unit),
        hostile = dfhack.units.isDanger(unit),
        profession = profession,
        motherId = unit.relationship_ids.Mother,
        fatherId = unit.relationship_ids.Father,
        spouseId = unit.relationship_ids.Spouse,
	}
end

function Helper.parseAnimal(unit)
    local male = dfhack.units.isMale(unit)
	local sex = male and "male" or "female"
    local unit_histfig = Helper.getHistoricalFigureByid(unit.hist_figure_id)

    local profession = dfhack.units.getProfessionName(unit)

	return {
		id = unit.id,
		name = dfhack.translation.translateName(unit.name),
		name_english = dfhack.translation.translateName(unit.name,true),
		race = dfhack.units.getRaceReadableName(unit),
		age = dfhack.units.getAge(unit),
        isAnimal = unit.flags4.counts_as_animal,
        isMerchant = unit.flags1.merchant,
        isTame = unit.flags1.tame,
		sex = sex,
        isPet = dfhack.units.isPet(unit),
        hostile = dfhack.units.isDanger(unit),
        butchered = unit.flags2.slaughter,
        motherId = unit.relationship_ids.Mother,
        fatherId = unit.relationship_ids.Father,
        petOwner = unit.relationship_ids.PetOwner,
	}
end


function Helper.parseUnit(unit)
	local male = dfhack.units.isMale(unit)
	local sex = male and "male" or "female"
    local unit_histfig = Helper.getHistoricalFigureByid(unit.hist_figure_id)
    local isAnimal = unit.flags4.counts_as_animal
    local profession = dfhack.units.getProfessionName(unit)

    if isAnimal then
        return Helper.parseAnimal(unit)
    else
        return Helper.parsePerson(unit)
    end 
end

function Helper.parseUnitById(unitId)
    local unit = Helper.getUnitById(unitId)
    if unit then
        return Helper.parseUnit(unit)
    else
        return nil
    end
end

return Helper

