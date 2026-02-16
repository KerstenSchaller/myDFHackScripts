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

local dfhack = require('dfhack')

local allInorganics = df.global.world.raws.inorganics.all

function getItemById(id)
    local items = df.global.world.items.all
    for _, item in ipairs(items) do
        if item.id == id then
            return item
        end
    end
end

function printMaterialInfo(mat_info)
    for k, v in pairs(mat_info) do
        if type(v) ~= "table" then
            print(k .. "= " .. tostring(v))
        else
            print(k .. ":")
            for sub_k, sub_v in pairs(v) do
                print("  " .. sub_k .. "- " .. tostring(sub_v))
            end
        end
    end
    print("")
    print("")
end

local woodItem = getItemById(5855) -- replace with actual item ID
local anotherWoodItem = getItemById(20136) -- replace with actual item ID

local barItem = getItemById(10178) -- replace with actual item ID
local anotherBarItem = getItemById(38287) -- replace with actual item ID
local rockItem = getItemById(3906) -- replace with actual item ID
local anotherRockItem = getItemById(3833) -- replace with actual item ID
local leatherItem = getItemById(15268) -- replace with actual item ID
local gemItem = getItemById(24595) -- replace with actual item ID



local matHelper = require('MaterialHelper')


local mat_info_wood = dfhack.matinfo.decode(woodItem.mat_type, woodItem.mat_index)
print("Material: " .. mat_info_wood.material.state_name[0])
--printMaterialInfo(mat_info_wood)
local matName = matHelper.typeInfoByItemId(woodItem.id)
print("Material type: " .. matName)

local mat_info_another_wood = dfhack.matinfo.decode(anotherWoodItem.mat_type, anotherWoodItem.mat_index)
print("Material: " .. mat_info_another_wood.material.state_name[0])
--printMaterialInfo(mat_info_another_wood)
local matNameAnotherWood = matHelper.typeInfoByItemId(anotherWoodItem)
print("Material type: " .. matNameAnotherWood)

local mat_info_leather = dfhack.matinfo.decode(leatherItem.mat_type, leatherItem.mat_index)
print("Material: " .. mat_info_leather.material.state_name[0])
--printMaterialInfo(mat_info_leather)
local matNameLeather = matHelper.typeInfoByItemId(leatherItem)
print("Material type: " .. matNameLeather)

local mat_info_bar = dfhack.matinfo.decode(barItem.mat_type, barItem.mat_index)
print("Material: " .. mat_info_bar.material.state_name[0])
--printMaterialInfo(mat_info_bar)
local matNameBar = matHelper.typeInfoByItemId(barItem)
print("Material type: " .. matNameBar)

local mat_info_another_bar = dfhack.matinfo.decode(anotherBarItem.mat_type, anotherBarItem.mat_index)
print("Material: " .. mat_info_another_bar.material.state_name[0])
--printMaterialInfo(mat_info_another_bar)
local matNameAnotherBar = matHelper.typeInfoByItemId(anotherBarItem)
print("Material type: " .. matNameAnotherBar)

local mat_info_rock = dfhack.matinfo.decode(rockItem.mat_type, rockItem.mat_index)
print("Material: " .. mat_info_rock.material.state_name[0])
--printMaterialInfo(mat_info_rock)
local matNameRock = matHelper.typeInfoByItemId(rockItem)
print("Material type: " .. matNameRock)

local mat_info_another_rock = dfhack.matinfo.decode(anotherRockItem.mat_type, anotherRockItem.mat_index)
print("Material: " .. mat_info_another_rock.material.state_name[0])
--printMaterialInfo(mat_info_another_rock)
local matNameAnotherRock = matHelper.typeInfoByItemId(anotherRockItem)
print("Material type: " .. matNameAnotherRock)

local mat_info_gem = dfhack.matinfo.decode(gemItem.mat_type, gemItem.mat_index)
print("Material: " .. mat_info_gem.material.state_name[0])
--printMaterialInfo(mat_info_gem)
local matNameGem = matHelper.typeInfoByItemId(gemItem)
print("Material type: " .. matNameGem)

