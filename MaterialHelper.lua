local MaterialHelper = {}


local Ores = {
    "HEMATITE",
    "LIMONITE",
    "GARNIERITE",
    "NATIVE GOLD",
    "NATIVE SILVER",
    "NATIVE COPPER",
    "MALACHITE",
    "GALENA",
    "SPHALERITE",
    "CASSITERITE",
    "HORN SILVER",
    "TETRAHEDRITE", 
    "NATIVE PLATINUM",
    "BISMUTHINITE",
    "MAGNETITE",
    "NATIVE ALUMINUM",
}

local economicStone = {
    "BITUMINOUS COAL", -- not sure if this is correct, but it is the only coal type in the raws
    "LIGNITE", -- not sure if this is correct, but it is the only coal type in the raws
    "KAOLINITE",--clay stuff
    "CALCITE",-- steel incredients
    "ALABASTER",--plaster
    "SELENITE",--plaster
    "SATINSPAR",--plaster
}

local otherRocks = {
    "CINNABAR", -- nothing
    "COBALTITE", -- nothing
    "GYPSUM",-- nothing
    "TALC",-- nothing
    "JET",-- nothing
    "PUDDINGSTONE",-- nothing
    "PETRIFIED WOOD",-- nothing
    "GRAPHITE",-- nothing
    "BRIMSTONE",-- nothing
    "KIMBERLITE",-- nothing
    "REALGAR",-- nothing
    "ORPIMENT",-- nothing
    "STIBNITE",-- nothing
    "MARCASITE",-- nothing
    "SYLVITE",-- nothing
    "CRYOLITE",-- nothing
    "PERICLASE",-- nothing
    "ILMENITE",-- nothing
    "RUTILE",-- nothing
    "CHROMITE",-- nothing
    "PYROLUSITE",-- nothing
    "PITCHBLENDE",-- nothing
    "BAUXITE",-- nothing
    "BORAX",-- nothing
    "OLIVINE",-- nothing
    "HORNBLENDE",-- nothing
    "SERPENTINE",-- nothing
    "ORTHOCLASE",-- nothing
    "MICROCLINE",-- nothing
    "MICA",-- nothing
    "SALTPETER",-- nothing
    "ANHYDRITE",-- nothing
    "ALUNITE",-- nothing
    "RAW ADAMANTINE",-- nothing
    "SLADE",-- nothing
	"SANDSTONE",
	"SILTSTONE",
	"MUDSTONE",
	"SHALE",
	"CLAYSTONE",
	"ROCK SALT",
	"LIMESTONE",
	"CONGLOMERATE",
	"DOLOMITE",
	"CHERT",
	"CHALK",
	"GRANITE",
	"DIORITE",
	"GABBRO",
	"RHYOLITE",
	"BASALT",
	"ANDESITE",
	"OBSIDIAN",
	"QUARTZITE",
	"SLATE",
	"PHYLLITE",
	"SCHIST",
	"GNEISS",
	"MARBLE"
}

local Wood = {
    "MANGROVE",
    "SAGUARO",
    "PINE",
    "CEDAR",
    "OAK",
    "MAHOGANY",
    "ACACIA",
    "KAPOK",
    "MAPLE",
    "WILLOW",
    "TOWER CAP",
    "BLACK CAP",
    "NETHER CAP",
    "GOBLIN CAP",
    "FUNGIWOOD",
    "TUNNEL TUBE",
    "SPORE TREE",
    "BLOOD THORN",
    "GLUMPRONG",
    "FEATHER",
    "HIGHWOOD",
    "LARCH",
    "CHESTNUT",
    "ALDER",
    "BIRCH",
    "ASH",
    "CANDLENUT",
    "MANGO",
    "RUBBER",
    "CACAO",
    "PALM"
}

local metal = {
     "IRON",
     "GOLD",
     "SILVER",
     "COPPER",
     "NICKEL",
     "ZINC",
     "BRONZE",
     "BRASS",
     "STEEL",
     "PIG IRON",
     "PLATINUM",
     "ELECTRUM",
     "TIN",
     "FINE PEWTER",
     "TRIFLE PEWTER",
     "LAY PEWTER",
     "LEAD",
     "ALUMINUM",
     "NICKEL SILVER",
     "BILLON",
     "STERLING SILVER",
     "BLACK BRONZE",
     "ROSE GOLD",
     "BISMUTH",
     "BISMUTH BRONZE",
     "ADAMANTINE",
}

function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

local dfhack = require('dfhack')

function MaterialHelper.getItemById(id)
    local items = df.global.world.items.all
    for _, item in ipairs(items) do
        if item.id == id then
            return item
        end
    end
end


function MaterialHelper.typeInfoByItemId(itemId)
    local item
    if type(itemId) == "number" then
        item = MaterialHelper.getItemById(itemId)
        if not item then
            print("Item with id " .. tostring(itemId) .. " not found.")
            return "unknown"
        end
    else
        item = itemId -- assume itemId is already an item object
    end

    local item_str = tostring(item)
    local item_type = item_str:match("^<([%w_]+):") or item_str


    if item_type == "item_eggst" then
        return "Food"
    end

    if item_type == "item_fishst" then
        return "Food"
    end

    if item_type == "item_corpsest" or item_type == "item_corpsepiecest" or item_type == "item_skullst" or item_type == "item_remainsst" then
        return "Corpse"
    end

    local mat_info = nil
    local ok, result = pcall(function()
        mat_info = dfhack.matinfo.decode(item.mat_type, item.mat_index)
    end)
    if not ok then
        print("Error: " .. item_type .. " has no material info. Item ID: " .. item.id)
        return ""
    else
        -- use result
    end


    if mat_info and mat_info.material.id == "Drink" then
        return "Drink"
    end

    if mat_info and mat_info.material.id == "Seed" then
        return "Seed"
    end

    local material_flags = mat_info and mat_info.material.flags or ""
    if material_flags.EDIBLE_VERMIN == true or material_flags.EDIBLE_RAW == true or material_flags.EDIBLE_COOKED == true then
        return "Food"
    end

    if mat_info and mat_info.mode == "plant" then
        return "Plant"
    end
    if mat_info and mat_info.mode == "inorganic" then
        local flags = mat_info.material.flags

        -- check if it's a gem, stone mineral, or other rock
        if flags.IS_GEM then
            return "Gem"
        end
        if flags.IS_STONE then        
            if table.contains(otherRocks, string.upper(mat_info.material.state_name[0])) then
                return "Rock"
            end
            if table.contains(economicStone, string.upper(mat_info.material.state_name[0])) then
                return "EconomicStone"
            end
            if table.contains(Ores, string.upper(mat_info.material.state_name[0])) then
                return "Ore"
            end
            if flags.IS_CERAMIC then
                return "Ceramic"
            end
            return "Unknown Rock: " .. mat_info.material.state_name[0]
        end
        if table.contains(metal, string.upper(mat_info.material.state_name[0])) then
            return "Metal"
        end

        
    end
    
    if mat_info and mat_info.mode == "builtin" then
        return mat_info.material.id
    end
    
    if mat_info and mat_info.mode == "creature" then
        return "Creature"
    end
    
    print("Material is metal: " .. mat_info.material.state_name[0])
    return "Unknown".. " (" .. item_type .. ")"..item.mat_type..":"..item.mat_index ..","..item.id
end




return MaterialHelper