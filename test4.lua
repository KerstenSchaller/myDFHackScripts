--@ module = true


local dfhack = require('dfhack')
local gui = require('gui')
local widgets = require('gui.widgets')


local eventful = require('plugins.eventful')

local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/'
package.path = script_dir .. '?.lua;' .. script_dir .. '?/init.lua;' .. package.path

local CurveWidget = require('CurveWidget')

local longString = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."



TestWindow = defclass(TestWindow, widgets.Window)

TestWindow.ATTRS {
    frame_title = 'Test Window',
    frame={w=80, h=40, l=40, t=13},
    autoarrange_subviews = true,
    autoarrange_gap = 1,
    resizable = true,
}

local currentV = 1
function TestWindow:onScrollbar(scroll_spec)
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
    if currentV + v >= 0 and currentV + v <= 30 then
        currentV = currentV + v
        self.subviews.scrollbar:update(currentV, 30, 60)
    end

    
end

function TestWindow:init()
    self:addviews{
        widgets.WrappedLabel{
            view_id='longText',
            frame={t=3, l=3, h=26, w=50},
            text_to_wrap=longString,
        },
        widgets.Panel{
            view_id='panel',
            frame={t=3, l=3, h=26, w=50},
            frame_style=gui.FRAME_INTERIOR,
            subviews={
                CurveWidget{
                    view_id='curve',
                    years={0,1,2,3,4,5,6,7,8,9,10,9,8,7,6,5,4,3,2,1,0,1,2,3,4,5,6,7,8,9,10},
                    values={0,1,2,3,4,5,6,7,8,9,10,9,8,7,6,5,4,3,2,1,0,1,2,3,4,5,6,7,8,9,10},
                    title="Example Stats",
                },
            },
        },
        widgets.Panel{
            view_id='panel',
            frame={t=0, l=53, h=40,w=4},
            frame_style=gui.FRAME_INTERIOR,
            subviews={
                widgets.Scrollbar{
                    view_id='scrollbar',
                    frame={l=0,t=0},
                    on_scroll=self:callback('onScrollbar'),
                    visible=true,   
                },
            },
        },
        widgets.WrappedLabel{
            view_id='longText',
            frame={t=3, l=3, h=26, w=50},
            text_to_wrap=longString,
        },
    }
    self.subviews.scrollbar:update(0, 30, 60)
end



testScreen = defclass(testScreen, gui.ZScreen)
testScreen.ATTRS {
    focus_path='minimal',
    pass_movement_keys=true,
    pass_mouse_clicks=false,
    defocusable=true,
}

function testScreen:init()
    self:addviews{TestWindow{}}
end

if not dfhack.isMapLoaded() then
    qerror('This script requires a map to be loaded')
end

function testScreen:onDismiss()
    view = nil
end

view = view and view:raise() or testScreen{}:show()

return testScreen