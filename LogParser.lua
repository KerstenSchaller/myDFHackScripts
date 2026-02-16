

local dfhack = require('dfhack')
local eventful = require('plugins.eventful')

local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/'
package.path = script_dir .. '?.lua;' .. script_dir .. '?/init.lua;' .. package.path

local Helper = require('Helper')
local logHandler = require('LogHandler')
local MaterialHelper = require('MaterialHelper')

local LogParser = {}

function LogParser.splitCommaSeparated(str)
   local result = {}
   for entry in string.gmatch(str, '([^,]+)') do
      table.insert(result, entry)
   end
   return result
end


function LogParser.logItemPartsToTable(parts)
   local joinedPartsString = table.concat(parts, ",", 8)
   local t = {
      date = {
         day = parts[1],
         month = parts[2],
         year = parts[3]
      },
      eventtype = parts[4],
      id = parts[6],
      type = parts[8],
      material = Helper.getValueFromSerializedString(joinedPartsString,"material"),
      name = Helper.getValueFromSerializedString(joinedPartsString,"name"),
      desc = Helper.getValueFromSerializedString(joinedPartsString,"desc"),
      maker = Helper.getValueFromSerializedString(joinedPartsString,"maker"),
      quality = Helper.getValueFromSerializedString(joinedPartsString,"quality"),
      value = Helper.getValueFromSerializedString(joinedPartsString,"value"),
      artifact = Helper.getValueFromSerializedString(joinedPartsString,"artifact"),
   }

   return t
end

-- Converts a split log line for [Announcement] into a structured table with named fields
function LogParser.logAnnouncementPartsToTable(parts)
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
function LogParser.logJobCompletedPartsToTable(parts)
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
function LogParser.logUnitDeathPartsToTable(parts)
   local joinedPartsString = table.concat(parts, ",", 8)
   return {
      date = {
         day = parts[1],
         month = parts[2],
         year = parts[3]
      },
      eventtype = parts[4],
      id = parts[6],
      name = parts[8],
      race = Helper.getValueFromSerializedString(joinedPartsString,"race"),
      death_cause = Helper.getValueFromSerializedString(joinedPartsString,"death_cause"),
      death_type_value = Helper.getValueFromSerializedString(joinedPartsString,"death_type_value"),
      killer = Helper.getValueFromSerializedString(joinedPartsString,"killer"),
      killed_by_citizen = Helper.getValueFromSerializedString(joinedPartsString,"killed_by_citizen"),
      killer_race = Helper.getValueFromSerializedString(joinedPartsString,"killer_race")
   }
end

function LogParser.analyzeUnitDeaths(unitDeathLines, yearFilter)

   local killedByCitizen={}
   local dwarfDeaths = {}
   for _, death in ipairs(unitDeathLines) do
      if yearFilter and tostring(death.date.year) ~= tostring(yearFilter) then
         goto continueDeaths
      end
      if death.killed_by_citizen == "true" then
         table.insert(killedByCitizen,death)
      end
      if death.race == "DWARF" then
         table.insert(dwarfDeaths, death)
      end
      ::continueDeaths::
   end
   
   return {
      KilledByCitizen = killedByCitizen,
      DwarfDeaths = dwarfDeaths
   }
end

-- Converts a split log line for [PetitionChange] into a structured table with key-value pairs
function LogParser.logPetitionChangePartsToTable(parts)
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

function LogParser.LogCitizenPartsToTable(parts)
   local t = {
      date = {
         day = parts[1],
         month = parts[2],
         year = parts[3]
      },
      type = parts[6],
      id = parts[8],
      name = parts[10],
      race = parts[12],
      age = parts[14],
      sex = parts[16]
   }
   return t
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
      local parts = LogParser.splitCommaSeparated(line)
      local msgType = parts[4]
      if msgType == '[Announcement]' then
         table.insert(Announcement, LogParser.logAnnouncementPartsToTable(parts))
      elseif msgType == '[ItemCreated]' then
         table.insert(ItemCreated, LogParser.logItemPartsToTable(parts))
      elseif msgType == '[PetitionChange]' then
         table.insert(PetitionChange, LogParser.logPetitionChangePartsToTable(parts))
      elseif msgType == '[Citizens]' then
         table.insert(Citizens, LogParser.LogCitizenPartsToTable(parts))
      elseif msgType == '[JobCompleted]' then
         table.insert(JobCompleted, LogParser.logJobCompletedPartsToTable(parts))
      elseif msgType == '[UnitDeath]' then
         table.insert(UnitDeath, LogParser.logUnitDeathPartsToTable(parts))
      end

      -- Collect unique years
      local year = parts[3] 
      
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
      if citizen.type == "newcitizen" then
         local citizenInfo = {
            id = citizen.id,
            name = citizen.name,
            race = citizen.race,
            age = citizen.age,
            sex = citizen.sex
         }
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
      if job.name == "Dig" or job.name == "Dig channel" or job.name == "Dig ramp" then
         diggingCountByWorker[job.worker] = (diggingCountByWorker[job.worker] or 0) + 1
         goto continueJobs
      end
      if job.name == "Smooth floor" or job.name == "Smooth wall" then
         smoothStoneCountByWorker[job.worker] = (smoothStoneCountByWorker[job.worker] or 0) + 1
         goto continueJobs
      end
      if job.name == "Detail floor" or job.name == "Detail wall" then
         encraveCountByWorker[job.worker] = (encraveCountByWorker[job.worker] or 0) + 1
         goto continueJobs
      end
      -- skip eat,drink, and sleep jobs to focus on labor jobs
      if job.name == "Eat" or job.name == "Drink" or job.name == "Sleep" then
         goto continueJobs
      end

      -- Example format: [JobCompleted],name,Carpenter,type,Carpenter,worker,Urist McCarpenter
      -- Extract job type and worker name from the log line
      -- Example format: [JobCompleted],name,Carpenter,type,Carpenter,worker,Urist McCarpenter
      local jobType = job.name or "unknown"
      local worker = job.worker or "unknown"
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
         table.insert(masterworks, item)
      end

      -- Collect artifacts
      if item.artifact == "true" then
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
      local creator = item.maker or "unknown"
      masterworkCreators[creator] = (masterworkCreators[creator] or 0) + 1
      -- gather material types of masterworks and count them
      local material = MaterialHelper.typeInfoByItemId(item.id) or "unknown"
      if masterworkMaterialTypes[material] then
         masterworkMaterialTypes[material] = masterworkMaterialTypes[material]  + 1
      else
         masterworkMaterialTypes[material] = 1
      end
      

      -- track unique masterwork names and count how many unique masterwork creators there are
      if not uniqueMasterworkNames[item.name] then
         uniqueMasterworkNames[item.name] = 1
         numberOfMasterWorkCreators = numberOfMasterWorkCreators + 1
         uniqueCount = uniqueCount + 1
      else
         uniqueMasterworkNames[item.name] = uniqueMasterworkNames[item.name] + 1
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
         print("  " .. item.name)
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