

local gui = require('gui')
local widgets = require('gui.widgets')
local dfhack = require('dfhack')

local logo_textures1 = dfhack.textures.loadTileset('hack/data/art/logo.png', 8, 12, true)

local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/'
package.path = script_dir .. '?.lua;' .. script_dir .. '?/init.lua;' .. package.path

local LogParser = require('LogParser')

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
		widgets.Label{
			view_id='statsPageLabel',
			frame={t=0,l=0},
			text="Stats Text Widget "..tostring(currentIndex),
		},
	}
end

function StatsTextWidget:onRenderBody(dc)
	self.subviews.statsPageLabel:setText("Stats Text Widget "..tostring(currentIndex))
	self:updateLayout()
end

StatsWindow = defclass(StatsWindow, widgets.Window)
StatsWindow.ATTRS {
	frame_title = 'Test Window 2',
	frame={w=80, h=40, l=40, t=13},
	autoarrange_subviews = true,
	autoarrange_gap = 1,
	resizable = true,
}



LogParser.parseAll()
local years = LogParser.getYears()
--local years = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20"}


function StatsWindow:init()
	self:addviews{
		widgets.TabBar{
            labels=years,
            on_select=function(idx)
					currentIndex = idx
					StatsTextWidget:setCurrentIndex(idx)
					self:updateLayout()
				end,
			get_cur_page=function() return StatsTextWidget:getCurrentIndex() end,
        },
		widgets.Divider{
			frame_style_l=false,
            frame_style_r=false,
            frame={t=3,l=0,r=0,h=1},
		},	
		StatsTextWidget{
			view_id='statsTextWidget',
			frame={t=4,l=0,r=0,b=0},
		},
	}
end

function StatsWindow:onRenderBody(dc)
	--self.subviews.statsTextWidget:setCurrentIndex(currentIndex)
	self:updateLayout()
	--ZScreen.super.render(self, dc)
end
StatScreen = defclass(StatScreen, gui.ZScreen)
StatScreen.ATTRS {
	focus_path = 'test2',
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
