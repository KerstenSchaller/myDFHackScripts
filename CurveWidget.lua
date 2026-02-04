--- Draws a coordinate system (axes) using the line and crossing chars

local gui = require('gui')
local Widget = require('gui.widgets.widget')

-------------
-- CurveWidget --
-------------

---@class widgets.CurveWidget.attrs: widgets.Widget.attrs
---@field values number[]  # List of Y values to plot
---@field pen table        # Pen to use for drawing points/lines

---@class widgets.CurveWidget: widgets.Widget, widgets.CurveWidget.attrs
---@field super widgets.Widget
---@field ATTRS widgets.CurveWidget.attrs|fun(attributes: table)
---@overload fun(init_table: widgets.CurveWidget.attrs): self
CurveWidget = defclass(CurveWidget, Widget)

CurveWidget.ATTRS{
    values = {},
    pen = {ch = '᯽', fg = COLOR_WHITE, bg = COLOR_BLACK},
}

local cornerCharBottomRight = 217
local cornerCharTopLeft = 218
local cornerCharTopRight = 191
local cornerCharBottomLeft = 192
local horizontalLineChar = 196
local verticalLineChar = 179
local crossingLineChar = 197
local yTickChar = 180
local xTickChar = 194
local yTickDistance = 2
local xTickDistance = 4

function CurveWidget.drawXAxisTick(dc, x, y, pen)
    dc:seek(x , y):char(nil, dfhack.pen.parse{ch=xTickChar, fg=pen.fg, bg=pen.bg})
end

function CurveWidget.drawYAxisTick(dc, x, y, pen)
    dc:seek(x , y):char(nil, dfhack.pen.parse{ch=yTickChar, fg=pen.fg, bg=pen.bg})
end

---@param dc gui.Painter
---@param x integer  # left position
---@param y integer  # top position
---@param w integer  # width
---@param h integer  # height
---@param pen table  # pen table (with fg, bg)
function CurveWidget.drawCoordinateSystem(dc, x, y, w, h, pen)
    -- Offset axes by one tile into the negative x and y axis direction
    -- Draw horizontal axis (X axis) one tile above the bottom
    for i = 0, w-1 do
        dc:seek(x + i, y + h - 2):char(nil, dfhack.pen.parse{ch=horizontalLineChar, fg=pen.fg, bg=pen.bg})
    end
    -- Draw vertical axis (Y axis) one tile right from the left
    for j = 0, h-1 do
        dc:seek(x + 1, y + j):char(nil, dfhack.pen.parse{ch=verticalLineChar, fg=pen.fg, bg=pen.bg})
    end
    -- Draw crossing at the new origin (one tile up and right from bottom-left)
    dc:seek(x + 1, y + h - 2):char(nil, dfhack.pen.parse{ch=crossingLineChar, fg=pen.fg, bg=pen.bg})

    -- Draw x axis ticks
    for i = xTickDistance+1, w-1, xTickDistance do
        if i ~= 1 then -- skip crossing
            CurveWidget.drawXAxisTick(dc, x + i , y + h - 2, pen)
        end
    end
    -- Draw y axis ticks and value labels
    -- For value labels, we need min/max, so pass them as extra args (optional)
    local min, max = pen._min or 0, pen._max or 1
    local nTicks = math.floor((h-2) / yTickDistance)
    for t = 1, nTicks do
        local j = h-2-t*yTickDistance
        if j >= 0 and j ~= h-2 then -- skip crossing
            CurveWidget.drawYAxisTick(dc, x + 1, y + j, pen)
            -- Draw value label (right-aligned, left of axis)
            local value = min + (max-min) * (t*yTickDistance) / (h-3)
            local label = string.format('%.2f', value)
            local label_x = x + 1 - #label - 1
            if label_x >= 0 then
                dc:seek(label_x, y + j):string(label, dfhack.pen.parse{fg=pen.fg, bg=pen.bg})
            end
        end
    end
    return x+1, y+3 -- x and y offsets for drawing values
end



--- Draws a rectangle using the local pen values (character, fg, bg)
---@param dc gui.Painter
---@param x integer  # left position
---@param y integer  # top position
---@param w integer  # width
---@param h integer  # height
---@param pen table  # pen table (with ch, fg, bg)
function CurveWidget.drawRect(dc, x, y, w, h, pen)
    -- Draw corners
    dc:seek(x, y):char(nil, dfhack.pen.parse{ch=cornerCharTopLeft, fg=pen.fg, bg=pen.bg})
    dc:seek(x + w - 1, y):char(nil, dfhack.pen.parse{ch=cornerCharTopRight, fg=pen.fg, bg=pen.bg})
    dc:seek(x, y + h - 1):char(nil, dfhack.pen.parse{ch=cornerCharBottomLeft, fg=pen.fg, bg=pen.bg})
    dc:seek(x + w - 1, y + h - 1):char(nil, dfhack.pen.parse{ch=cornerCharBottomRight, fg=pen.fg, bg=pen.bg})

    -- Draw top and bottom borders
    for i = 1, w-2 do
        dc:seek(x + i, y):char(nil, dfhack.pen.parse{ch=horizontalLineChar, fg=pen.fg, bg=pen.bg})
        dc:seek(x + i, y + h - 1):char(nil, dfhack.pen.parse{ch=horizontalLineChar, fg=pen.fg, bg=pen.bg})
    end
    -- Draw left and right borders
    for j = 1, h-2 do
        dc:seek(x, y + j):char(nil, dfhack.pen.parse{ch=verticalLineChar, fg=pen.fg, bg=pen.bg})
        dc:seek(x + w - 1, y + j):char(nil, dfhack.pen.parse{ch=verticalLineChar, fg=pen.fg, bg=pen.bg})
    end
end


--- Plots the values as points on the graph
---@param dc gui.Painter
---@param rect table  # frame_rect with width and height
---@param values table # array of numbers
function CurveWidget.drawValues(dc, rect, values, xOffset, yOffset)
    local n = #values
    if n < 2 then return end
    -- Find min/max for scaling
    local min, max = values[1], values[1]
    
    for i = 2, n do
        if values[i] < min then min = values[i] end
        if values[i] > max then max = values[i] end
    end
    local height = rect.height
    local width = rect.width
    -- Offset so values do not draw over axes: x+2, y in [0, height-2)
    for i = 1, math.min(width-2, n) do
        local v = values[i]
        local y = math.floor((v - min) / math.max(1, max - min) * (height - 3 ) + 0.5)
        --local y = v
        y = height - y -- invert y so 0 is at bottom, above axis
        local _pen = dfhack.pen.parse{ ch = '*', fg = COLOR_WHITE, bg = COLOR_BLACK }
        dc:seek(i + xOffset, y - yOffset):char(nil, _pen)
    end
end

--- Renders the coordinate system and the values
---@param dc gui.Painter
function CurveWidget:onRenderBody(dc)
    local rect = self.frame_rect
    local values = self.values
    -- Find min/max for Y axis labels
    local min, max = values[1] or 0, values[1] or 1
    for i = 2, #values do
        if values[i] < min then min = values[i] end
        if values[i] > max then max = values[i] end
    end
    max = max 
    -- Pass min/max via pen for Y tick labels
    local pen = {}
    for k,v in pairs(self.pen) do pen[k]=v end
    pen._min = min
    pen._max = max
    local xOffset, yOffset = CurveWidget.drawCoordinateSystem(dc, 9, 0, rect.width-10, rect.height, pen)
    CurveWidget.drawValues(dc, rect, values, xOffset, yOffset)
end

return CurveWidget



