

local gui = require('gui')
local widgets = require('gui.widgets')
local dfhack = require('dfhack')

local logo_textures1 = dfhack.textures.loadTileset('hack/data/art/logo.png', 8, 12, true)

local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/'
package.path = script_dir .. '?.lua;' .. script_dir .. '?/init.lua;' .. package.path

local LogParser = require('LogParser')
local CurveWidget = require('CurveWidget')
local Helper = require('Helper')
local DeathHelper = require('DeathHelper')

local view



local WindowWidth = 120
local WindowHeight = 40
local WindowPosLeft = 40
local WindowPosTop = 13



StatsWindow = defclass(StatsWindow, widgets.Window)
StatsWindow.ATTRS {
	frame_title = 'The Fortress Chronicle',
	frame={w=WindowWidth, h=WindowHeight, l=WindowPosLeft, t=WindowPosTop},
	autoarrange_subviews = true,
	autoarrange_gap = 1,
	resizable = true,
}



local parsedLogs = LogParser.parseAll()
local years = {"All", table.unpack(LogParser.getYears())}
--local years = {"102", "103", "104", "105", "106"}


local longInitText = ""
-- fill longInitText with a very long string to test scrolling	
for i = 1, 100 do
	longInitText = longInitText .. "This is line " .. i ..'------------------------------------------------------' .."\n"
end


	local citizenChanges = LogParser.analyzeCitizens(parsedLogs.Citizens)
	local announcements = LogParser.analyzeAnnouncements(parsedLogs.Announcement)
	local anualLogs = LogParser.analyzeAnualCitizenList(parsedLogs.AllCitizensAnnualLog)
	local unitDeaths = LogParser.analyzeUnitDeaths(parsedLogs.UnitDeath)
	local itemInfo = LogParser.analyzeItems(parsedLogs.ItemCreated)
	local jobInfos = LogParser.analyzeJobs(parsedLogs.JobCompleted)
	local jobInfos = LogParser.analyzeJobs(parsedLogs.JobCompleted)

function addTokenisedText(tokens, text, fgColor, gap, setLineBreak)
	local token = {
		--text=dfhack.utf2df(text),
		text=text,
		gap=gap or 0,
		pen={fg=fgColor or COLOR_WHITE, bg=COLOR_BLACK},
	}
	table.insert(tokens, token)
	if setLineBreak then
		table.insert(tokens, NEWLINE)
	end
end

function addLinebreak(tokens)
	table.insert(tokens, NEWLINE)
end

function createOverviewPageText(year)
	local title = "In all years of the fortress, in glory or decline:"
	if year then
		title = "In year " .. year .. " of the fortress:"
	end
	local tokens = {}
	addTokenisedText(tokens, title, COLOR_WHITE, 0, true)
	addLinebreak(tokens)
	



	-- new citizens
	local str1=string.format("The fortress gained %d new citizens.", #citizenChanges.NewCitizens)
	addTokenisedText(tokens, str1, COLOR_GREEN, 4, true)
	addLinebreak(tokens)
	--list births
	local str3=string.format("There were %d births recorded.", #announcements.BirthCitizen)
	addTokenisedText(tokens, str3, COLOR_GREEN, 4, true)
	addLinebreak(tokens)
	-- list deaths
	local str2=string.format("The dwarves lost %d of their kind.", #unitDeaths.DwarfDeaths)
	addTokenisedText(tokens, str2, COLOR_MAGENTA, 4, true)
	addLinebreak(tokens)

	--list item info
	local str3=string.format("The dwarves created %d items,", #itemInfo.AllItems)
	addTokenisedText(tokens, str3, COLOR_YELLOW, 4, true)
	local str4=string.format("of which %d were masterwork and %d were artifacts.", itemInfo.MasterworkCount, #itemInfo.Artifacts)
	addTokenisedText(tokens, str4, COLOR_YELLOW, 4, true)
	addLinebreak(tokens)

	--list job info
	local str5=string.format("The dwarves completed %d jobs,", #jobInfos.TotalJobs)
	addTokenisedText(tokens, str5, COLOR_CYAN, 4, true)

	--list digging info
	local str6=string.format("of which %d were digging jobs.", jobInfos.DiggingCount)
	addTokenisedText(tokens, str6, COLOR_CYAN, 4, true)
	addLinebreak(tokens)

	--list marriages and divorces
	local marriages = anualLogs.Marriages
	local divorces = anualLogs.Divorces
	local str7=string.format("There were %d marriages and %d divorces recorded.", #marriages, #divorces)
	addTokenisedText(tokens, str7, COLOR_GREEN, 4, true)


	return tokens
end


function createPopulationPageText(year, index)
	local _index = index or 1
	local tokens = {}
	local title = "In all years of the fortress, in glory or decline:"
	if year then
		title = "In year " .. year .. " of the fortress:"
	end
	addTokenisedText(tokens, title, COLOR_WHITE, 0, true)
	addLinebreak(tokens)


	local marriages = anualLogs.Marriages
	local divorces = anualLogs.Divorces

	if _index == 1 then
		
		-- list new citizens
		addTokenisedText(tokens, string.format("%d citizens joined the fortress.", #citizenChanges.NewCitizens), COLOR_WHITE, 4, true)
		addLinebreak(tokens)
		for _, citizen in ipairs(citizenChanges.NewCitizens) do
			local age = citizen.data.citizen.age
			local color = citizen.data.citizen.sex == "male" and COLOR_CYAN or COLOR_LIGHTMAGENTA
			age = math.floor(age)

			local text = string.format(" a %d years old %s %s joined the fortress", age, citizen.data.citizen.sex, citizen.data.citizen.race)
			addTokenisedText(tokens, "On " .. citizen.date.day.."-"..citizen.date.month.."-"..citizen.date.year, COLOR_WHITE, 8, false)
			addTokenisedText(tokens, dfhack.utf2df(citizen.data.citizen.name), color, 1, false)
			addTokenisedText(tokens, text, COLOR_WHITE, 0, true)
			addLinebreak(tokens)
		end
		addLinebreak(tokens)

	elseif _index == 2 then
		-- list deaths

		if #unitDeaths.DwarfDeaths > 0 then
			addTokenisedText(tokens, string.format("%d citizens perished.", #unitDeaths.DwarfDeaths), COLOR_WHITE, 4, true)
			addLinebreak(tokens)
			for _, death in ipairs(unitDeaths.DwarfDeaths) do
				-- age is a float string with . divider, we want to remove the decimal part for display
				local age = math.floor(death.data.victim.age)
				local color = death.data.victim.sex == "male" and COLOR_CYAN or COLOR_LIGHTMAGENTA
				addTokenisedText(tokens,"On "..death.date.day.."-"..death.date.month.."-"..death.date.year, COLOR_WHITE, 8, false)
				addTokenisedText(tokens, dfhack.utf2df(death.data.victim.name), color, 1, false)
				addTokenisedText(tokens, string.format(" a %d years old %s %s,", age, death.data.victim.sex, death.data.victim.race), COLOR_WHITE, 0, false)
				addTokenisedText(tokens, DeathHelper.getDeathCauseByString(death.data.death_cause), COLOR_WHITE, 0, true)
				
				addTokenisedText(tokens,"killed by ", COLOR_WHITE, 8, false)
				local killer_name = dfhack.utf2df(death.data.killer.name)
				local killeRace = death.data.killer.race
				local killerAge = math.floor(death.data.killer.age)
				local killerSex = death.data.killer.sex == "male" and "male" or "female"

				local killerText = ""
				if killer_name ~= "" then 
					killerText = string.format("%s, a %d years old %s %s.", killer_name, killerAge, killerSex, killeRace)
				else
					killerText = string.format("a %d years old %s %s.", killerAge, killerSex, killeRace)
				end
				addTokenisedText(tokens, killerText, COLOR_WHITE, 0, true)
				addLinebreak(tokens)
				addLinebreak(tokens)
			end
		else
			addTokenisedText(tokens, "No dwarf deaths recorded.", COLOR_GREEN, 4, true)
		end

	elseif _index == 3 then
		-- list births
		local births=announcements.BirthCitizen
		if #births > 0 then
			addTokenisedText(tokens, string.format("%d children were born.", #births), COLOR_WHITE, 4, true)
			addLinebreak(tokens)
			for _, birth in ipairs(births) do
				local mother = Helper.getUnitById(birth.mother_id)
				local father = Helper.getUnitById(birth.father_id)
				local motherAge = mother and math.floor(dfhack.units.getAge(mother)) or "unknown"
				local fatherAge = father and math.floor(dfhack.units.getAge(father)) or "unknown"
				local motherName = mother  and (dfhack.translation.translateName(mother.name)) or "unknown"
				local fatherName = father ~= -1 and (dfhack.translation.translateName(father.name)) or "unknown"
				local genderStr = birth.child.sex == "male" and "boy" or "girl"
				addTokenisedText(tokens,"On " .. birth.date.day.."-"..birth.date.month.."-"..birth.date.year, COLOR_WHITE, 8, false)
				addTokenisedText(tokens, birth.child.name, COLOR_GREEN, 1, false)
				addTokenisedText(tokens, string.format(" a %s %s", birth.child.race,genderStr), COLOR_WHITE, 0, false)
				addTokenisedText(tokens, " was born to the mother ",COLOR_WHITE, 0, false)
				addTokenisedText(tokens, motherName, COLOR_LIGHTMAGENTA, 0, false)
				addTokenisedText(tokens, " (age ".. motherAge ..")", COLOR_WHITE, 0, true)
				addTokenisedText(tokens, "and the father ",COLOR_WHITE, 8, false)
				addTokenisedText(tokens, fatherName, COLOR_CYAN, 0, false)
				addTokenisedText(tokens, " (age ".. fatherAge ..")", COLOR_WHITE, 0, true)

				addLinebreak(tokens)
			end
		else
			addTokenisedText(tokens, "No births recorded.", COLOR_WHITE, 4, true)
		end

	elseif _index == 4 or _index == 5 then --marriages and divorces
		-- list marriages
		local currentMarriages = nil
		local typeStr = ""
		local typeStr2 = ""
		if _index == 4 then
			currentMarriages = marriages
			typeStr = "married"
			typeStr2 = "marriages"
		else
			currentMarriages = divorces
			typeStr = "divorced"
			typeStr2 = "divorces"
		end

		local count = 0
		if #currentMarriages > 0 then
			addLinebreak(tokens)
			for _, marriage in ipairs(currentMarriages) do
				if year ~= tostring(marriage.year) and year ~= nil then
					goto continueMarriage
				end
				count = count + 1
				local unit1 = marriage.unit1
				local unit2 = marriage.unit2
				local color_unit1 = unit1.sex == "male" and COLOR_CYAN or COLOR_LIGHTMAGENTA
				local color_unit2 = unit2.sex == "male" and COLOR_CYAN or COLOR_LIGHTMAGENTA
				local unit1Name = unit1.name
				local unit2Name = unit2.name
				addTokenisedText(tokens,"In " .. marriage.year, COLOR_WHITE, 8, false)
				addTokenisedText(tokens, unit1Name, color_unit1, 1, false)
				addTokenisedText(tokens,",a " .. math.floor(unit1.age) .. " years old ".. unit1.sex .. " " .. unit1.race, COLOR_WHITE, 0, false)
				addTokenisedText(tokens, " " .. typeStr .. " ", COLOR_WHITE, 0, false)
				addTokenisedText(tokens, unit2Name, color_unit2, 0, true)
				addTokenisedText(tokens,",a " .. math.floor(unit2.age) .. " years old ".. unit2.sex .. " " .. unit2.race, COLOR_WHITE, 8, true)
				addLinebreak(tokens)
				::continueMarriage::
			end
			if count == 0 then
				addTokenisedText(tokens, "No " .. typeStr2 .. " recorded in year " .. year .. ".", COLOR_WHITE, 4, true)
			end

		end

		
	elseif _index == 6 then --animals
		local analyzedAnnouncements = LogParser.analyzeAnnouncements(parsedLogs.Announcement, year)
		local births = analyzedAnnouncements.AnimalBirthCountByRace
		local slaughters = analyzedAnnouncements.SlaughterCountByRace
		local starvations = analyzedAnnouncements.StarvationCountByRace
		
		
		-- list animal births by year,
			addTokenisedText(tokens,"Animal births:", COLOR_WHITE, 4, true)
			for race, count in pairs(births) do
				local text = string.format("%d %s were born.", count, race)
				addTokenisedText(tokens, text, COLOR_WHITE, 8, true)
			end
			addLinebreak(tokens)
		-- list slaughters
			addTokenisedText(tokens,"Slaughtered animals:", COLOR_WHITE, 4, true)
			for race, count in pairs(slaughters) do
				local text = string.format("%d %s were slaughtered.", count, race)
				addTokenisedText(tokens, text, COLOR_WHITE, 8, true)
			end
			addLinebreak(tokens)
		-- list starvations
			addTokenisedText(tokens,"Starved animals:", COLOR_WHITE, 4, true)
			for race, count in pairs(starvations) do
				local text = string.format("%d %s starved to death.", count, race)
				addTokenisedText(tokens, text, COLOR_WHITE, 8, true)
			end
			addLinebreak(tokens)
			local tameAnimalDeaths = LogParser.analyzeUnitDeaths(parsedLogs.UnitDeath, year).TameAnimalDeaths
			addTokenisedText(tokens,"Animal deaths:", COLOR_WHITE, 4, true)
			for _, death in ipairs(tameAnimalDeaths) do
				local age = math.floor(death.data.victim.age)
				local race = death.data.victim.race
				local cause = DeathHelper.getDeathCauseByString(death.data.death_cause)
				local text = string.format("A %d years old %s %s,", age, race, cause)
				addTokenisedText(tokens, text, COLOR_WHITE, 8, true)
				------
				addTokenisedText(tokens,"killed by ", COLOR_WHITE, 8, false)
				local killer_name = dfhack.utf2df(death.data.killer.name)
				local killeRace = death.data.killer.race
				local killerAge = math.floor(death.data.killer.age)
				local killerSex = death.data.killer.sex == "male" and "male" or "female"
				local killerText = ""
				if killer_name ~= "" then 
					killerText = string.format("%s, a %d years old %s %s.", killer_name, killerAge, killerSex, killeRace)
				else
					killerText = string.format("a %d years old %s %s.", killerAge, killerSex, killeRace)
				end
				addTokenisedText(tokens, killerText, COLOR_WHITE, 0, true)
				addLinebreak(tokens)
			end

	elseif _index == 7 then --pets
		local petDeaths = LogParser.analyzeUnitDeaths(parsedLogs.UnitDeath, year).PetDeaths
		addTokenisedText(tokens,"Pet deaths:", COLOR_WHITE, 4, true)
		for _, death in ipairs(petDeaths) do
			local age = math.floor(death.data.victim.age)
			local race = death.data.victim.race
			local name = dfhack.utf2df(death.data.victim.name)
			local cause = DeathHelper.getDeathCauseByString(death.data.death_cause)
			local text = string.format("%s, a %d years old %s %s,", name, age, race, cause)
			addTokenisedText(tokens, text, COLOR_WHITE, 8, true)
			------
			addTokenisedText(tokens,"killed by ", COLOR_WHITE, 8, false)
			local killer_name = dfhack.utf2df(death.data.killer.name)
			local killeRace = death.data.killer.race
			local killerAge = math.floor(death.data.killer.age)
			local killerSex = death.data.killer.sex == "male" and "male" or "female"

			local killerText = ""
			if killer_name ~= "" then 
				killerText = string.format("%s, a %d years old %s %s.", killer_name, killerAge, killerSex, killeRace)
			else
				killerText = string.format("a %d years old %s %s.", killerAge, killerSex, killeRace)
			end
			addTokenisedText(tokens, killerText, COLOR_WHITE, 0, true)
			addLinebreak(tokens)
		end
	end

	return tokens
end

function createArtifactsPageText(year)
	local tokens = {}
	local title = "In all years of the fortress, in glory or decline:"
	if year then
		title = "In year " .. year .. " of the fortress:"
	end
	addTokenisedText(tokens, title, COLOR_WHITE, 0, true)
	addLinebreak(tokens)

	local itemInfo = LogParser.analyzeItems(parsedLogs.ItemCreated, year)
	if #itemInfo.Artifacts > 0 then
		for _, artifact in ipairs(itemInfo.Artifacts) do
			local text = string.format("%s, a %s created by %s", dfhack.utf2df(artifact.data.item_descr), dfhack.utf2df(artifact.data.item_name), dfhack.utf2df(artifact.data.maker.name))
			addTokenisedText(tokens, text, COLOR_YELLOW, 4, true)
		end
	else
		addTokenisedText(tokens, "No artifacts recorded.", COLOR_YELLOW, 4, true)
	end

	return tokens
end

function createEconomyPageText(year)
	local tokens = {}
	local title = "In all years of the fortress, in glory or decline:"
	if year then
		title = "In year " .. year .. " of the fortress:"
	end
	addTokenisedText(tokens, title, COLOR_WHITE, 0, true)
	addLinebreak(tokens)
	
	-- list 10 most produced item types
	addTokenisedText(tokens, "Most Produced items:", COLOR_WHITE, 4, true)
	local itemInfo = LogParser.analyzeItems(parsedLogs.ItemCreated, year)
	for _, pair in ipairs(LogParser.getTopN(itemInfo.ItemTypeCount, 10)) do
		local itemType, count = pair[1], pair[2]
		local text = string.format("%s: %d", itemType, count)
		addTokenisedText(tokens, text, COLOR_WHITE, 8, true)
	end
	addLinebreak(tokens)
	
	
	-- list unique masterwork names
	addTokenisedText(tokens, "Masterwork items produced:", COLOR_WHITE, 4, true)
	for _, pair in ipairs(LogParser.getTopN(itemInfo.UniqueMasterworkNames, itemInfo.UniqueCount)) do
		local name, count = pair[1], pair[2]
		local text = string.format("%d %ss ", count, name)
		addTokenisedText(tokens, text, COLOR_WHITE, 8, true)
	end
	addLinebreak(tokens)

	-- list all masterwork material types and their counts
	addTokenisedText(tokens, "Not ready, waits for mat index and mat type to be implemented in items logger", COLOR_RED, 4, true)
	addTokenisedText(tokens,tostring(#itemInfo.MasterworkMaterialTypes).. "Masterwork material types produced:", COLOR_WHITE, 4, true)
	for materialType,count in pairs(itemInfo.MasterworkMaterialTypes) do
		local text = string.format("%s: %d", materialType, count)
		addTokenisedText(tokens, text, COLOR_WHITE, 8, true)
	end
	addLinebreak(tokens)

	--list top masterwork creators
	local masterworkCreators = itemInfo.MasterworkCreators
	addTokenisedText(tokens, string.format("Top Masterwork Creators:"), COLOR_WHITE, 4, true)
	for _, pair in ipairs(LogParser.getTopN(masterworkCreators, 10)) do
		local creator, count = pair[1], pair[2]
		local text = string.format("%s created %d masterworks", dfhack.utf2df(creator), count)
		addTokenisedText(tokens, text, COLOR_WHITE, 8, true)
	end

	return tokens
end

function createLaborPageText(year)
	local tokens = {}
	local title = "In all years of the fortress, in glory or decline:"
	if year then
		title = "In year " .. year .. " of the fortress:"
	end
	addTokenisedText(tokens, title, COLOR_WHITE, 0, true)
	addLinebreak(tokens)

	
	addTokenisedText(tokens, "Most common job types", COLOR_WHITE, 4, true)
	for _, pair in ipairs(LogParser.getTopN(jobInfos.JobTypeCount, 10)) do
		local jobType, count = pair[1], pair[2]
		local text = string.format("%s: %d", jobType, count)
		addTokenisedText(tokens, text, COLOR_WHITE, 8, true)
	end
	addLinebreak(tokens)

	addTokenisedText(tokens,"Most active workers:", COLOR_WHITE, 4, true)
	for _, pair in ipairs(LogParser.getTopN(jobInfos.WorkerCount, 10)) do
		local worker, count = dfhack.utf2df(pair[1]), pair[2]
		local text = string.format("%s: %d jobs", worker, count)
		addTokenisedText(tokens, text, COLOR_WHITE, 8, true)
	end
	addLinebreak(tokens)

	addTokenisedText(tokens,"Best miners:", COLOR_WHITE, 4, true)
	for _, pair in ipairs(LogParser.getTopN(jobInfos.DiggingCountByWorker, 10)) do
		local worker, count = pair[1], pair[2]
		local text = string.format("%s: %d digging jobs", worker, count)
		addTokenisedText(tokens, text, COLOR_WHITE, 8, true)
	end
	addLinebreak(tokens)

	addTokenisedText(tokens,"Best smoothers:", COLOR_WHITE, 4, true)
	for _, pair in ipairs(LogParser.getTopN(jobInfos.SmoothStoneCountByWorker, 10)) do
		local worker, count = pair[1], pair[2]
		local text = string.format("%s: %d smoothing jobs", worker, count)
		addTokenisedText(tokens, text, COLOR_WHITE, 8, true)
	end
	addLinebreak(tokens)

	addTokenisedText(tokens,"Best encravers:", COLOR_WHITE, 4, true)
	for _, pair in ipairs(LogParser.getTopN(jobInfos.EncraveCountByWorker, 10)) do
		local worker, count = pair[1], pair[2]
		local text = string.format("%s: %d encraving jobs", worker, count)
		addTokenisedText(tokens, text, COLOR_WHITE, 8, true)
	end
	addLinebreak(tokens)

	return tokens
end

function createWarfarePageText(year)
	local tokens = {}
	local title = "In all years of the fortress, in glory or decline:"
	if year then
		title = "In year " .. year .. " of the fortress:"
	end
	addTokenisedText(tokens, title, COLOR_WHITE, 0, true)
	addLinebreak(tokens)

	-- not implemented yet, waiting for invasion and battle loggers

	return tokens
end

local OverviewPage = widgets.Panel{
					frame={t=0,l=0},
					autoarrange_subviews=false,
					autoarrange_gap=1,
					subviews={
						widgets.Label{
							view_id='overviewLabel',
							frame={t=0,l=0,r=0},
							auto_height=true,
							text_pen = {fg=COLOR_WHITE, bg=COLOR_BLACK},
							text=createOverviewPageText(),
						}
					}
				}


local popPageIndex = 1
local PopulationPage = widgets.Panel{
					frame={t=0,l=0},
					autoarrange_subviews=false,
					autoarrange_gap=1,
					subviews={
						widgets.Divider{
							frame_style_l=false,
							frame_style_r=false,
							frame={t=1},
						},
						widgets.Label{
							view_id='populationLabel',
							frame={t=2,l=0,r=0},
							auto_height=true,
							text_pen = {fg=COLOR_WHITE, bg=COLOR_BLACK},
							text=createPopulationPageText(nil, popPageIndex),
						}
					}
				}

local JoinedButtonText = "Citizens Joined"
local DiedButtonText = "Citizens Died"
local BornButtonText = "Citizens Born"
local MarriageButtonText = "Marriages"
local DivorceButtonText = "Divorces"
local AnimalButtonText = "Animals"
local PetButtonText = "Pets"
local lIndex = 0

local JoinedButton = widgets.TextButton{
							view_id='Joined',
							frame={l=lIndex,t=0,w=#JoinedButtonText+2,h=1},
							label=JoinedButtonText,
							on_activate=function() 
								popPageIndex = 1
								PopulationPage.subviews.populationLabel:setText(createPopulationPageText(nil, popPageIndex)) 
								self:updateLayout()
							end,
							enabled=true,
						}
lIndex = lIndex + #JoinedButtonText + 3

local DiedButton = widgets.TextButton{
							view_id='Died',
							label=DiedButtonText,
							frame={l=lIndex,t=0,w=#DiedButtonText+2,h=1},
							on_activate=function() 
								popPageIndex = 2
								PopulationPage.subviews.populationLabel:setText(createPopulationPageText(nil, popPageIndex)) 
								self:updateLayout()
							end,
							enabled=true,
						}
lIndex = lIndex + #DiedButtonText + 3


local BornButton = widgets.TextButton{
							view_id='Born',
							frame={l=lIndex,t=0,w=#BornButtonText+2,h=1},
							label=BornButtonText,
							on_activate=function() 
								popPageIndex = 3
								PopulationPage.subviews.populationLabel:setText(createPopulationPageText(nil, popPageIndex)) 
								self:updateLayout()
							end,
							enabled=true,
						}
lIndex = lIndex + #BornButtonText + 3

local MarriageButton = widgets.TextButton{
							view_id='Marriages',
							frame={l=lIndex,t=0,w=#MarriageButtonText+2,h=1},
							label=MarriageButtonText,
							on_activate=function() 
								popPageIndex = 4
								PopulationPage.subviews.populationLabel:setText(createPopulationPageText(nil, popPageIndex)) 
								self:updateLayout()
							end,
							enabled=true,
						}

lIndex = lIndex + #MarriageButtonText + 3

local DivorceButton = widgets.TextButton{
							view_id='Divorces',
							frame={l=lIndex,t=0,w=#DivorceButtonText+2,h=1},
							label=DivorceButtonText,
							on_activate=function() 
								popPageIndex = 5
								PopulationPage.subviews.populationLabel:setText(createPopulationPageText(nil, popPageIndex)) 
								self:updateLayout()
							end,
							enabled=true,
						}
lIndex = lIndex + #DivorceButtonText + 3

local AnimalButton = widgets.TextButton{
							view_id='Animals',
							frame={l=lIndex,t=0,w=#AnimalButtonText+2,h=1},
							label=AnimalButtonText,
							on_activate=function() 
								popPageIndex = 6
								PopulationPage.subviews.populationLabel:setText(createPopulationPageText(nil, popPageIndex)) 
								self:updateLayout()
							end,
							enabled=true,
						}

lIndex = lIndex + #AnimalButtonText + 3

local PetButton = widgets.TextButton{
							view_id='Pets',
							frame={l=lIndex,t=0,w=#PetButtonText+2,h=1},
							label=PetButtonText,
							on_activate=function() 
								popPageIndex = 7
								PopulationPage.subviews.populationLabel:setText(createPopulationPageText(nil, popPageIndex)) 
								dfhack.gui.showAnnouncement("Showing pets", COLOR_CYAN)
								self:updateLayout()
							end,
							enabled=true,
						}


PopulationPage:addviews{JoinedButton, DiedButton, BornButton,MarriageButton, DivorceButton, AnimalButton, PetButton}

local EconomyPage = widgets.Panel{
					frame={t=0,l=0},
					autoarrange_subviews=false,
					autoarrange_gap=1,
					subviews={
						widgets.Label{
							view_id='economyLabel',
							frame={t=0,l=0,r=0},
							auto_height=true,
							text_pen = {fg=COLOR_WHITE, bg=COLOR_BLACK},
							text=createEconomyPageText(),
						}
					}
				}

local LaborPage = widgets.Panel{
					frame={t=0,l=0},
					autoarrange_subviews=false,
					autoarrange_gap=1,
					subviews={
						widgets.Label{
							view_id='laborLabel',
							frame={t=0,l=0,r=0},
							auto_height=true,
							text_pen = {fg=COLOR_WHITE, bg=COLOR_BLACK},
							text=createLaborPageText(),
						}
					}
				}


local ArtifactsPage = widgets.Panel{
					frame={t=0,l=0},
					autoarrange_subviews=false,
					autoarrange_gap=1,
					subviews={
						widgets.Label{
							view_id='artifactsLabel',
							frame={t=0,l=0,r=0},
							auto_height=true,
							text_pen = {fg=COLOR_WHITE, bg=COLOR_BLACK},
							text=createArtifactsPageText(),
						}
					}
				}

local WarfarePage = widgets.Panel{
					frame={t=0,l=0},
					autoarrange_subviews=false,
					autoarrange_gap=1,
					subviews={
						widgets.Label{
							view_id='warfareLabel',
							frame={t=0,l=0,r=0},
							auto_height=true,
							text_pen = {fg=COLOR_WHITE, bg=COLOR_BLACK},
							text=createWarfarePageText(),
						}
					}
				}

local contentPanel = widgets.Panel{
			frame_style=gui.FRAME_INTERIOR,
			frame={t=0,l=7,b=0},
			subviews={				
				widgets.Pages{
					view_id='pages',
					frame={t=0, l=0, b=0, r=0},
					subviews={
						OverviewPage,
						PopulationPage,
						EconomyPage,
						LaborPage,
						ArtifactsPage,
						WarfarePage,
        			},
				
				}
			}
		}

function updatePanels(year)
	if year == "All" then
		year = nil
	end

	citizenChanges = LogParser.analyzeCitizens(parsedLogs.Citizens, year)
	announcements = LogParser.analyzeAnnouncements(parsedLogs.Announcement, year)
	anualLogs = LogParser.analyzeAnualCitizenList(parsedLogs.AllCitizensAnnualLog)
	unitDeaths = LogParser.analyzeUnitDeaths(parsedLogs.UnitDeath, year)
	itemInfo = LogParser.analyzeItems(parsedLogs.ItemCreated, year)
	jobInfos = LogParser.analyzeJobs(parsedLogs.JobCompleted, year)
	jobInfos = LogParser.analyzeJobs(parsedLogs.JobCompleted, year)

	OverviewPage.subviews.overviewLabel:setText(createOverviewPageText(year))
	PopulationPage.subviews.populationLabel:setText(createPopulationPageText(year, popPageIndex))
	EconomyPage.subviews.economyLabel:setText(createEconomyPageText(year))
	ArtifactsPage.subviews.artifactsLabel:setText(createArtifactsPageText(year))
	LaborPage.subviews.laborLabel:setText(createLaborPageText(year))


	self:updateLayout()
end

local yearsPanel = widgets.Panel{
			view_id='yearsPanel',
			frame={t=0,l=0,w=6},
			frame_style=gui.FRAME_INTERIOR,
			subviews={
				widgets.Label{
					frame={t=0,l=0},
					text="Years",
				},
				widgets.Divider{
					frame_style_l=false,
					frame_style_r=false,
					frame={t=1},
				},
				widgets.List{
				view_id='yearList',
				frame={t=3,l=0},
				choices=years,
				on_submit=function(idx, choice)
					updatePanels(choice.text)
				end
				},
			},
		}

local tabBar = widgets.TabBar{
			view_id='tabBar',
			frame={t=0,l=8},
			labels={'Overview', 'Population', 'Economy','Labor', 'Artifacts','Warfare'},
			on_select=function(idx) 
				currentIndex = idx
				contentPanel.subviews.pages:setSelected(idx)
                self:updateLayout()
			 end,
			get_cur_page=function() return contentPanel.subviews.pages:getSelected() end
		}

function StatsWindow:init()



	self:addviews{
		yearsPanel,
		tabBar,
		contentPanel
	}
end



function StatsWindow:onRenderBody(dc)
	self:updateLayout()
	--ZScreen.super.render(self, dc)
end
StatScreen = defclass(StatScreen, gui.ZScreen)
StatScreen.ATTRS {
	focus_path='minimal',
	pass_movement_keys = false,
	pass_mouse_clicks = false,
}

function StatScreen:init()
	self:addviews{StatsWindow{}}
end

-- Show only TestScreen1 initially
--view1 = view1 and view1:raise() or TestScreen1{}:show()
view = view and view:raise() or StatScreen{}:show()
updatePanels("All")


::EOF::
