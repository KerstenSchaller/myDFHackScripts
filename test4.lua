--@ module = true


local dfhack = require('dfhack')
local gui = require('gui')
local widgets = require('gui.widgets')


local eventful = require('plugins.eventful')

local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/'
package.path = script_dir .. '?.lua;' .. script_dir .. '?/init.lua;' .. package.path

local CurveWidget = require('CurveWidget')

local longString = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
local shortString = "Lorem ipsum dolor sit."

local CustomTextWidget = defclass(CustomTextWidget, widgets.Widget)
CustomTextWidget.ATTRS {
    frame={t=3, l=3, h=26, w=50},
    text=longString,
}

function CustomTextWidget:onRenderBody(dc)
    local lines = self.text or {}
    if type(lines) == 'string' then
        lines = {lines}
    end
    local max_lines = math.min(#lines, self.frame.h)
    for j = 1, max_lines do
        dc:string(lines[j], nil, j-1, 0)
    end
end

-- Replace widgets.WrappedLabel with CustomTextWidget in TestWindow:init()
function TestWindow:init()
    self:addviews{
        CustomTextWidget{
            view_id='longText',
            frame={t=3, l=3, h=26, w=50},
            text=longString,
        },
        -- ...existing code...
    }
    self.subviews.scrollbar:update(0, 30, 60)
end

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

        dfhack.gui.showAnnouncement("Scrolled to: " .. currentV)
        -- If you have other content views, adjust their frame.t similarly
    end
end

function TestWindow:splitStringIntoLines(text, max_width)
    local lines = {}
    local i = 1
    if type(text) == 'table' then
        return text
    end
    if text:find('\n') then
        for line in text:gmatch('[^\n]+') do
            table.insert(lines, line)
        end
        return lines
    end
    while i <= #text do
        local line = text:sub(i, i + max_width - 1)
        table.insert(lines, line)
        i = i + max_width
    end
    return lines
end

function TestWindow:init()

    local longInitText = self:splitStringIntoLines(longString, 50)
    local shortInitText = self:splitStringIntoLines(shortString, 50)


    local tempText = longInitText
    local panel1_t = #tempText
    local longText1_frame = {t=3, l=3, h=panel1_t, w=50}

    self:addviews{
        CustomTextWidget{
            view_id='longText1',
            frame=longText1_frame,
            text=tempText,
        },
        widgets.Panel{
            view_id='panel1',
            frame={t=panel1_t, l=3, h=26, w=50},
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
            view_id='panel2',
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
        CustomTextWidget{
            view_id='longText2',
            frame={t=3, l=3, h=26, w=50},
            text=tempText,
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