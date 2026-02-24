
local Json = {}

-- Converts a Lua table to a JSON string, recursively handling nested tables.
function Json.table_to_json(tbl)
    -- Escapes special characters in strings for JSON output.
    local function escape_str(s)
        return '"' .. tostring(s):gsub('[%c\\"]', {
            ['\\'] = '\\\\', ['"'] = '\\"',
            ['\b'] = '\\b', ['\f'] = '\\f',
            ['\n'] = '\\n', ['\r'] = '\\r', ['\t'] = '\\t'
        }) .. '"'
    end

    -- Checks if a table is an array (all integer keys from 1..n, no gaps, no string keys).
    local function is_array(t)
        if type(t) ~= 'table' then return false end
        local count = 0
        local max = 0
        for k, v in pairs(t) do
            if type(k) ~= 'number' or k < 1 or math.floor(k) ~= k then
                return false
            end
            if k > max then max = k end
            count = count + 1
        end
        return count == max and count > 0
    end

    -- Recursively encodes a value as JSON.
    local function encode(val)
        if type(val) == "table" then
            if is_array(val) then
                -- Table is an array: encode as JSON array
                local res = {}
                for _, v in ipairs(val) do
                    table.insert(res, encode(v))
                end
                return "[" .. table.concat(res, ",") .. "]"
            else
                -- Table is an object: encode as JSON object
                local res = {}
                -- Custom key order: date, type, data first if present
                local key_order = {"date", "type", "data", "day", "month", "year", "ticks"}
                local used_keys = {}
                for _, key in ipairs(key_order) do
                    if val[key] ~= nil then
                        table.insert(res, escape_str(key) .. ":" .. encode(val[key]))
                        used_keys[key] = true
                    end
                end
                -- Add the rest of the keys (unordered)
                for k, v in pairs(val) do
                    if not used_keys[k] then
                        table.insert(res, escape_str(k) .. ":" .. encode(v))
                    end
                end
                return "{" .. table.concat(res, ",") .. "}"
            end
        elseif type(val) == "string" then
            return escape_str(val)
        elseif type(val) == "number" or type(val) == "boolean" then
            return tostring(val)
        elseif val == nil then
            return "null"
        else
            -- Only basic types are supported
            error("Unsupported type: " .. type(val))
        end
    end

    return encode(tbl)
end


    -- Parses a JSON string into a Lua table (basic implementation, handles objects, arrays, strings, numbers, booleans, and null)
    function Json.json_to_table(json)
        local pos = 1
        function skip_whitespace()
            pos = json:find("%S", pos) or (#json + 1)
        end

        function parse_string()
            local start = pos + 1 -- skip initial '"'
            local i = start
            local str = ''
            while i <= #json do
                local c = json:sub(i, i)
                if c == '\\' then
                    local nextc = json:sub(i+1, i+1)
                    if nextc == '"' or nextc == '\\' or nextc == '/' then
                        str = str .. nextc
                        i = i + 2
                    elseif nextc == 'b' then str = str .. '\b'; i = i + 2
                    elseif nextc == 'f' then str = str .. '\f'; i = i + 2
                    elseif nextc == 'n' then str = str .. '\n'; i = i + 2
                    elseif nextc == 'r' then str = str .. '\r'; i = i + 2
                    elseif nextc == 't' then str = str .. '\t'; i = i + 2
                    else error('Invalid escape at ' .. i) end
                elseif c == '"' then
                    pos = i + 1
                    return str
                else
                    str = str .. c
                    i = i + 1
                end
            end
            error('Unterminated string at ' .. start)
        end
        
        function parse_object()
            local obj = {}
            pos = pos + 1 -- skip '{'
            skip_whitespace()
            if json:sub(pos, pos) == '}' then
                pos = pos + 1
                return obj
            end
            while true do
                skip_whitespace()
                local key = parse_string()
                skip_whitespace()
                assert(json:sub(pos, pos) == ':', 'Expected : at position ' .. pos)
                pos = pos + 1
                local value = parse_value()
                obj[key] = value
                skip_whitespace()
                local char = json:sub(pos, pos)
                if char == '}' then
                    pos = pos + 1
                    break
                end
                assert(char == ',', 'Expected , at position ' .. pos)
                pos = pos + 1
            end
            return obj
        end
        
        function parse_array()
            local arr = {}
            pos = pos + 1 -- skip '['
            skip_whitespace()
            if json:sub(pos, pos) == ']' then
                pos = pos + 1
                return arr
            end
            while true do
                local value = parse_value()
                table.insert(arr, value)
                skip_whitespace()
                local char = json:sub(pos, pos)
                if char == ']' then
                    pos = pos + 1
                    break
                end
                assert(char == ',', 'Expected , at position ' .. pos)
                pos = pos + 1
            end
            return arr
        end

        
        function parse_number()
            local start = pos
            -- Matches a JSON number pattern: optional negative sign, digits with optional decimal point,
            -- optional exponent notation (e or E) with optional sign, and exponent digits.
            -- Examples: 123, -45, 3.14, 1.5e10, 2E-3
            local pat = '^[%-]?%d+%.?%d*[eE]?[%+%-]?%d*'
            local s, e = json:find(pat, pos)
            assert(s == pos, 'Invalid number at position ' .. pos)
            local num = tonumber(json:sub(s, e))
            pos = e + 1
            return num
        end
        
        function parse_value()
            skip_whitespace()
            local char = json:sub(pos, pos)
            if char == '{' then
                return parse_object()
            elseif char == '[' then
                return parse_array()
            elseif char == '"' then
                return parse_string()
            elseif char:match('[%d%-]') then
                return parse_number()
            elseif json:sub(pos, pos+3) == 'true' then
                pos = pos + 4
                return true
            elseif json:sub(pos, pos+4) == 'false' then
                pos = pos + 5
                return false
            elseif json:sub(pos, pos+3) == 'null' then
                pos = pos + 4
                return nil
            else
                error('Invalid JSON value at position ' .. pos)
            end
        end

        local result = parse_value()
        skip_whitespace()
        if pos <= #json then
            error('Unexpected trailing characters at position ' .. pos)
        end
        return result
    end



    -- Adds a key-value pair to the beginning of a JSON object string.
    -- Adds one or more key-value pairs (from a table or single key/value) to the beginning of a JSON object string.
    function Json.add_to_json_start(json_str, key_or_table, value)
        -- Only works for JSON objects (strings starting with '{')
        if type(json_str) ~= 'string' or json_str:sub(1,1) ~= '{' then
            error('Input must be a JSON object string')
        end
        local new_entries_tbl
        if type(key_or_table) == 'table' then
            new_entries_tbl = key_or_table
        else
            new_entries_tbl = {[key_or_table] = value}
        end
        -- Remove the opening and closing braces
        local inner = json_str:sub(2, -2)
        local new_entries = Json.table_to_json(new_entries_tbl):sub(2, -2)
        if #inner:gsub('%s','') == 0 then
            -- Empty object
            return '{' .. new_entries .. '}'
        else
            return '{' .. new_entries .. ',' .. inner .. '}'
        end
    end



-- Sample usage:
local _data = {
    name = "Dwarf",
    age = 42,
    skills = {"mining", "crafting"},
    stats = {strength = 10, agility = 8},
    alive = true
}


local date = {day = 15, month = 3, year = 105}
local msg = {date = date, data = _data}

local json_str = Json.table_to_json(msg)
print("JSON String:", json_str)

local parsed_data = Json.json_to_table(json_str)
print("Parsed Data:", parsed_data.data.name, parsed_data.data.age, parsed_data.data.skills[1], parsed_data.data.stats.strength, parsed_data.data.alive)

return Json