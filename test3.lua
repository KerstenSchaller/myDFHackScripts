

local gui = require('gui')
local widgets = require('gui.widgets')
local dfhack = require('dfhack')

local logo_textures1 = dfhack.textures.loadTileset('hack/data/art/logo.png', 8, 12, true)

local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/'
package.path = script_dir .. '?.lua;' .. script_dir .. '?/init.lua;' .. package.path

local LogParser = require('LogParser')
local CurveWidget = require('CurveWidget')

local view



local WindowWidth = 85
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
--local years = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20"}


local longInitText = ""
-- fill longInitText with a very long string to test scrolling	
for i = 1, 100 do
	longInitText = longInitText .. "This is line " .. i ..'------------------------------------------------------' .."\n"
end




function addTokenisedText(tokens, text, fgColor, gap, setLineBreak)
	local token = {
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
	local citizenChanges = LogParser.analyzeCitizens(parsedLogs.Citizens, year)
	local str1=string.format("The fortress gained %d new citizens.", #citizenChanges.NewCitizens)
	addTokenisedText(tokens, str1, COLOR_GREEN, 4, true)
	addLinebreak(tokens)

	-- list new citizens
	local unitDeaths = LogParser.analyzeUnitDeaths(parsedLogs.UnitDeath, year)
	local str2=string.format("The dwarves lost %d of their kind.", #unitDeaths.DwarfDeaths)
	addTokenisedText(tokens, str2, COLOR_MAGENTA, 4, true)
	addLinebreak(tokens)

	--list item info
	local itemInfo = LogParser.analyzeItems(parsedLogs.ItemCreated, year)
	local str3=string.format("The dwarves created %d items,", #itemInfo.AllItems)
	addTokenisedText(tokens, str3, COLOR_YELLOW, 4, true)
	local str4=string.format("of which %d were masterwork and %d were artifacts.", itemInfo.MasterworkCount, #itemInfo.Artifacts)
	addTokenisedText(tokens, str4, COLOR_YELLOW, 4, true)
	addLinebreak(tokens)

	return tokens
end


function createPopulationPageText(year)
	local tokens = {}
	addTokenisedText(tokens, "Population details for year " .. (year or "All") .. ":", COLOR_WHITE, 0, true)
	addLinebreak(tokens)

	local citizenChanges = LogParser.analyzeCitizens(parsedLogs.Citizens, year)
	local unitDeaths = LogParser.analyzeUnitDeaths(parsedLogs.UnitDeath, year)

	-- list new citizens
	addTokenisedText(tokens, string.format("New citizens: %d", #citizenChanges.NewCitizens), COLOR_GREEN, 4, true)
	for _, citizen in ipairs(citizenChanges.NewCitizens) do
		local age = citizen.age
		age = age:match("^([^.]+)") or age
		local text = string.format("%s, a %s years old %s %s", citizen.name, age, citizen.sex, citizen.race)
		addTokenisedText(tokens, text, COLOR_GREEN, 8, true)
	end
	addLinebreak(tokens)

	if #unitDeaths.DwarfDeaths > 0 then
		addTokenisedText(tokens, string.format("Dwarf deaths: %d", #unitDeaths.DwarfDeaths), COLOR_MAGENTA, 4, true)
		for _, death in ipairs(unitDeaths.DwarfDeaths) do
			-- age is a float string with . divider, we want to remove the decimal part for display
			local text = string.format("%s, a %s years old %s %s", death.name, "TODO", "TODO", death.race)
			addTokenisedText(tokens, text, COLOR_MAGENTA, 8, true)
		end
	else
		addTokenisedText(tokens, "No dwarf deaths recorded.", COLOR_MAGENTA, 4, true)
	end




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

local PopulationPage = widgets.Panel{
					frame={t=0,l=0},
					autoarrange_subviews=false,
					autoarrange_gap=1,
					subviews={
						widgets.Label{
							view_id='populationLabel',
							frame={t=0,l=0,r=0},
							auto_height=true,
							text_pen = {fg=COLOR_WHITE, bg=COLOR_BLACK},
							text=createPopulationPageText(),
						}
					}
				}

local EconomyPage = widgets.Label{
					frame={t=0,l=0},
					text="Economy page",
				}

local LaborPage = widgets.Label{
					frame={t=0,l=0},
					text="Labor page",
				}

local ArtifactsPage = widgets.Label{
					frame={t=0,l=0},
					text="Artifacts page",
				}

local WarfarePage = widgets.Label{
					frame={t=0,l=0},
					text="Warfare page",
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
	OverviewPage.subviews.overviewLabel:setText(createOverviewPageText(year))
	PopulationPage.subviews.populationLabel:setText(createPopulationPageText(year))

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


::EOF::
