--@ module = true
reqscript('quickfort').refresh_scripts()

local gui = require('gui')
local widgets = require('gui.widgets')


local dfhack = require('dfhack')
local eventful = require('plugins.eventful')

local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/'
package.path = script_dir .. '?.lua;' .. script_dir .. '?/init.lua;' .. package.path

local CurveWidget = require('CurveWidget')
local DiagramScreen = require('DiagramWindow')
--
-- Fortress Statistics
--

MinimalWindow = defclass(MinimalWindow, widgets.Window)
MinimalWindow.ATTRS {
    frame_title='Fortress Statistics',

    frame={w=80, h=40, l=40, t=13},

    resizable=false,
}




local sinusAmplitude = 300
local sinusFrequency = 0.2
local sinusValues = {}
for i = 0, 149 do
    local val = sinusAmplitude * math.sin(i * sinusFrequency)
    if val > 0 then
        table.insert(sinusValues, val )
    end
end

local handles = nil
local logo_textures1, logo_dfhack
local label_with_tileset
local using_logo1 = true







local function hexToRGB(hex)
    hex = hex:gsub("#", "")
    if #hex ~= 6 then
        error("Invalid hex color: " .. hex)
    end
    local r = tonumber(hex:sub(1, 2), 16)
    local g = tonumber(hex:sub(3, 4), 16)
    local b = tonumber(hex:sub(5, 6), 16)
    print(string.format("Parsed color: R=%d, G=%d, B=%d", r, g, b))
    return string.char(tostring(r), tostring(g), tostring(b))
end

local BLACK_SHADE = hexToRGB("#1c1c1c")
local WHITE = hexToRGB("#ffffff")

local function writeImage(filename,color)
    local width, height = 64, 36
    local f = assert(io.open(filename, "wb"))
    -- PPM header
    f:write("P6\n")
    f:write(width .. " " .. height .. "\n")
    f:write("255\n")

    for y = 0, height - 1 do
        for x = 0, width - 1 do
            -- Draw a white cross in the left half
            if x < width // 2 and (x == width // 4 or y == height // 2) then
                f:write(WHITE)
            else
                f:write(color)
            end
        end
    end
    f:close()
end

local years = {4,8,12,16,20,24,28,32,36,40,44,48,52,56,60}

function MinimalWindow:onClick()
    local curve = self.subviews.curve
    local newValues = {}
    -- generate random values for demonstration
    for i = 1, 150 do
        table.insert(newValues, math.random(0, 100))
    end

    curve:updateValues(newValues)
end

local values       = {100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,
                      121,122,123,124,125,126,127,128,129,130,
                      131,132,133,134,135,136,137,138,139,140,
                      141,142,143,144,145,146,147,148,149}
local values = {0,1,2,3,4,5,6,7,8,9,10,
                11,12,13,14,15,16,17,18,19,
                20,21,22,23,24,25,26,27,28,
                29,30,31,32,33,34,35,36,37,
                38,39,40,41,42,43,44,45,46,47,}

function MinimalWindow:init()
    writeImage("image.ppm", BLACK_SHADE)
    logo_textures1 = dfhack.textures.loadTileset('image.ppm', 8, 12, true)
    logo_dfhack = dfhack.textures.loadTileset('hack/data/art/logo.png', 8, 12, true)
    handles = logo_textures1
    local logo_textures=dfhack.textures.loadTileset('image.ppm', 8, 12, true)
    self:addviews{
                widgets.Panel{
                    frame={t=2, h=20, w=54},
                    frame_style=gui.FRAME_INTERIOR,
                    subviews={
                        CurveWidget{
                            view_id='curve',
                            frame={t=0, l=0, r=0, b=0, w=54},
                            pen={fg=COLOR_GREEN, bg=COLOR_BLACK},
                            years=years,
                            values=values,
                        },
                    },
                    
                },
                widgets.Label{
                    frame={b=5,l=5},
                    text=widgets.makeButtonLabelText{
                        chars={
                            {179, 'D', 'F', 179},
                            {179, 'H', 'a', 179},
                            {179, 'c', 'k', 179},
                        },
                        tileset=logo_textures,
                        tileset_offset=1,
                        tileset_stride=8,
                        tileset_hover=logo_textures,
                        tileset_hover_offset=5,
                        tileset_hover_stride=8,
                    },
                    on_click=function()
                        self:onClick()
                    end,
                }
             }
        
    
    ::skip_texture_loading::
end

MinimalScreen = defclass(MinimalScreen, gui.ZScreen)
MinimalScreen.ATTRS {
    focus_path='minimal',
    pass_movement_keys=true,
    pass_mouse_clicks=false,
    defocusable=true,
}

function MinimalScreen:init()

    self:addviews{MinimalWindow{}}
end

if not dfhack.isMapLoaded() then
    qerror('This script requires a map to be loaded')
end

function MinimalScreen:onDismiss()
    --dfhack.textures.deleteHandle(logo_textures1)
    --dfhack.textures.deleteHandle(logo_dfhack)
    --dfhack.textures.deleteHandle(handles)
    --handles = nil
    --logo_textures1 = nil
    --logo_dfhack = nil
    view = nil
    view2 = nil
end

view = view and view:raise() or MinimalScreen{}:show()

return MinimalScreen