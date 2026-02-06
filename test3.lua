

local gui = require('gui')
local widgets = require('gui.widgets')
local dfhack = require('dfhack')

local logo_textures1 = dfhack.textures.loadTileset('hack/data/art/logo.png', 8, 12, true)

local view1, view2

TestWindow1 = defclass(TestWindow1, widgets.Window)
TestWindow1.ATTRS {
	frame_title = 'Test Window 1',
	frame = {w = 60, h = 10, r = 2, t = 5},
	autoarrange_subviews = true,
	autoarrange_gap = 1,
	resizable = true,
}

function TestWindow1:onButtonClick()
	dfhack.gui.showAnnouncement('TestWindow1 Button clicked! Args: '..tostring(x)..','..tostring(y), COLOR_LIGHTGREEN)
	dfhack.screen.dismiss(view1)
	view2 = TestScreen2{}:show()
end

function TestWindow1:init()
	self:addviews{
		widgets.Label{
			text=widgets.makeButtonLabelText{
				chars={
					{179, 'D', 'F', 179},
					{179, 'H', 'a', 179},
					{179, 'c', 'k', 179},
				},
				view_id='graphLabel1',
				tileset=logo_textures1,
				tileset_offset=1,
				tileset_stride=8,
				tileset_hover=logo_textures1,
				tileset_hover_offset=5,
				tileset_hover_stride=8,
			},
			on_click=function(self)
				self:onButtonClick()
			end,
		},
	}
end

TestScreen1 = defclass(TestScreen1, gui.ZScreen)
TestScreen1.ATTRS {
	focus_path = 'test1',
	pass_movement_keys = true,
	pass_mouse_clicks = false,
}

function TestScreen1:init()
	self:addviews{TestWindow1{}}
end

TestWindow2 = defclass(TestWindow2, widgets.Window)
TestWindow2.ATTRS {
	frame_title = 'Test Window 2',
	frame = {w = 60, h = 10, r = 2, t = 20},
	autoarrange_subviews = true,
	autoarrange_gap = 1,
	resizable = true,
}

function TestWindow2:onButtonClick()
	dfhack.gui.showAnnouncement('TestWindow2 Button clicked! Args: '..tostring(x)..','..tostring(y), COLOR_LIGHTRED)
	dfhack.screen.dismiss(view2)
	view1 = TestScreen1{}:show()
end

function TestWindow2:init()
	self:addviews{
		widgets.Label{
			text=widgets.makeButtonLabelText{
				chars={
					{179, 'T', 'E', 179},
					{179, 'S', 'T', 179},
					{179, 'W', '2', 179},
				},
				view_id='graphLabel2',
				tileset=logo_textures1,
				tileset_offset=1,
				tileset_stride=8,
				tileset_hover=logo_textures1,
				tileset_hover_offset=5,
				tileset_hover_stride=8,
			},
			on_click=function()
				self:onButtonClick()
			end,
		},
	}
end

TestScreen2 = defclass(TestScreen2, gui.ZScreen)
TestScreen2.ATTRS {
	focus_path = 'test2',
	pass_movement_keys = true,
	pass_mouse_clicks = false,
}

function TestScreen2:init()
	self:addviews{TestWindow2{}}
end

-- Show only TestScreen1 initially
view1 = view1 and view1:raise() or TestScreen1{}:show()
--view2 = view2 and view2:raise() or TestScreen2{}:show()
