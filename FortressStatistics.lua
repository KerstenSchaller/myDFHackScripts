local eventful = require('plugins.eventful')
local dfhack = require('dfhack')

--add the current path to the package path so we can load other local scripts

local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/'
package.path = script_dir .. '?.lua;' .. script_dir .. '?/init.lua;' .. package.path

print(package.path)

local sc = require('subScripts')
local LogHandler = sc.LogHandler
local Helper = sc.Helper
local AnnouncementWatcher = sc.AnnouncementWatcher


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


eventful.enableEvent(eventful.eventType.ITEM_CREATED, 1)
eventful.enableEvent(eventful.eventType.UNIT_DEATH, 1)
eventful.enableEvent(eventful.eventType.JOB_COMPLETED, 1)
eventful.enableEvent(eventful.eventType.INVASION, 1)
eventful.enableEvent(eventful.eventType.REPORT, 1)

----------------------------------------------------------------------------------------------------------------------------------
-- Function to append messages to a file



----------------------------------------------------------------------------------------------------------------------------------



function LogItem(item_id)
    local item = df.item.find(item_id)
    if not item then return end

    local item_name = dfhack.items.getDescription(item, 0)
    local item_type = df.item_type[item:getType()]
    local mat = dfhack.matinfo.decode(item)
    local mat_name = mat and mat:toString() or 'unknown material'

    local makerId = item.maker
    -- get unit with hist_fig_id == makerId
    local maker = Helper.getMakerName(makerId)


    local item_descr = dfhack.items.getReadableDescription(item)
    local msg = string.format(
        '[ItemCreated],id,%d,type,%s,material,%s,name,"%s",desc,"%s,maker,%s"',
        item_id,
        item_type,
        mat_name,
        item_name,
        item_descr,
        maker
    )

    msg = filterAnnouncement(msg, {"type=REMAINS", "name=magma", "type=SEEDS"})

    -- Write to file
    LogHandler.write_log(msg)
end





-------------------------------------------------------------------------------------------------------------------------------------
function LogUnit(unit_id)
    
    local unit = df.unit.find(unit_id)
    if not unit then return end

    
    
    local unit_race = dfhack.units.getRaceName(unit) or 'unknown'
    local unit_name = dfhack.units.getVisibleName(unit) or 'unknown'
    local unit_id_str = tostring(unit_id)

    local name = dfhack.units.getReadableName(unit) or 'unknown'
    local msg = string.format(
        '[UnitDeath],id,%s,name,"%s",race,"%s"', 
        unit_id_str,
        name,
        unit_race
    )

    -- Write to file
    LogHandler.write_log(msg)
end

function LogJob(job)

    local job_type = df.job_type[job.job_type] or 'unknown'
    local job_name = dfhack.job.getName(job) or 'unknown'
    local job_unit = dfhack.job.getWorker(job)
    local job_unit_name = job_unit and dfhack.units.getReadableName(job_unit) or 'unknown'

    local msg = string.format(
        '[JobCompleted],name,"%s",type,"%s",worker,"%s"', 
        job_name,
        job_type,
        job_unit_name
    )

    -- Write to file
    LogHandler.write_log(msg)
end









-- Call watchAnnouncements every 10 ticks (about 1 second)
local function startAnnouncementWatcher()
    local function tick()
        AnnouncementWatcher.watch()
        dfhack.timeout(10, 'ticks', tick)
    end
    tick()  
end

-------------------------------------------------------------------------------------------------------------------------------------
-- Main command handling
-------------------------------------------------------------------------------------------------------------------------------------
if command == 'enable' then
    dfhack.gui.showAnnouncement("DF_LOGGER_SUB enabled.", COLOR_WHITE)
    startAnnouncementWatcher()
    eventful.onItemCreated[modId] = function(itemId)
        LogItem(itemId)
    end
    eventful.onUnitDeath[modId] = function(unitId)
        LogUnit(unitId)
    end
    eventful.onJobCompleted[modId] = function(job)
        LogJob(job)
    end
    eventful.onInvasion[modId] = function(invasion)
        local msg = string.format("[Invasion],civ_id,%d,site_id,%d,size,%d", invasion.civ_id, invasion.site_id, invasion.size)
        LogHandler.write_log(msg)
    end

    print("Item announcer enabled.")

elseif command == 'disable' then
    dfhack.gui.showAnnouncement(modId .. " disabled.", COLOR_WHITE)
    eventful.onItemCreated[modId] = nil
    eventful.onUnitDeath[modId] = nil
    eventful.onJobCompleted[modId] = nil
    eventful.onInvasion[modId] = nil

    print(modId .. " disabled.")

else
    print("Usage: " .. modId .. " enable|disable")
end


----------------------------------------------------------------------------------------------------------------------------------




