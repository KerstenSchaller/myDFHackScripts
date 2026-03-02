

local dfhack = require('dfhack')
local eventful = require('plugins.eventful')

local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/'
package.path = script_dir .. '?.lua;' .. script_dir .. '?/init.lua;' .. package.path

local Helper = require('Helper')
local logHandler = require('LogHandler')
local MaterialHelper = require('MaterialHelper')
local Json = require('Json')

local LogParser = {}

function LogParser.splitCommaSeparated(str)
   local result = {}
   for entry in string.gmatch(str, '([^,]+)') do
      table.insert(result, entry)
   end
   return result
end





function LogParser.analyzeUnitDeaths(unitDeathLines, yearFilter)

   local killedByCitizen={}
   local dwarfDeaths = {}
   for _, death in ipairs(unitDeathLines) do
      if yearFilter and death.date.year ~= yearFilter then
         goto continueDeaths
      end
      if death.data.victim.killed_by_citizen == true then
         table.insert(killedByCitizen,death)
      end
      if death.data.victim.race == "dwarf" then
         table.insert(dwarfDeaths, death)
      end
      ::continueDeaths::
   end
   
   return {
      KilledByCitizen = killedByCitizen,
      DwarfDeaths = dwarfDeaths
   }
end



function LogParser.listNumberOfDifferentMessages(logLines)
   local unique = {}
   for _, line in ipairs(logLines) do
    print(line)
      local parts = LogParser.splitCommaSeparated(line)
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
function LogParser.parseLogLinesByType(logLines)
   local Announcement = {}
   local ItemCreated = {}
   local PetitionChange = {}
   local Citizens = {}
   local JobCompleted = {}
   local UnitDeath = {}
   local years = {}

   for _, line in ipairs(logLines) do
      local item = Json.json_to_table(line)

      local msgType = item.type
      if msgType == 'Announcement' then
         table.insert(Announcement, item)
      elseif msgType == 'ItemCreated' then
         table.insert(ItemCreated, item)
      elseif msgType == 'PetitionResidency' or msgType == 'PetitionLocation' then
         table.insert(PetitionChange, item)
      elseif msgType == 'Citizen' then
         table.insert(Citizens, item)
      elseif msgType == 'JobCompleted' then
         table.insert(JobCompleted, item)
      elseif msgType == 'UnitDeath' then
         table.insert(UnitDeath, item)
      end

      -- Collect unique years
      local year = item.date.year 
      
      if year then
         years[year] = true
      end
   end

   --sort years numerically 
   local sortedYears = {}
   for year, _ in pairs(years) do
      table.insert(sortedYears, year)
   end
   table.sort(sortedYears)
   
   local stringYears = {}
   for _, year in ipairs(sortedYears) do
      table.insert(stringYears, tostring(year))
   end

   return {
      Announcement = Announcement,
      ItemCreated = ItemCreated,
      PetitionChange = PetitionChange,
      Citizens = Citizens,
      JobCompleted = JobCompleted,
      UnitDeath = UnitDeath,
      Years = stringYears
   }
end

-- Helper to sort a table of key-value pairs by value descending
function LogParser.getTopN(tbl, n)
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

function LogParser.analyzeCitizens(citizenLines, yearFilter)
   local newCitzens = {}

   for _, citizen in ipairs(citizenLines) do
      if yearFilter and tostring(citizen.date.year) ~= tostring(yearFilter) then
         goto continueCitizens
      end

      -- check for new citizens and collect their info
      if citizen.data.type == "newcitizen" then
         local citizenInfo = citizen.data.citizen
         table.insert(newCitzens, citizenInfo)
      end


      ::continueCitizens::

   end
   return {
      NewCitizens = newCitzens
   }
end

function LogParser.analyzeJobs(jobCompletedLines, yearFilter)
   local jobTypeCount = {}
   local workerCount = {}
   local jobsByWorker = {}
   local diggingCountByWorker = {}
   local smoothStoneCountByWorker = {}
   local encraveCountByWorker = {}

   for _, job in ipairs(jobCompletedLines) do
      if yearFilter and tostring(job.date.year) ~= tostring(yearFilter) then
         goto continueJobs
      end
      if job.data.job_name == "Dig" or job.data.job_name == "Dig channel" or job.data.job_name == "Dig ramp" then
         diggingCountByWorker[job.data.job_unit.name] = (diggingCountByWorker[job.data.job_unit.name] or 0) + 1
         goto continueJobs
      end
      if job.data.job_name == "Smooth floor" or job.data.job_name == "Smooth wall" then
         smoothStoneCountByWorker[job.data.job_unit.name] = (smoothStoneCountByWorker[job.data.job_unit.name] or 0) + 1
         goto continueJobs
      end
      if job.data.job_name == "Detail floor" or job.data.job_name == "Detail wall" then
         encraveCountByWorker[job.data.job_unit.name] = (encraveCountByWorker[job.data.job_unit.name] or 0) + 1
         goto continueJobs
      end
      -- skip eat,drink, and sleep jobs to focus on labor jobs
      if job.data.job_name == "Eat" or job.data.job_name == "Drink" or job.data.job_name == "Sleep" then
         goto continueJobs
      end

      -- Example format: [JobCompleted],name,Carpenter,type,Carpenter,worker,Urist McCarpenter
      -- Extract job type and worker name from the log line
      -- Example format: [JobCompleted],name,Carpenter,type,Carpenter,worker,Urist McCarpenter
      local jobType = job.data.job_name or "unknown"
      local worker = job.data.job_unit.name or {name = "unknown"}
      -- Count job types
      jobTypeCount[jobType] = (jobTypeCount[jobType] or 0) + 1
      -- Count jobs per worker
      workerCount[worker] = (workerCount[worker] or 0) + 1
      -- Track job types by worker
      jobsByWorker[worker] = jobsByWorker[worker] or {}
      jobsByWorker[worker][jobType] = (jobsByWorker[worker][jobType] or 0) + 1
      ::continueJobs::
   end

    return {
        JobTypeCount = jobTypeCount,
        WorkerCount = workerCount,
        JobsByWorker = jobsByWorker,
        DiggingCountByWorker = diggingCountByWorker,
        SmoothStoneCountByWorker = smoothStoneCountByWorker,
        EncraveCountByWorker = encraveCountByWorker
    }

    
end

function LogParser.printJobInfo(jobInfo)
    print("\nMost common job types:")
    for _, pair in ipairs(LogParser.getTopN(jobInfo.JobTypeCount, 10)) do
        print(pair[1] .. ": " .. pair[2])
    end

    print("\nMost active workers:")
    for _, pair in ipairs(LogParser.getTopN(jobInfo.WorkerCount, 10)) do
        print(pair[1] .. ": " .. pair[2])
    end

    print("\nJob types by worker:")
    for worker, jobs in pairs(jobInfo.JobsByWorker) do
        print(worker .. ":")
        for _, pair in ipairs(LogParser.getTopN(jobs, 10)) do
            print("  " .. pair[1] .. ": " .. pair[2])
        end
    end
end

function LogParser.analyzeItems(itemCreatedLines, yearFilter)
   local itemTypeCount = {}
   local creatorCount = {}
   local itemsByCreator = {}
   local masterworkCount = 0
   local masterworks = {}
   local artifacts = {}
   local allItems = {}
   local uniqueCount = 0
   local masterworkMaterialTypes = {}

   for _, item in ipairs(itemCreatedLines) do
      if yearFilter and tostring(item.date.year) ~= tostring(yearFilter) then
        goto continueItems
      end


      table.insert(allItems, item)
      local itemType = item.data.item_type or "unknown"
      local creator = item.data.maker or "unknown"
      local quality = item.data.quality or ""
      local name = item.data.name or "(unnamed)"

      -- Count item types
      itemTypeCount[itemType] = (itemTypeCount[itemType] or 0) + 1

      -- Count items per creator
      creatorCount[creator] = (creatorCount[creator] or 0) + 1

      -- Track item types by creator
      itemsByCreator[creator] = itemsByCreator[creator] or {}
      itemsByCreator[creator][itemType] = (itemsByCreator[creator][itemType] or 0) + 1

      -- Count masterwork items (quality == '5') and collect their names
      if quality == 5 then
         masterworkCount = masterworkCount + 1
         table.insert(masterworks, item)
      end

      -- Collect artifacts
      if item.data.is_artifact == true then
         table.insert(artifacts, item)
      end

      table.insert(allItems, item)

      ::continueItems::
   end

   -- gather masterwork creator info and sort by most masterworks created
   local uniqueMasterworkNames = {}
   local masterworkCreators = {}
   local numberOfMasterWorkCreators = 0
   for _, item in ipairs(masterworks) do
      local creator = item.data.maker.name or "unknown"
      masterworkCreators[creator] = (masterworkCreators[creator] or 0) + 1
      -- gather material types of masterworks and count them
      local material = MaterialHelper.typeInfoByItemId(item.data.item_id) or "unknown"
      if masterworkMaterialTypes[material] then
         masterworkMaterialTypes[material] = masterworkMaterialTypes[material]  + 1
      else
         masterworkMaterialTypes[material] = 1
      end
      

      -- track unique masterwork names and count how many unique masterwork creators there are
      if not uniqueMasterworkNames[item.data.item_name] then
         uniqueMasterworkNames[item.data.item_name] = 1
         numberOfMasterWorkCreators = numberOfMasterWorkCreators + 1
         uniqueCount = uniqueCount + 1
      else
         uniqueMasterworkNames[item.data.item_name] = uniqueMasterworkNames[item.data.item_name] + 1
      end

   end
   local sortedMasterworkCreators = LogParser.getTopN(masterworkCreators, #masterworkCreators)




   return {
      ItemTypeCount = itemTypeCount,
      CreatorCount = creatorCount,
      ItemsByCreator = itemsByCreator,
      MasterworkCount = masterworkCount,
      Masterworks = masterworks,
      Artifacts = artifacts,
      AllItems = allItems,
      MasterworkCreators = masterworkCreators,
      UniqueMasterworkNames = uniqueMasterworkNames,
      MasterworkMaterialTypes = masterworkMaterialTypes,
      UniqueCount = uniqueCount

   }



end

function LogParser.printItemCreatedInformation(itemInfo)
   print("Number of masterwork items (quality 5): " .. itemInfo.MasterworkCount)
   if itemInfo.MasterworkCount > 0 then
      print("Names of masterwork items:")
      for _, item in ipairs(itemInfo.Masterworks) do
         print("  " .. item.data.item_name)
      end
   end
   print("\nTop 10 most common item types:")
   for _, pair in ipairs(LogParser.getTopN(itemInfo.ItemTypeCount, 10)) do
      print(pair[1] .. ": " .. pair[2])
   end

   print("\nTop 10 most active creators:")
   for _, pair in ipairs(LogParser.getTopN(itemInfo.CreatorCount, 10)) do
      print(pair[1] .. ": " .. pair[2])
   end

   print("\nTop 10 creators and their top item types:")
   local topCreators = LogParser.getTopN(itemInfo.CreatorCount, 10)
   for _, pair in ipairs(topCreators) do
      local creator = pair[1]
      local topItems = LogParser.getTopN(itemInfo.ItemsByCreator[creator], 1)
      for _, itemPair in ipairs(topItems) do
         print(creator .. ": " .. itemPair[1] .. ": " .. itemPair[2])
      end
   end
end


local parsedLists = nil

function LogParser.parseAll()
   local logLines = logHandler.readAllLogLines()
   parsedLists = LogParser.parseLogLinesByType(logLines)
   return parsedLists
end

function LogParser.getYears()
   return parsedLists.Years
end

local parsedLists = LogParser.parseAll()
local itemInfo = LogParser.analyzeItems(parsedLists.ItemCreated, 103)
local jobInfo = LogParser.analyzeJobs(parsedLists.JobCompleted, 103)

LogParser.printItemCreatedInformation(itemInfo)
LogParser.printJobInfo(jobInfo)
print("Citizens born in year 102: ".. #LogParser.analyzeCitizens(parsedLists.Citizens, 102).NewCitizens)
print("Citizens born in year 103: ".. #LogParser.analyzeCitizens(parsedLists.Citizens, 103).NewCitizens)
print("Citizens born in year 104: ".. #LogParser.analyzeCitizens(parsedLists.Citizens, 104).NewCitizens)
print("Citizens born in year 105: ".. #LogParser.analyzeCitizens(parsedLists.Citizens, 105).NewCitizens)

print("Dwarf deaths in year 102: ".. #LogParser.analyzeUnitDeaths(parsedLists.UnitDeath, 102).DwarfDeaths)
print("Dwarf deaths in year 103: ".. #LogParser.analyzeUnitDeaths(parsedLists.UnitDeath, 103).DwarfDeaths)
print("Dwarf deaths in year 104: ".. #LogParser.analyzeUnitDeaths(parsedLists.UnitDeath, 104).DwarfDeaths)
print("Dwarf deaths in year 105: ".. #LogParser.analyzeUnitDeaths(parsedLists.UnitDeath, 105).DwarfDeaths)

local deaths = LogParser.analyzeUnitDeaths(parsedLists.UnitDeath,104)
for _, death in ipairs(deaths.DwarfDeaths) do
   print("Dwarf death in year 104: " .. death.name .. " cause: " .. death.death_cause)
end


return LogParser