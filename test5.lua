function splitStringIntoLines(text, max_width)
    local lines = {}
    local i = 1
    if type(text) == 'table' then
        return text
    end
    if text:find('\n') then
        for line in text:gmatch('[^\n]+') do
            table.insert(lines, line)
        end
        return lines
    end
    while i <= #text do
        local line = text:sub(i, i + max_width - 1)
        table.insert(lines, line)
        i = i + max_width
    end
    return lines
end

local longString = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
local shortString = "Lorem ipsum dolor sit."

local lines = splitStringIntoLines(longString, 50)
for i, line in ipairs(lines) do
    print(string.format("Line %d: %s", i, line))
end