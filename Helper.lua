--Helper

local Helper = {}

local dfhack = require('dfhack')

-- Function to get the current date in day, month, year format
function Helper.date()
    local day = dfhack.world.ReadCurrentDay()
    local month = dfhack.world.ReadCurrentMonth()
    local year = dfhack.world.ReadCurrentYear()
    return string.format("%d,%d,%d",day, month,year)
end

function Helper.getMakerName(makerId)
    local maker = "unknown"
    if makerId ~= -1 and makerId ~= nil then
        for _, unit in ipairs(df.global.world.units.active) do
            if unit.hist_figure_id == makerId then
                maker = dfhack.units.getReadableName(unit) or tostring(makerId)
                break
            end
        end
    else
        maker = tostring(makerId)
    end
    return maker
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
                lastCount = #known_items
                firstCall = false
                if secondCondition ~= nil then
                    for id, item in ipairs(known_items) do
                        local _,_,val = secondCondition(nil,item)
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
                dfhack.gui.showAnnouncement("Petition change detected")
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
        return d[v]..","..string.format("%s%s",tostring(k),"_value")..","..tostring(v)
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
    local pattern = key .. ",(.-),"
    local value = serializedString:match(pattern)
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
        print("0 " .. indent .. parentPath .. tostring(t))
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
            print(tostring(currentPrintDepth) .. " " .. indent .. fullPath .. ":")
            if currentPrintDepth < maxDepth then
                Helper.printTable(v, indent .. "  ", fullPath)
            end
        else
            if Helper.is_number(tostring(k)) and v == false then
                goto continue
            end
            print(tostring(currentPrintDepth) .. indent .. fullPath .. ": " .. Helper.resolveEnum(k,v))
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
            unitname = dfhack.units.getReadableName(unit)
        end
        return unitname
    else
        return "unknown_unit"
    end
end

function Helper.isUnitCitizen(unitId)
    for _, unit in ipairs(df.global.world.units.active) do
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

return Helper

