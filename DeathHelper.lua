local DeathHelper = {}

DEATH_TYPES = {
    [0] = ' died of old age',                 -- OLD_AGE
    [1] = ' starved to death',                      -- HUNGER
    [2] = ' died of dehydration',                   -- THIRST
    [3] = ' was shot and killed',                   -- SHOT
    [4] = ' bled to death',                         -- BLEED
    [5] = ' drowned',                               -- DROWN
    [6] = ' suffocated',                            -- SUFFOCATE
    [7] = ' was struck down',                       -- STRUCK_DOWN
    [8] = ' was scuttled',                          -- SCUTTLE
    [9] = " didn't survive a collision",            -- COLLISION
    [10] = ' took a magma bath',                     -- MAGMA
    [11] = ' took a magma shower',                   -- MAGMA_MIST
    [12] = ' was incinerated by dragon fire',        -- DRAGONFIRE
    [13] = ' was killed by fire',                    -- FIRE
    [14] = ' experienced death by SCALD',            -- SCALD
    [15] = ' was crushed by cavein',                 -- CAVEIN
    [16] = ' was smashed by a drawbridge',           -- DRAWBRIDGE
    [17] = ' was killed by falling rocks',           -- FALLING_ROCKS
    [18] = ' experienced death by CHASM',            -- CHASM
    [19] = ' experienced death by CAGE',             -- CAGE
    [20] = ' was murdered',                          -- MURDER
    [21] = ' was killed by a trap',                  -- TRAP
    [22] = ' vanished',                              -- VANISH
    [23] = ' experienced death by QUIT',             -- QUIT
    [24] = ' experienced death by ABANDON',          -- ABANDON
    [25] = ' suffered heat stroke',                  -- HEAT
    [26] = ' died of hypothermia',                   -- COLD
    [27] = ' experienced death by SPIKE',            -- SPIKE
    [28] = ' experienced death by ENCASE_LAVA',      -- ENCASE_LAVA
    [29] = ' experienced death by ENCASE_MAGMA',     -- ENCASE_MAGMA
    [30] = ' was preserved in ice',                  -- ENCASE_ICE
    [31] = ' became headless',                       -- BEHEAD
    [32] = ' was crucified',                         -- CRUCIFY
    [33] = ' experienced death by BURY_ALIVE',       -- BURY_ALIVE
    [34] = ' experienced death by DROWN_ALT',        -- DROWN_ALT
    [35] = ' experienced death by BURN_ALIVE',       -- BURN_ALIVE
    [36] = ' experienced death by FEED_TO_BEASTS',   -- FEED_TO_BEASTS
    [37] = ' experienced death by HACK_TO_PIECES',   -- HACK_TO_PIECES
    [38] = ' choked on air',                         -- LEAVE_OUT_IN_AIR
    [39] = ' experienced death by BOIL',             -- BOIL
    [40] = ' melted',                                -- MELT
    [41] = ' experienced death by CONDENSE',         -- CONDENSE
    [42] = ' experienced death by SOLIDIFY',         -- SOLIDIFY
    [43] = ' succumbed to infection',                -- INFECTION
    [44] = "'s ghost was put to rest with a memorial", -- MEMORIALIZE
    [45] = ' scared to death',                       -- SCARE
    [46] = ' experienced death by DARKNESS',         -- DARKNESS
    [47] = ' experienced death by COLLAPSE',         -- COLLAPSE
    [48] = ' was drained of blood',                  -- DRAIN_BLOOD
    [49] = ' was slaughtered',                       -- SLAUGHTER
    [50] = ' became roadkill',                       -- VEHICLE
    [51] = ' killed by a falling object',            -- FALLING_OBJECT
}

DEATH_STRINGS = 
{
["OLD_AGE"] = 0,
["HUNGER"] = 1,
["THIRST"] = 2,
["SHOT"] = 3,
["BLEED"] = 4,
["DROWN"] = 5,
["SUFFOCATE"] = 6,
["STRUCK_DOWN"] = 7,
["SCUTTLE"] = 8,
["COLLISION"] = 9,
["MAGMA"] = 10,
["MAGMA_MIST"] = 11,
["DRAGONFIRE"] = 12,
["FIRE"] = 13,
["SCALD"] = 14,
["CAVEIN"] = 15,
["DRAWBRIDGE"] = 16,
["FALLING_ROCKS"] = 17,
["CHASM"] = 18,
["CAGE"] = 19,
["MURDER"] = 20,
["TRAP"] = 21,
["VANISH"] = 22,
["QUIT"] = 23,
["ABANDON"] = 24,
["HEAT"] = 25,
["COLD"] = 26,
["SPIKE"] = 27,
["ENCASE_LAVA"] = 28,
["ENCASE_MAGMA"] = 29,
["ENCASE_ICE"] = 30,
["BEHEAD"] = 31,
["CRUCIFY"] = 32,
["BURY_ALIVE"] = 33,
["DROWN_ALT"] = 34,
["BURN_ALIVE"] = 35,
["FEED_TO_BEASTS"] = 36,
["HACK_TO_PIECES"] = 37,
["LEAVE_OUT_IN_AIR"] = 38,
["BOIL"] = 39,
["MELT"] = 40,
["CONDENSE"] = 41,
["SOLIDIFY"] = 42,
["INFECTION"] = 43,
["MEMORIALIZE"] = 44,
["SCARE"] = 45,
["DARKNESS"] = 46,
["COLLAPSE"] = 47,
["DRAIN_BLOOD"] = 48,
["SLAUGHTER"] = 49,
["VEHICLE"] = 50,
["FALLING_OBJECT"] = 51
}

function DeathHelper.getDeathCauseByString(death_cause)
    return DEATH_TYPES[DEATH_STRINGS[death_cause]] or " experienced an unknown death"
end


return DeathHelper