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
for i = 0, 49 do
    table.insert(sinusValues, sinusAmplitude + sinusAmplitude * math.sin(i * sinusFrequency))
end

local handles = nil
local logo_textures1, logo_dfhack
local label_with_tileset
local using_logo1 = true

function MinimalWindow:onButtonClick()
    --dfhack.screen.dismiss(view)

    dfhack.gui.showAnnouncement("Button clicked! Toggling logo. Using logo1: " .. tostring(using_logo1), COLOR_LIGHTGREEN)  
    --DiagramScreen{}:show()
    local diagramScreen = DiagramScreen{tileset_path = "image.ppm"}
    diagramScreen:show()

end





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

local years = {1000, 1100,1200}

function MinimalWindow:onClick()
    local curve = self.subviews.curve
    local newValues = {}
    -- generate random values for demonstration
    for i = 1, 50 do
        table.insert(newValues, math.random(0, 100))
    end

    curve:updateValues(newValues)
end


function MinimalWindow:init()
    writeImage("image.ppm", BLACK_SHADE)
    logo_textures1 = dfhack.textures.loadTileset('image.ppm', 8, 12, true)
    logo_dfhack = dfhack.textures.loadTileset('hack/data/art/logo.png', 8, 12, true)
    handles = logo_textures1
    local logo_textures=dfhack.textures.loadTileset('image.ppm', 8, 12, true)
    self:addviews{



                widgets.Panel{
                    frame={b=2, h=20, w=50},
                    frame_style=gui.FRAME_INTERIOR,
                    subviews={
                        CurveWidget{
                            view_id='curve',
                            frame={t=0, l=0, r=0, b=0, w=50},
                            pen={fg=COLOR_GREEN, bg=COLOR_BLACK},
                            years=years,
                            values=sinusValues,
                        },
                    },
                    
                },
                widgets.Label{
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
                },
        
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