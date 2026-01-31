local dfhack = require('dfhack') -- or just use global df

-- Example: Inspecting a named type (struct/class)

local all = df.global.world.agreements.all
local details = all[#all-1].details[0]
local unit_type = details._type

print("Kind:", unit_type._kind) -- e.g., 'class-type'
print("Is union?", unit_type._union) -- usually nil for structs/classes
print("Type identity:", unit_type._identity)

-- List all fields of the type
for field_name, field_info in pairs(unit_type._fields) do
    print("Field:", field_name)
    print("  Offset:", field_info.offset)
    print("  Count:", field_info.count)
    print("  Type name:", field_info.type_name)
    print("  Mode:", field_info.mode)
    -- You can also inspect type, type_identity, etc. if present
end

-- Create a new instance (not always safe for all types!)
-- local new_unit = unit_type:new()
-- print("Created new unit:", new_unit)

-- Check size of the type
print("Size of unit:", unit_type:sizeof())

-- Check if an object is an instance of the type
local some_unit = df.global.world.units.active[0]
print("Is instance:", unit_type:is_instance(some_unit))

-- Example: Enum type
local goal_type = df.goal_type
print("Enum kind:", goal_type._kind) -- 'enum-type'

-- List all enum values and their attributes
for k, v in pairs(goal_type.attrs) do
    print("Enum key:", k, "Value:", v)
    if type(v) == 'table' then
        for attr, val in pairs(v) do
            print("  ", attr, val)
        end
    end
end

-- Get next enum item
local first = goal_type._first_item
local next_item = goal_type.next_item(first)
print("Next enum item after first:", next_item)

-- Example: Using get_vector() for types with instance vectors
local items = df.item.get_vector()
print("Number of items in world:", #items)

-- Example: Using find(key) if available
-- local found_item = df.item.find(some_id)
-- print("Found item:", found_item)