

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

local currentV = 1
function StatsWindow:onScrollbar(scroll_spec)

	local v = 0
    if tonumber(scroll_spec) then
        v = scroll_spec - self.page_top
    elseif scroll_spec == 'down_large' then
        v = math.ceil(self.page_size / 2)
    elseif scroll_spec == 'up_large' then
        v = -math.ceil(self.page_size / 2)
    elseif scroll_spec == 'down_small' then
        v = 1
    elseif scroll_spec == 'up_small' then
        v = -1
    end
    currentV = currentV + v

	
	dfhack.gui.showAnnouncement("height: " .. self.frame_body.height.. " render_start_line: " .. render_start_line.. " scroll_spec: " .. scroll_spec, COLOR_LIGHTGREEN)
	self.scrollbar:update(
        currentV,
        5,
        60
    )
	self:updateLayout()
end

function StatsWindow:init()

	local longInitText = ""
	-- fill longInitText with a very long string to test scrolling	
	for i = 1, 100 do
		longInitText = longInitText .. "This is line " .. i ..'------------------------------------------------------' .."\n"
	end

	self:addviews{

		widgets.Panel{
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
			
			
		},
		widgets.TabBar{
			view_id='tabBar',
			frame={t=0,l=8},
			labels={'Overview', 'Population', 'Economy','Labor', 'Artifacts','Warfare'},
			on_select=function(idx) currentIndex = idx end,
			get_cur_page=function() return currentIndex end
		},		
		widgets.Panel{
			frame_style=gui.FRAME_INTERIOR,
			frame={t=3,l=7,b=0},
			subviews={
				

				
				--[[
				CurveWidget{
					view_id='curve',
					frame={t=3, l=3, h=26, w=54},
					pen={fg=COLOR_GREEN, bg=COLOR_BLACK},
					years={4,8,12,16,20,24,28,32,36,40,44,48,52,56,60,64,68,72,76,80},
					values={0,1,2,3,4,5,6,7,8,9,10,9,8,7,6,5,4,3,2,1,0,1,2,3,4,5,6,7,8,9,10},
					title="Example Stats",
				},
				
				widgets.Label{
					view_id='statsTextWidget',
					frame={t=0,l=0,w=WindowWidth-7,h=WindowHeight-5},
					text=longInitText,
				},
				--]]
				widgets.Scrollbar{
					view_id='scrollbar',
					frame={r=0},
					on_scroll=self:callback('onScrollbar'),
					visible=true,
				},
				
			}
		}
	}
	self.subviews.scrollbar:update(0, 5, 60)

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
