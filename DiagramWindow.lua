local gui = require('gui')
local widgets = require('gui.widgets')
local dfhack = require('dfhack')

local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/'
package.path = script_dir .. '?.lua;' .. script_dir .. '?/init.lua;' .. package.path

--
-- Diagram Widget Window
--
local view

DiagramWindow = defclass(DiagramWindow, widgets.Window)
DiagramWindow.ATTRS {
    frame_title = 'Diagram Widget',
    frame = {w = 60, h = 20, r = 2, t = 18},
    autoarrange_subviews = true,
    autoarrange_gap = 1,
    resizable = true,
    tileset_path = dfhack.NULL, -- path to tileset ppm/png
}

function DiagramWindow:init()
    local path = self.tileset_path or 'hack/data/art/logo.png'
    local logo_textures = dfhack.textures.loadTileset(path, 8, 12, true)
    self:addviews{
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
            on_click=function(self)
                dfhack.run_command{'hotkeys', 'menu', self.name}
            end,
        },
    }
end

---@param dc gui.Painter
function DiagramWindow:onRenderBody(dc)
    -- Rendering code goes here
end

DiagramScreen = defclass(DiagramScreen, gui.ZScreen)
DiagramScreen.ATTRS {
    focus_path = 'diagram',
    pass_movement_keys = true,
    pass_mouse_clicks = false,
}

function DiagramScreen:init()
    self:addviews{DiagramWindow{}}
    dfhack.gui.showAnnouncement("Diagram Screen opened!", COLOR_LIGHTGREEN)
    view = view and view:raise() or DiagramScreen{}:show()
    --self:raise()
end

function DiagramScreen:onDismiss()
    view = nil
    
end


function set()
    view = view and view:raise() or DiagramScreen{}:show()
end


return DiagramScreen