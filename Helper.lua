--Helper

local Helper = {}

local dfhack = require('dfhack')

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
function Helper.watch(getCurrentList, getKey, logChange, logNew)
    local lastCount = 0
    local known_items = {}

    return function()
        local current_items = getCurrentList()
        local newCount = #current_items
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
        return newCount
    end
end

-- Helper function to resolve enum values to strings
function Helper.resolveEnum(k,v)
    local d = df[k]
    if d == nil then
        return tostring(v)
    else
        return d[v]..","..string.format("%s%s",tostring(k),"_value")..","..tostring(v)
    end

end





-- Helper function to recursively print table contents
function Helper.parseTable(t, serializedString)
    if type(t) ~= "table" and type(t) ~= "userdata" then
        -- header line
        serializedString = serializedString .. tostring(t) .. ","
        return
    end
    for k, v in pairs(t) do
        if type(v) == "table" or type(v) == "userdata" then
            --print("t: " .. tostring(v))
            serializedString = serializedString .. tostring(t) .. ","
            Helper.parseTable(v, serializedString)
        else
            --print("t: " .. tostring(v))
            serializedString = serializedString .. tostring(k) .. "," .. Helper.resolveEnum(k,v) .. ","
            print(tostring(k) .. ": " .. Helper.resolveEnum(k,v))
        end
    end
end

-- Helper function to recursively print table contents
function Helper.print(t, indent)
    indent = indent or ""
    if type(t) ~= "table" and type(t) ~= "userdata" then
        -- header line
        print("0 " .. indent .. tostring(t))
        return
    end
    for k, v in pairs(t) do
        if type(v) == "table" or type(v) == "userdata" then
            --print("t: " .. tostring(v))
            print("1 ".. indent .. tostring(k) .. ":")
            Helper.print(v, indent .. "  ")
        else
            --print("t: " .. tostring(v))
            print("2 " .. indent .. tostring(k) .. ": " .. Helper.resolveEnum(k,v))
        end
    end
end

return Helper

