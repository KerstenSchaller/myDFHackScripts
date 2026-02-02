local dfhack = require('dfhack')

local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/'
package.path = script_dir .. '?.lua;' .. script_dir .. '?/init.lua;' .. package.path

local Helper = require('Helper')
local LogHandler = require('LogHandler')


-- get all units
local units = df.global.world.units.all

print("Total number of active units:", #units)

function getUnit(id)
    for _, unit in ipairs(df.global.world.units.all) do
        if unit.id == id then
            return unit
        end
    end
    return nil
end

function getUnit(id)
    for _, unit in ipairs(df.global.world.units.all) do
        if unit.id == id then
            return unit
        end
    end
    return nil
end

function getEntity(id)
    for _, entity in ipairs(df.global.world.entities.all) do
        if entity.id == id then
            return entity
        end
    end
    return nil
end

function getHistFigure(id)
    for _, histfig in ipairs(df.global.world.history.figures) do
        if histfig.id == id then
            return histfig
        end
    end
    return nil
end



local maxDepth = 6
local currentPrintDepth = -1
local maxLines = 10
local currentLines = 0
function printTable(t, indent, parentPath)
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
            currentLines = currentLines + 1
            print(tostring(currentPrintDepth) .. " " .. indent .. fullPath .. ":")
            if currentPrintDepth < maxDepth then
                Helper.printTable(v, indent .. "  ", fullPath)
            end
        else
            if Helper.is_number(tostring(k)) and v == false then
                goto continue
            end
            currentLines = currentLines + 1
            print(tostring(currentPrintDepth) .. indent .. fullPath .. ": " .. Helper.resolveEnum(k,v))
            ::continue::
        end
    end
    currentPrintDepth = currentPrintDepth - 1
end


function getUnitParents(unit)
    local relations = unit.relationship_ids
    local motherId = relations.Mother
    local fatherId = relations.Father
    local motherUnit = getHistFigure(motherId)
    local fatherUnit = getHistFigure(fatherId)
    local motherUnitId = motherUnit.unit_id
    local fatherUnitId = fatherUnit.unit_id
    print("Mother Unit ID:", motherUnitId)
    print("Father Unit ID:", fatherUnitId)
    return getHistFigure(motherUnitId), getHistFigure(fatherUnitId)
end


local unitId  = 13149 
local unit = getUnit(unitId)
local motherUnit, fatherUnit = getUnitParents(unit)

motherName = dfhack.translation.translateName(motherUnit.name)
print("Mother Name:", motherName)
fatherName = dfhack.translation.translateName(fatherUnit.name)
print("Father Name:", fatherName)

local motherMother, motherFather = getUnitParents(motherUnit)

print("Maternal Grandmother Name:", dfhack.translation.translateName(motherMother.name))
print("Maternal Grandfather Name:", dfhack.translation.translateName(motherFather.name))