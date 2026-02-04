local dig = require('plugins.dig')
local gui = require('gui')
local widgets = require('gui.widgets')


local dfhack = require('dfhack')
local eventful = require('plugins.eventful')

local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/'
package.path = script_dir .. '?.lua;' .. script_dir .. '?/init.lua;' .. package.path

local CurveWidget = require('CurveWidget')

--
-- Minimal Example
--

MinimalWindow = defclass(MinimalWindow, widgets.Window)
MinimalWindow.ATTRS {
    frame_title='Minimal Example',
    --[[
        frame: Table specifying the dimensions and position of a GUI frame.
          w: Width of the frame in pixels.
          h: Height of the frame in pixels.
          r: Right offset or margin from the parent/container, in pixels.
          t: Top offset or margin from the parent/container, in pixels.
    ]]
    frame={w=160, h=40, r=2, t=18},
    autoarrange_subviews=true,
    autoarrange_gap=1,
    resizable=true,
}


local sinusAmplitude = 300
local sinusFrequency = 0.2
local sinusValues = {}
for i = 0, 49 do
    table.insert(sinusValues, sinusAmplitude + sinusAmplitude * math.sin(i * sinusFrequency))
end

function MinimalWindow:init()
    self:addviews{
        widgets.Label{
            frame={t=0, l=0},
            text='Hello, DFHack GUI!',
        },
        CurveWidget{
            frame={h=18}, -- height of the graph
            values=sinusValues, -- example data
            --values={120, 240, 255, 570, 240, 430, 340, 500, 600, 340, 125, 300}, -- example data
            pen={ch='*', fg=COLOR_LIGHTCYAN},
        },
        widgets.Label{
            frame={t=0, l=0},
            text='__12345678901234567890123456789012345678901234567890',
        }
    }
end

MinimalScreen = defclass(MinimalScreen, gui.ZScreen)
MinimalScreen.ATTRS {
    focus_path='minimal',
    pass_movement_keys=true,
    pass_mouse_clicks=false,
}

function MinimalScreen:init()
    self:addviews{MinimalWindow{}}
end

if not dfhack.isMapLoaded() then
    qerror('This script requires a map to be loaded')
end

function MinimalScreen:onDismiss()
    view = nil
end

view = view and view:raise() or MinimalScreen{}:show()
