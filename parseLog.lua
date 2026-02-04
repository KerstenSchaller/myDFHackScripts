

local dfhack = require('dfhack')
local eventful = require('plugins.eventful')

local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/'
package.path = script_dir .. '?.lua;' .. script_dir .. '?/init.lua;' .. package.path

local Helper = require('Helper')
local logHandler = require('LogHandler')




function splitCommaSeparated(str)
   local result = {}
   for entry in string.gmatch(str, '([^,]+)') do
      table.insert(result, entry)
   end
   return result
end


function logItemPartsToTable(parts)
   local t = {
      date = {
         day = parts[1],
         month = parts[2],
         year = parts[3]
      },
      eventtype = parts[4],
      id = parts[6],
      type = parts[8],
      material = parts[10],
      name = parts[12],
      desc = parts[14],
      maker = parts[16],
      quality = parts[19],
      value = parts[21],
      artifact = parts[23]
   }

   return t
end

-- Converts a split log line for [Announcement] into a structured table with named fields
function logAnnouncementPartsToTable(parts)
   return {
      date = {
         day = parts[1],
         month = parts[2],
         year = parts[3]
      },
      eventtype = parts[4],
      id = parts[6],
      text = parts[8],
      repeat_count = parts[10]
   }
end

-- Converts a split log line for [JobCompleted] into a structured table with named fields
function logJobCompletedPartsToTable(parts)
   return {
      date = {
         day = parts[1],
         month = parts[2],
         year = parts[3]
      },
      eventtype = parts[4],
      name = parts[6],
      type = parts[8],
      worker = parts[10],
   }
end

-- Converts a split log line for [UnitDeath] into a structured table with named fields
function logUnitDeathPartsToTable(parts)
   local joinedPartsString = table.concat(parts, ",", 8)
   return {
      date = {
         day = parts[1],
         month = parts[2],
         year = parts[3]
      },
      eventtype = parts[4],
      id = parts[6],
      name = Helper.getValueFromSerializedString(joinedPartsString,"name"),
      race = Helper.getValueFromSerializedString(joinedPartsString,"race"),
      death_cause = Helper.getValueFromSerializedString(joinedPartsString,"death_cause"),
      death_type_value = Helper.getValueFromSerializedString(joinedPartsString,"death_type_value"),
      killer = Helper.getValueFromSerializedString(joinedPartsString,"killer"),
      killed_by_citizen = Helper.getValueFromSerializedString(joinedPartsString,"killed_by_citizen"),
      killer_race = Helper.getValueFromSerializedString(joinedPartsString,"killer_race")
   }
end

-- Converts a split log line for [PetitionChange] into a structured table with key-value pairs
function logPetitionChangePartsToTable(parts)
   local newCond = parts[5] == "[NEW]" and true or false
   local t = {
      date = {
         day = parts[1],
         month = parts[2],
         year = parts[3]
      },
      eventtype = parts[4],
      newPetition = newCond,
      petitionDataStr = table.concat(parts, ",", newCond and 6 or 5)


   }
   return t
end


function listNumberOfDifferentMessages(logLines)
   local unique = {}
   for _, line in ipairs(logLines) do
    print(line)
      local parts = splitCommaSeparated(line)
      if parts[4] then
         unique[parts[4]] = true
         
      end
   end
   print('Unique message types (4th element) in logLines:')
   for msgType, _ in pairs(unique) do
      print(msgType)
   end
end




-- Parses logLines into lists according to their 4th element
function parseLogLinesByType(logLines)
   local Announcement = {}
   local ItemCreated = {}
   local PetitionChange = {}
   local Citizens = {}
   local JobCompleted = {}
   local UnitDeath = {}

   for _, line in ipairs(logLines) do
      local parts = splitCommaSeparated(line)
      local msgType = parts[4]
      if msgType == '[Announcement]' then
         table.insert(Announcement, logAnnouncementPartsToTable(parts))
      elseif msgType == '[ItemCreated]' then
         table.insert(ItemCreated, logItemPartsToTable(parts))
      elseif msgType == '[PetitionChange]' then
         table.insert(PetitionChange, logPetitionChangePartsToTable(parts))
      elseif msgType == '[Citizens]' then
         table.insert(Citizens, parts)
      elseif msgType == '[JobCompleted]' then
         table.insert(JobCompleted, logJobCompletedPartsToTable(parts))
      elseif msgType == '[UnitDeath]' then
         table.insert(UnitDeath, logUnitDeathPartsToTable(parts))
      end
   end

   return {
      Announcement = Announcement,
      ItemCreated = ItemCreated,
      PetitionChange = PetitionChange,
      Citizens = Citizens,
      JobCompleted = JobCompleted,
      UnitDeath = UnitDeath
   }
end


function analyzeJobCompleted(jobCompletedLines)
    local jobTypeCount = {}
    local workerCount = {}
    local jobsByWorker = {}

    for _, line in ipairs(jobCompletedLines) do
        local parts = splitCommaSeparated(line)
        -- Example format: [JobCompleted],name,Carpenter,type,Carpenter,worker,Urist McCarpenter
        local jobType = parts[6] or "unknown"
        local worker = parts[8] or "unknown"

        -- Count job types
        jobTypeCount[jobType] = (jobTypeCount[jobType] or 0) + 1

        -- Count jobs per worker
        workerCount[worker] = (workerCount[worker] or 0) + 1

        -- Track job types by worker
        jobsByWorker[worker] = jobsByWorker[worker] or {}
        jobsByWorker[worker][jobType] = (jobsByWorker[worker][jobType] or 0) + 1
    end

    print("Total JobCompleted events: " .. #jobCompletedLines)
    print("\nMost common job types:")
    for jobType, count in pairs(jobTypeCount) do
        print(jobType .. ": " .. count)
    end

    print("\nMost active workers:")
    for worker, count in pairs(workerCount) do
        print(worker .. ": " .. count)
    end

    print("\nJob types by worker:")
    for worker, jobs in pairs(jobsByWorker) do
        print(worker .. ":")
        for jobType, count in pairs(jobs) do
            print("  " .. jobType .. ": " .. count)
        end
    end
end


function analyzeItemCreated(itemCreatedLines)
   local itemTypeCount = {}
   local creatorCount = {}
   local itemsByCreator = {}
   local masterworkCount = 0
   local masterworkNames = {}

   for _, item in ipairs(itemCreatedLines) do
      local itemType = item.type or "unknown"
      local creator = item.maker or "unknown"
      local quality = item.quality or ""
      local name = item.name or "(unnamed)"

      -- Count item types
      itemTypeCount[itemType] = (itemTypeCount[itemType] or 0) + 1

      -- Count items per creator
      creatorCount[creator] = (creatorCount[creator] or 0) + 1

      -- Track item types by creator
      itemsByCreator[creator] = itemsByCreator[creator] or {}
      itemsByCreator[creator][itemType] = (itemsByCreator[creator][itemType] or 0) + 1

      -- Count masterwork items (quality == '5') and collect their names
      if tostring(quality) == '5' then
         masterworkCount = masterworkCount + 1
         table.insert(masterworkNames, name)
      end
   end

   -- Helper to sort a table of key-value pairs by value descending
   local function getTopN(tbl, n)
      local arr = {}
      for k, v in pairs(tbl) do
         table.insert(arr, {k, v})
      end
      table.sort(arr, function(a, b) return a[2] > b[2] end)
      local result = {}
      for i = 1, math.min(n, #arr) do
         table.insert(result, arr[i])
      end
      return result
   end

   print("Total ItemCreated events: " .. #itemCreatedLines)
   print("Number of masterwork items (quality 5): " .. masterworkCount)
   if masterworkCount > 0 then
      print("Names of masterwork items:")
      for _, n in ipairs(masterworkNames) do
         print("  " .. n)
      end
   end
   print("\nTop 10 most common item types:")
   for _, pair in ipairs(getTopN(itemTypeCount, 10)) do
      print(pair[1] .. ": " .. pair[2])
   end

   print("\nTop 10 most active creators:")
   for _, pair in ipairs(getTopN(creatorCount, 10)) do
      print(pair[1] .. ": " .. pair[2])
   end

   print("\nTop 10 creators and their top item types:")
   local topCreators = getTopN(creatorCount, 10)
   for _, pair in ipairs(topCreators) do
      local creator = pair[1]
      print(creator .. ":")
      local topItems = getTopN(itemsByCreator[creator], 10)
      for _, itemPair in ipairs(topItems) do
         --print("  " .. itemPair[1] .. ": " .. itemPair[2])
      end
   end
end

local logLines = logHandler.readAllLogLines()
local parsedLists = parseLogLinesByType(logLines)




print("Number of Announcement logs: " .. #parsedLists.Announcement)
print("Number of ItemCreated logs: " .. #parsedLists.ItemCreated)   
print("Number of PetitionChange logs: " .. #parsedLists.PetitionChange)
print("Number of Citizens logs: " .. #parsedLists.Citizens)
print("Number of JobCompleted logs: " .. #parsedLists.JobCompleted)

--analyzeJobCompleted(parsedLists.JobCompleted)
analyzeItemCreated(parsedLists.ItemCreated)

