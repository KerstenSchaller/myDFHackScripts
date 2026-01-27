local eventful = require('plugins.eventful')
local dfhack = require('dfhack')

--reload all scripts


--add the current path to the package path so we can load other local scripts
local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/'
package.path = script_dir .. '?.lua;' .. script_dir .. '?/init.lua;' .. package.path


local LogHandler = require('LogHandler')
local Helper = require('Helper')
local AnnouncementLogger = require('AnnouncementLogger')
local ItemLogger = require('ItemLogger')

local DeathLogger = require('DeathLogger')  
local JobLogger = require('JobLogger')
local InvasionLogger = require('InvasionLogger')
local BookAnnouncer = require('AnnounceBooks')
local CitezenLogger = require('CitizenLogger')
local PetitionLogger = require('PetitionLogger')
-------------------------------------------------------------------------------------------------------------------------------------

eventful.enableEvent(eventful.eventType.ITEM_CREATED, 1)
eventful.enableEvent(eventful.eventType.UNIT_DEATH, 1)
eventful.enableEvent(eventful.eventType.JOB_COMPLETED, 1)
eventful.enableEvent(eventful.eventType.INVASION, 1)

local args = {...}
local command = args[1] or 'help'


local modId = "DF_STATS"

local Version = "0.1.0"
print('DF_LOGGER_SUB v' .. Version .. ' loading...')

---eventType=invertTable{
---    [0]="TICK",
---    "JOB_INITIATED",   
---    "JOB_STARTED",
--- X  "JOB_COMPLETED",    
---    "UNIT_NEW_ACTIVE",
--- X  "UNIT_DEATH",
--- X  "ITEM_CREATED",
---    "BUILDING",
---    "CONSTRUCTION",
---    "SYNDROME",
--- X  "INVASION",
---    "INVENTORY_CHANGE",
--- O  "REPORT", -- handled via polling
---    "UNIT_ATTACK",
---    "UNLOAD",
---    "INTERACTION",
---    "EVENT_MAX"
---}
---







----------------------------------------------------------------------------------------------------------------------------------
-- Function to append messages to a file



----------------------------------------------------------------------------------------------------------------------------------







-- Call watchAnnouncements every 10 ticks (about 1 second)

local watcherActive = false
local lastAnnouncementId = -1
local function startWatcher()
    print("Starting DF_LOGGER_SUB watcher...")
    watcherActive = true


    local function tick()
        if not watcherActive then return end
        AnnouncementLogger.watch()
        CitezenLogger.watch()
        BookAnnouncer.checkForNewBooks()
        PetitionLogger.watch()
        if watcherActive then
            dfhack.timeout(10, 'ticks', tick)
        end
    end
    tick()
end

local function stopWatcher()
    watcherActive = false
end

local function shutdownLogging()
    stopWatcher()
    eventful.onItemCreated[modId] = nil
    eventful.onUnitDeath[modId] = nil
    eventful.onJobCompleted[modId] = nil
    eventful.onInvasion[modId] = nil
    dfhack.gui.showAnnouncement("DF_LOGGER_SUB shutdown.", COLOR_WHITE)
end



local function setupLogging()
    dfhack.gui.showAnnouncement("DF_LOGGER_SUB enabled.", COLOR_WHITE)
    startWatcher()
    eventful.onItemCreated[modId] = function(itemId)
        ItemLogger.log(itemId)
    end
    eventful.onUnitDeath[modId] = function(unitId)
        DeathLogger.log(unitId)
    end
    eventful.onJobCompleted[modId] = function(job)
        JobLogger.log(job)
    end
    eventful.onInvasion[modId] = function(invasion)
        local msg = string.format("[Invasion],civ_id,%d,site_id,%d,size,%d", invasion.civ_id, invasion.site_id, invasion.size)
        LogHandler.write_log(msg)
    end

    print("Item announcer enabled.")
end

-------------------------------------------------------------------------------------------------------------------------------------
-- Main command handling
-------------------------------------------------------------------------------------------------------------------------------------

if command == 'enable' then
    setupLogging()
elseif command == 'disable' then
    shutdownLogging()
else
    print("Usage: " .. modId .. " enable|disable")
end


----------------------------------------------------------------------------------------------------------------------------------




