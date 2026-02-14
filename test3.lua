

local gui = require('gui')
local widgets = require('gui.widgets')
local dfhack = require('dfhack')

local logo_textures1 = dfhack.textures.loadTileset('hack/data/art/logo.png', 8, 12, true)

local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/'
package.path = script_dir .. '?.lua;' .. script_dir .. '?/init.lua;' .. package.path

local LogParser = require('LogParser')
local CurveWidget = require('CurveWidget')

local view

StatsTextWidget = defclass(StatsTextWidget, widgets.Widget)

local currentIndex = 1

function StatsTextWidget:setCurrentIndex(idx)
	currentIndex = idx
end

function StatsTextWidget:getCurrentIndex()
	return currentIndex
end

function StatsTextWidget:init()
	self:addviews{


			}
end

local WindowWidth = 85
local WindowHeight = 40
local WindowPosLeft = 40
local WindowPosTop = 13



StatsWindow = defclass(StatsWindow, widgets.Window)
StatsWindow.ATTRS {
	frame_title = 'Fortress Statistics',
	frame={w=WindowWidth, h=WindowHeight, l=WindowPosLeft, t=WindowPosTop},
	autoarrange_subviews = true,
	autoarrange_gap = 1,
	resizable = true,
}



LogParser.parseAll()
local years = {"All", table.unpack(LogParser.getYears())}
--local years = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20"}


local longInitText = ""
-- fill longInitText with a very long string to test scrolling	
for i = 1, 100 do
	longInitText = longInitText .. "This is line " .. i ..'------------------------------------------------------' .."\n"
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
					self.subviews.statsTextWidget:setCurrentIndex(idx)
				end
				},
			},
		}


					local tokens = {}
					local token = {
						text="Overview",
						pen = {fg=COLOR_WHITE, bg=COLOR_BLACK},
					}

					local token2 = {
						text="page bla bla",
						gap = 1,
						pen = {fg=COLOR_RED, bg=COLOR_BLACK},
					}

					table.insert(tokens, token)
					table.insert(tokens, token2)



local OverviewPage = widgets.Panel{
					frame={t=0,l=0},
					autoarrange_subviews=false,
					autoarrange_gap=1,



					subviews={
						widgets.Label{
							frame={t=0,l=0,r=0},
							text_pen = {fg=COLOR_WHITE, bg=COLOR_BLACK},
							text=tokens,
						},
						widgets.Label{
							frame={t=3,l=0,r=0},
							text_pen = {fg=COLOR_GREEN, bg=COLOR_BLACK},
							text="Here goes Info about joined or born citizens\n\n\n\n",
						},
						widgets.Label{
							frame={t=6,l=0,r=0},
							text_pen = {fg=COLOR_RED, bg=COLOR_BLACK},
							text="Here goes Info about died citizens",
						},
						widgets.Label{
							frame={t=9,l=0,r=0},
							text_pen = {fg=COLOR_GRAY, bg=COLOR_BLACK},
							text="Here goes Info about created Items",
						},
						widgets.Label{
							frame={t=12,l=0,r=0},
							text_pen = {fg=COLOR_GRAY, bg=COLOR_BLACK},
							text="Here goes Info about labors",
						},
						widgets.Label{
							frame={t=15,l=0,r=0},
							text_pen = {fg=COLOR_GRAY, bg=COLOR_BLACK},
							text="Here goes Info about artifacts",
						},
						widgets.Label{
							frame={t=18	,l=0,r=0},
							text_pen = {fg=COLOR_GRAY, bg=COLOR_BLACK},
							text="Here goes Info about sieges and other combat related stuff",
						},
					}
				}

local PopulationPage = widgets.Label{
					frame={t=0,l=0},
					text="Population page",
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
	--self.subviews.statsTextWidget:setCurrentIndex(currentIndex)
	self:updateLayout()
	--ZScreen.super.render(self, dc)
end
StatScreen = defclass(StatScreen, gui.ZScreen)
StatScreen.ATTRS {
	focus_path='minimal',
	pass_movement_keys = true,
	pass_mouse_clicks = false,
}

function StatScreen:init()
	self:addviews{StatsWindow{}}
end

-- Show only TestScreen1 initially
--view1 = view1 and view1:raise() or TestScreen1{}:show()
view = view and view:raise() or StatScreen{}:show()


::EOF::
