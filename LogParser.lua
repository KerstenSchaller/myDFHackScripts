

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
   local tameAnimalDeaths = {}
   local petDeaths = {}
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
      if death.data.victim.isPet == true then
         table.insert(petDeaths, death)
         goto continueDeaths
      end
      if death.data.victim.isAnimal == true and death.data.victim.isTame == true then
         table.insert(tameAnimalDeaths, death)
      end
      ::continueDeaths::
   end
   
   return {
      KilledByCitizen = killedByCitizen,
      DwarfDeaths = dwarfDeaths,
      TameAnimalDeaths = tameAnimalDeaths,
      PetDeaths = petDeaths
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
   local AllCitizensAnnualLog = {}
   local VisitorsAndOthers = {}

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
      elseif msgType == "AllCitizens" then
         table.insert(AllCitizensAnnualLog, item)
      elseif msgType == "VisitorsAndOthers" then
         table.insert(VisitorsAndOthers, item)
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
      AllCitizensAnnualLog = AllCitizensAnnualLog,
      VisitorsAndOthers = VisitorsAndOthers,
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



function LogParser.analyzeVisitorsAndOthers(visitorLines)
   -- Group logs by year and month
   local logsByYearMonth = {}
   for _, log in ipairs(visitorLines) do
      local year = log.date.year
      local month = log.date.month
      logsByYearMonth[year] = logsByYearMonth[year] or {}
      logsByYearMonth[year][month] = log
   end

   -- Sort years and months
   local sortedYears = {}
   for year in pairs(logsByYearMonth) do table.insert(sortedYears, year) end
   table.sort(sortedYears)

   -- Helper to extract unit data by id from a group (table of units or dict of units)
   local function extractUnitMap(group)
      local map = {}
      if type(group) == 'table' then
         for _, entry in ipairs(group) do
            if entry.id then map[entry.id] = entry end
         end
         for k, v in pairs(group) do
            if type(k) == 'number' and v and v.id then map[v.id] = v end
         end
      end
      return map
   end

   -- Track first seen and last seen
   local firstSeen = {merchants = {}, guests = {}, ghosts = {}, animals = {}, pets = {}}
   local lastSeen = {merchants = {}, guests = {}, ghosts = {}, animals = {}, pets = {}}
   local unitData = {merchants = {}, guests = {}, ghosts = {}, animals = {}, pets = {}}

   -- Track who is present in the previous month
   local prevPresent = {merchants = {}, guests = {}, ghosts = {}, animals = {}, pets = {}}

   for _, year in ipairs(sortedYears) do
      local months = logsByYearMonth[year]
      local sortedMonths = {}
      for m in pairs(months) do table.insert(sortedMonths, m) end
      table.sort(sortedMonths)
      for _, month in ipairs(sortedMonths) do
         local log = months[month]
         local data = log.data or {}
         -- Get unit maps
         local merchantMap = extractUnitMap(data.merchants or {})
         local guestMap = extractUnitMap(data.guests or {})
         local ghostMap = extractUnitMap(data.ghosts or {})
         local animalMap = {}
         local petMap = {}
         -- Animals and pets may be in lifestock (array) or pets (dict/array)
         if type(data.lifestock) == 'table' then
            for _, entry in ipairs(data.lifestock) do
               if entry.id then
                  if entry.isAnimal then
                     animalMap[entry.id] = entry
                  end
                  if entry.isPet then
                     petMap[entry.id] = entry
                  end
               end
            end
         end
         if type(data.pets) == 'table' then
            for _, entry in ipairs(data.pets) do
               if entry.id then petMap[entry.id] = entry end
            end
            for k, v in pairs(data.pets) do
               if type(k) == 'number' and v and v.id then petMap[v.id] = v end
            end
         end

         -- Convert to sets for fast lookup
         local merchantSet, guestSet, ghostSet = {}, {}, {}
         local animalSet, petSet = {}, {}
         for id, entry in pairs(merchantMap) do merchantSet[id] = true end
         for id, entry in pairs(guestMap) do guestSet[id] = true end
         for id, entry in pairs(ghostMap) do ghostSet[id] = true end
         for id, entry in pairs(animalMap) do animalSet[id] = true end
         for id, entry in pairs(petMap) do petSet[id] = true end

         -- Helper to process each type
         local function processType(typeName, map, set)
            for id, entry in pairs(map) do
               if not firstSeen[typeName][id] then
                  firstSeen[typeName][id] = {year = year, month = month}
                  unitData[typeName][id] = entry
               end
               lastSeen[typeName][id] = {year = year, month = month}
               unitData[typeName][id] = entry
            end
            prevPresent[typeName] = set
         end

         processType('merchants', merchantMap, merchantSet)
         processType('guests', guestMap, guestSet)
         processType('ghosts', ghostMap, ghostSet)
         processType('animals', animalMap, animalSet)
         processType('pets', petMap, petSet)
      end
   end

   -- Build sorted lists for each type
   local function buildList(typeName)
      local list = {}
      for id, data in pairs(unitData[typeName]) do
         table.insert(list, {
            id = id,
            data = data,
            FirstSeen = firstSeen[typeName][id],
            LastSeen = lastSeen[typeName][id]
         })
      end
      table.sort(list, function(a, b) return a.id < b.id end)
      return list
   end

   return {
      Merchants = buildList('merchants'),
      Guests = buildList('guests'),
      Ghosts = buildList('ghosts'),
      Animals = buildList('animals'),
      Pets = buildList('pets')
   }
end

function LogParser.analyzeAnualCitizenList(allCitizensAnnualLog)

   -- Group logs by year and month
   local logsByYearMonth = {}
   for _, log in ipairs(allCitizensAnnualLog) do
      local year = log.date.year
      local month = log.date.month
      logsByYearMonth[year] = logsByYearMonth[year] or {}
      logsByYearMonth[year][month] = log
   end

   -- Find the best log for each year: prefer month==0, else lowest month
   local logsByYear = {}
   for year, months in pairs(logsByYearMonth) do
      if months[0] then
         logsByYear[year] = months[0]
      else
         -- Find the lowest month entry for this year
         local minMonth, minLog = nil, nil
         for m, log in pairs(months) do
            if minMonth == nil or m < minMonth then
               minMonth = m
               minLog = log
            end
         end
         logsByYear[year] = minLog
      end
   end

   -- Sort years ascending
   local sortedYears = {}
   for year in pairs(logsByYear) do table.insert(sortedYears, year) end
   table.sort(sortedYears)



   -- Helper: build a map of unit_id -> spouse_id for a log
   local function getMarriagesMap(log)
      local marriages = {}
      for _, unit in ipairs(log.data) do
         if unit.spouseId and unit.spouseId and unit.spouseId ~= -1 then
            --print("Found marriage in log: Unit " .. unit.id .. " is married to " .. unit.spouseId)
            marriages[unit.id] = unit.spouseId
         end
      end
      return marriages
   end

   -- Find marriages and divorces by comparing subsequent logs
   local marriages = {}
   local divorces = {}
   for i = 2, #sortedYears do
      local prevLog = logsByYear[sortedYears[i-1]]
      local currLog = logsByYear[sortedYears[i]]
      local prevMarriages = getMarriagesMap(prevLog)
      local currMarriages = getMarriagesMap(currLog)
      -- Marriages: For each unit in curr, if they have a spouse now but not before, it's a new marriage
      for unit_id, spouse_id in pairs(currMarriages) do
         if (not prevMarriages[unit_id] or prevMarriages[unit_id] ~= spouse_id) and spouse_id ~= -1 then
            -- Only add if the spouse reciprocates
            if currMarriages[spouse_id] == unit_id then
               -- Avoid duplicates (A,B) and (B,A)
               local key = tostring(math.min(unit_id, spouse_id)) .. '-' .. tostring(math.max(unit_id, spouse_id))
               if not marriages[key] then
                  marriages[key] = {
                     year = sortedYears[i],
                     unit1 = unit_id,
                     unit2 = spouse_id,
                  }
               end
            end
         end
      end
      -- Divorces: For each unit in prev, if they had a spouse before but not now, it's a divorce
      for unit_id, spouse_id in pairs(prevMarriages) do
         if spouse_id ~= -1 and (not currMarriages[unit_id] or currMarriages[unit_id] ~= spouse_id) then
            -- Only add if the spouse reciprocates in prev, and both are now not married to each other
            if prevMarriages[spouse_id] == unit_id and (not currMarriages[spouse_id] or currMarriages[spouse_id] ~= unit_id) then
               local key = tostring(math.min(unit_id, spouse_id)) .. '-' .. tostring(math.max(unit_id, spouse_id))
               if not divorces[key] then
                  print("Found divorce between " .. unit_id .. " and " .. spouse_id .. " in year " .. sortedYears[i])
                  divorces[key] = {
                     year = sortedYears[i],
                     unit1 = unit_id,
                     unit2 = spouse_id,
                  }
               end
            end
         end
      end
   end

   -- If only one year is available, try to use a mid-year entry as the previous log
   if #sortedYears == 1 then
      local onlyYear = sortedYears[1]
      local months = logsByYearMonth[onlyYear]
      if months then
         local monthList = {}
         for m in pairs(months) do table.insert(monthList, m) end
         table.sort(monthList)
         for i = 2, #monthList do
            local prevLog = months[monthList[i-1]]
            local currLog = months[monthList[i]]
            local prevMarriages = getMarriagesMap(prevLog)
            local currMarriages = getMarriagesMap(currLog)
            -- Marriages
            for unit_id, spouse_id in pairs(currMarriages) do
               if (not prevMarriages[unit_id] or prevMarriages[unit_id] ~= spouse_id) and spouse_id ~= -1 then
                  if currMarriages[spouse_id] == unit_id then
                     local key = tostring(math.min(unit_id, spouse_id)) .. '-' .. tostring(math.max(unit_id, spouse_id))
                     if not marriages[key] then
                        marriages[key] = {
                           year = onlyYear,
                           month = monthList[i],
                           unit1 = unit_id,
                           unit2 = spouse_id,
                        }
                     end
                  end
               end
            end
            -- Divorces
            for unit_id, spouse_id in pairs(prevMarriages) do
               if spouse_id ~= -1 and (not currMarriages[unit_id] or currMarriages[unit_id] ~= spouse_id) then
                  if prevMarriages[spouse_id] == unit_id and (not currMarriages[spouse_id] or currMarriages[spouse_id] ~= unit_id) then
                     local key = tostring(math.min(unit_id, spouse_id)) .. '-' .. tostring(math.max(unit_id, spouse_id))
                     if not divorces[key] then
                        divorces[key] = {
                           year = onlyYear,
                           month = monthList[i],
                           unit1 = unit_id,
                           unit2 = spouse_id,
                        }
                     end
                  end
               end
            end
         end
      end
   end

   -- Convert marriages to list
   local marriageList = {}
   for _, m in pairs(marriages) do
      local unit1 = Helper.parseUnit(Helper.getUnitById(m.unit1))
      local unit2 = Helper.parseUnit(Helper.getUnitById(m.unit2))
      local updatedMarriage = {
         year = m.year,
         month = m.month or 0,
         unit1 = unit1,
         unit2 = unit2
      }
      table.insert(marriageList, updatedMarriage)
   end

   -- Convert divorces to list
   local divorceList = {}
   for _, d in pairs(divorces) do
      local unit1 = Helper.parseUnit(Helper.getUnitById(d.unit1))
      local unit2 = Helper.parseUnit(Helper.getUnitById(d.unit2))
      local updatedDivorce = {
         year = d.year,
         month = d.month or 0,
         unit1 = unit1,
         unit2 = unit2
      }
      table.insert(divorceList, updatedDivorce)
   end

   return {
      Marriages = marriageList,
      Divorces = divorceList
   }
end

function LogParser.analyzeCitizens(citizenLines, yearFilter)
   local newCitzens = {}

   for _, citizen in ipairs(citizenLines) do
      if yearFilter and tostring(citizen.date.year) ~= tostring(yearFilter) then
         goto continueCitizens
      end

      -- check for new citizens and collect their info
      if citizen.data.type == "newcitizen" then
         local citizenInfo = citizen
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
   local diggingCount = 0
   local smoothStoneCountByWorker = {}
   local encraveCountByWorker = {}
   local totalJobs = {}

   for _, job in ipairs(jobCompletedLines) do
      if yearFilter and tostring(job.date.year) ~= tostring(yearFilter) then
         goto continueJobs
      end
      table.insert(totalJobs, job)
      if job.data.job_name == "Dig" or job.data.job_name == "Dig channel" or job.data.job_name == "Dig ramp" then
         diggingCountByWorker[job.data.job_unit.name] = (diggingCountByWorker[job.data.job_unit.name] or 0) + 1
         diggingCount = diggingCount + 1
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
        DiggingCount = diggingCount,
        SmoothStoneCountByWorker = smoothStoneCountByWorker,
        EncraveCountByWorker = encraveCountByWorker,
        TotalJobs = totalJobs
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



   -- getNameFromBirthAnnouncement(input, delimiter, getBefore)
   -- input: string or announcement object
   -- delimiter: string to search for (default ",")
   -- getBefore: if true (default), return before delimiter; if false, return after delimiter
   function getNameFromBirthAnnouncement(input, delimiter, getBefore)
      local text = input
      if type(input) == 'table' and input.data and input.data.text then
         text = input.data.text
      end
      delimiter = delimiter or ','
      if not text then return 'unknown' end
      local pattern
      if getBefore == false then
         -- Get after delimiter
         pattern = delimiter == '' and '^()$' or delimiter .. '%s*(.*)'
         local after = string.match(text, pattern)
         return after or 'unknown'
      else
         -- Get before delimiter
         pattern = '^(.-)' .. delimiter
         local before = string.match(text, pattern)
         return before or 'unknown'
      end
   end


function LogParser.analyzeAnnouncements(announcementLines, yearFilter)
   local announcementTypeCount = {}
   local BirthCitizen = {}
   local slaughters = {}
   local starvings = {}
   local animalsBorn = {}
   for _, announcement in ipairs(announcementLines) do
      if yearFilter and tostring(announcement.date.year) ~= tostring(yearFilter) then
         goto continueAnnouncements
      end
      local announcementType = announcement.data.type or "unknown"
      local typestr = df.announcement_type[announcementType].." "..tostring(announcementType)
      announcementTypeCount[typestr] = (announcementTypeCount[typestr] or 0) + 1

      --parse births
      if announcement.data.type == df.announcement_type.BIRTH_CITIZEN then
         local mother = Helper.getUnitByName(getNameFromBirthAnnouncement(announcement,',', true))
         local unit_born = Helper.getUnitByMotherId(mother and mother.id or -1)
         table.insert(BirthCitizen, {
            date = announcement.date,
            mother_id = mother and mother.id or -1,
            child = Helper.parseUnit(unit_born),
            father_id = unit_born and unit_born.relationship_ids.Father or -1,
         })
         goto continueAnnouncements
      end
      -- parse animal births
      if announcement.data.type == df.announcement_type.BIRTH_ANIMAL then
         -- if text does not contain (tame) continue
         if not string.find(announcement.data.text, "%(tame%)") then
            --goto continueAnnouncements
         end
         local mother = getNameFromBirthAnnouncement(announcement,' has given birth to a ', true)
         local animal_born = getNameFromBirthAnnouncement(announcement,' has given birth to a ', false)
         table.insert(animalsBorn, {
            date = announcement.date,
            mother=mother or "unknown",
            child = Helper.removeStringFromString(animal_born, "%.") or "unknown"
         })
         goto continueAnnouncements
      end

      --parse pet deats (slaughters and starvations)
      if announcement.data.type == df.announcement_type.PET_DEATH then
         if string.find(announcement.data.text, " has been slaughtered.") then
            local name = string.match(announcement.data.text, "^(.-) has been slaughtered.")
            name = Helper.removeStringFromString(name, " %(Tame%)")
            name = Helper.removeStringFromString(name, "The ")
            name = Helper.removeStringFromString(name, "Stray ")
            
            table.insert(slaughters, {
               date = announcement.date,
               name = name or announcement.data.text
            })
            goto continueAnnouncements
         end
         
         if string.find(announcement.data.text, " has been found, starved to death.") then
            local name = string.match(announcement.data.text, "^(.-) has been found, starved to death.")
            name = Helper.removeStringFromString(name, " %(Tame%)")
            name = Helper.removeStringFromString(name, "The ")
            name = Helper.removeStringFromString(name, "Stray ")

            table.insert(starvings, {
               date = announcement.date,
               name = name or announcement.data.text
            })
            goto continueAnnouncements
         end
      end

      ::continueAnnouncements::
   end

   --animalCounter per race
   local animalBirthCountByRace = {}
   for _, animal in ipairs(animalsBorn) do
      local race = animal.child
      if race then
         animalBirthCountByRace[race] = (animalBirthCountByRace[race] or 0) + 1
      end
   end



    --parse slaughters per race
    local slaughtersByRace = {}
      for _, slaughter in ipairs(slaughters) do
         local race = slaughter.name
         if race then
            slaughtersByRace[race] = (slaughtersByRace[race] or 0) + 1
         end
      end

      --starvarion deaths per race
      local starvationsByRace = {}
      for _, starvation in ipairs(starvings) do
         local race = starvation.name
         if race then
            starvationsByRace[race] = (starvationsByRace[race] or 0) + 1
         end
      end

   return {
      AnnouncementTypeCount = announcementTypeCount,
      BirthCitizen = BirthCitizen,
      Slaughters = slaughters,
      AnimalsBorn = animalsBorn,
      AnimalBirthCountByRace = animalBirthCountByRace,
      SlaughterCountByRace = slaughtersByRace,
      StarvationCountByRace = starvationsByRace
   }
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



for id, slaughter in pairs(LogParser.analyzeAnnouncements(parsedLists.Announcement).Slaughters) do
   print(slaughter.date.day.."-"..slaughter.date.month.."-"..slaughter.date.year.." Slaughter announcement: " .. slaughter.name)
end

for id, animal in pairs(LogParser.analyzeAnnouncements(parsedLists.Announcement).AnimalsBorn) do
   print(animal.date.day.."-"..animal.date.month.."-"..animal.date.year.." Animal birth announcement: " .. animal.child .. " born to " .. animal.mother)
end

-- animal and pet deaths
local deathSummary = LogParser.analyzeUnitDeaths(parsedLists.UnitDeath)
print("\nUnit Death Summary:")
local animalDeaths = deathSummary.TameAnimalDeaths
local petDeaths = deathSummary.PetDeaths
for _, death in ipairs(animalDeaths) do
   print("Tame animal death: " .. death.data.victim.race .. " on " .. death.date.day .. "-" .. death.date.month .. "-" .. death.date.year)
end
for _, death in ipairs(petDeaths) do
   print("Pet death: " .. death.data.victim.name .. " a " .. death.data.victim.race .. " on " .. death.date.day .. "-" .. death.date.month .. "-" .. death.date.year)
end

--print arrival and departure summary of visitors and others
local summary = LogParser.analyzeVisitorsAndOthers(parsedLists.VisitorsAndOthers)
print("\nVisitors and Others Arrival and Departure Summary:")
for _, merchant in ipairs(summary.Merchants) do
   print("Merchant " .. merchant.data.name .. " first seen: " .. merchant.FirstSeen.year .. "-" .. merchant.FirstSeen.month .. " last seen: " .. merchant.LastSeen.year .. "-" .. merchant.LastSeen.month)
end
print("")
print("")
for _, guest in ipairs(summary.Guests) do
   print("Guest " .. guest.data.name .. " first seen: " .. guest.FirstSeen.year .. "-" .. guest.FirstSeen.month .. " last seen: " .. guest.LastSeen.year .. "-" .. guest.LastSeen.month)
end
print("")
print("")

for _, ghost in ipairs(summary.Ghosts) do
   print("Ghost " .. ghost.data.id .. " first seen: " .. ghost.FirstSeen.year .. "-" .. ghost.FirstSeen.month .. " last seen: " .. ghost.LastSeen.year .. "-" .. ghost.LastSeen.month)
end

print("")
print("")
for _, animal in ipairs(summary.Animals) do
   print("Animal " .. animal.data.race .. " first seen: " .. animal.FirstSeen.year .. "-" .. animal.FirstSeen.month .. " last seen: " .. animal.LastSeen.year .. "-" .. animal.LastSeen.month)
end

for _, pet in ipairs(summary.Pets) do
   print("Pet " .. pet.data.name .." a " .. pet.data.race .. " first seen: " .. pet.FirstSeen.year .. "-" .. pet.FirstSeen.month .. " last seen: " .. pet.LastSeen.year .. "-" .. pet.LastSeen.month)
end

--list births 
for id, slaughter in pairs(LogParser.analyzeAnnouncements(parsedLists.Announcement).AnimalBirthCountByRace) do
   print("Animal birth count for race " .. id .. ": " .. slaughter)
end
--list slaughters
for id, slaughter in pairs(LogParser.analyzeAnnouncements(parsedLists.Announcement).SlaughterCountByRace) do
   print("Slaughter count for race " .. id .. ": " .. slaughter)
end
--list starvations
for id, starvation in pairs(LogParser.analyzeAnnouncements(parsedLists.Announcement).StarvationCountByRace) do
   print("Starvation death count for race " .. id .. ": " .. starvation)
end

--divorves
local marriageInfo = LogParser.analyzeAnualCitizenList(parsedLists.AllCitizensAnnualLog)
print("\nMarriages:")
for _, marriage in ipairs(marriageInfo.Marriages) do
   print("Marriage in year " .. marriage.year .. ": " .. marriage.unit1.name .. " and " .. marriage.unit2.name)
end

for _, divorce in ipairs(marriageInfo.Divorces) do
   print("Divorce in year " .. divorce.year .. ": " .. divorce.unit1.name .. " and " .. divorce.unit2.name)
end


return LogParser