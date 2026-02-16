local MaterialHelper = {}

local Gems = {
    "INDIGO TOURMALINE",
    "BLUE GARNET",
    "SAPPHIRE",
    "DIAMOND_BLUE",
    "PRASE",
    "PRASE OPAL",
    "MOSS AGATE",
    "MOSS OPAL",
    "VARISCITE",
    "AVENTURINE",
    "TSAVORITE",
    "GREEN TOURMALINE",
    "DEMANTOID",
    "GREEN ZIRCON",
    "EMERALD",
    "DIAMOND_GREEN",
    "BLOODSTONE",
    "SARD",
    "CARNELIAN",
    "BANDED AGATE",
    "SARDONYX",
    "CHERRY OPAL",
    "RED ZIRCON",
    "RED TOURMALINE",
    "RED PYROPE",
    "ALMANDINE",
    "RED GROSSULAR",
    "SPINEL_RED",
    "RUBY",
    "DIAMOND_RED",
    "LAVENDER JADE",
    "RHODOLITE",
    "SPINEL_PURPLE",
    "TUBE AGATE",
    "FIRE AGATE",
    "PLUME AGATE",
    "BROWN JASPER",
    "PICTURE JASPER",
    "SMOKY QUARTZ",
    "WAX OPAL",
    "WOOD OPAL",
    "AMBER OPAL",
    "CINNAMON GROSSULAR",
    "HONEY YELLOW BERYL",
    "JELLY OPAL",
    "BROWN ZIRCON",
    "DIAMOND_FY",
    "ONYX",
    "MORION",
    "SCHORL",
    "BLACK ZIRCON",
    "BLACK PYROPE",
    "MELANITE",
    "OPAL_BLACK",
    "DIAMOND_BLACK",
    "LACE AGATE",
    "BLUE JADE",
    "LAPIS LAZULI",
    "OPAL_CLARO",
    "SAPPHIRE_STAR",
    "CHRYSOPRASE",
    "GREEN JADE",
    "HELIODOR",
    "PERIDOT",
    "CHRYSOBERYL",
    "CHRYSOCOLLA",
    "TURQUOISE",
    "AQUAMARINE",
    "QUARTZ_ROSE",
    "PINK TOURMALINE",
    "RED BERYL",
    "FIRE OPAL",
    "OPAL_PFIRE",
    "OPAL_REDFLASH",
    "RUBY_STAR",
    "PINK JADE",
    "ALEXANDRITE",
    "TANZANITE",
    "MORGANITE",
    "VIOLET SPESSARTINE",
    "PINK GARNET",
    "KUNZITE",
    "AMETHYST",
    "GOLD OPAL",
    "CITRINE",
    "YELLOW JASPER",
    "TIGEREYE",
    "TIGER IRON",
    "SUNSTONE",
    "RESIN OPAL",
    "PYRITE",
    "YELLOW ZIRCON",
    "GOLDEN BERYL",
    "YELLOW SPESSARTINE",
    "TOPAZ",
    "TOPAZOLITE",
    "YELLOW GROSSULAR",
    "RUBICELLE",
    "OPAL_LEVIN",
    "DIAMOND_YELLOW",
    "CLEAR TOURMALINE",
    "GRAY CHALCEDONY",
    "DENDRITIC AGATE",
    "SHELL OPAL",
    "BONE OPAL",
    "WHITE CHALCEDONY",
    "FORTIFICATION AGATE",
    "MILK QUARTZ",
    "MOONSTONE",
    "WHITE JADE",
    "JASPER OPAL",
    "PINEAPPLE OPAL",
    "ONYX OPAL",
    "MILK OPAL",
    "PIPE OPAL",
    "CRYSTAL_ROCK",
    "CLEAR GARNET",
    "GOSHENITE",
    "CAT'S EYE",
    "CLEAR ZIRCON",
    "OPAL_WHITE",
    "OPAL_CRYSTAL",
    "OPAL_HARLEQUIN",
    "OPAL_PINFIRE",
    "OPAL_BANDFIRE",
    "DIAMOND_LY",
    "DIAMOND_CLEAR"
}

local Ores = {
    "HEMATITE",
    "LIMONITE",
    "GARNIERITE",
    "NATIVE_GOLD",
    "NATIVE_SILVER",
    "NATIVE_COPPER",
    "MALACHITE",
    "GALENA",
    "SPHALERITE",
    "CASSITERITE",
    "HORN_SILVER",
    "TETRAHEDRITE", 
    "NATIVE_PLATINUM",
    "BISMUTHINITE",
    "MAGNETITE",
    "NATIVE_ALUMINUM",
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
    "PETRIFIED_WOOD",-- nothing
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
    "RAW_ADAMANTINE",-- nothing
    "SLADE",-- nothing
	"SANDSTONE",
	"SILTSTONE",
	"MUDSTONE",
	"SHALE",
	"CLAYSTONE",
	"ROCK_SALT",
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
    "TOWER_CAP",
    "BLACK_CAP",
    "NETHER_CAP",
    "GOBLIN_CAP",
    "FUNGIWOOD",
    "TUNNEL_TUBE",
    "SPORE_TREE",
    "BLOOD_THORN",
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
     "PIG_IRON",
     "PLATINUM",
     "ELECTRUM",
     "TIN",
     "PEWTER_FINE",
     "PEWTER_TRIFLE",
     "PEWTER_LAY",
     "LEAD",
     "ALUMINUM",
     "NICKEL_SILVER",
     "BILLON",
     "STERLING_SILVER",
     "BLACK_BRONZE",
     "ROSE_GOLD",
     "BISMUTH",
     "BISMUTH_BRONZE",
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
    local item = MaterialHelper.getItemById(itemId)
    if not item then
        return "unknown"
    end
    dfhack.gui.showAnnouncement("id" .. tostring(item.id) )
    local mat_info = dfhack.matinfo.decode(item.mat_type, item.mat_index)
    local retString = "unknown"
    if mat_info and mat_info.mode == "plant" then
        retString = "Plant"
    end
    if mat_info and mat_info.mode == "inorganic" then
        -- check if it's a gem, stone mineral, or other rock
        if table.contains(Gems, string.upper(mat_info.material.state_name[0])) then
            retString = "Gem"
        end
        if table.contains(otherRocks, string.upper(mat_info.material.state_name[0])) then
            retString = "Rock"
        end
        if table.contains(economicStone, string.upper(mat_info.material.state_name[0])) then
            retString = "EconomicStone"
        end
        if table.contains(Ores, string.upper(mat_info.material.state_name[0])) then
            retString = "Ore"
        end
        if table.contains(metal, string.upper(mat_info.material.state_name[0])) then
            retString = "Metal"
        end
    end
    if mat_info and mat_info.mode == "creature" then
        retString = "Creature"
    end
    return retString
    
    
end




return MaterialHelper