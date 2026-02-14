--- Draws a coordinate system (axes) using the line and crossing chars

local gui = require('gui')
local widgets = require('gui.widgets')


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
    years = {}, -- Optional: array of years for x-axis labels
    pen = {ch = '᯽', fg = COLOR_WHITE, bg = COLOR_BLACK},
    title = "Curve Widget",
}

local bottomOffset = 6
local heightSupression = 4 -- number of rows to suppress at top of graph to prevent bars from touching top border

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

local FullBlockChar = 219
local LightShadeChar = 176
local MediumShadeChar = 177
local DarkShadeChar = 178

local barChar = LightShadeChar 

function sliderValueChanged()
    dfhack.gui.showAnnouncement("Slider value changed: " .. tostring(sliderVal), COLOR_LIGHTGREEN)
    if CurveWidget and CurveWidget.redraw then
        CurveWidget:redraw()
    end
end

function CurveWidget:UpdateValueText()
    local valueText = "Values: "
    for i, v in ipairs(self.values) do
        valueText = valueText .. string.format("%.2f ", v)
    end
    self.value_text = valueText
end

local sliderVal = 1
local sliderVal2 = 1
function CurveWidget:init()

    local yearOptions={}
    for i, year in ipairs(self.years) do
        table.insert(yearOptions, {label=tostring(year), value=year})
    end

    local quarterOptions={
        {label="Q1", value=1},
        {label="Q2", value=2},
        {label="Q3", value=3},
        {label="Q4", value=4},
    }

    self:addviews{
        widgets.Label{
            frame={t=0,l=20},
            text=self.title,
        },
        widgets.Divider{
            view_id='divider1',
            frame_style_l=false,
            frame_style_r=false,
            frame={t=1,l=0,r=0,h=1},
        },
        widgets.Slider{
            view_id='range_slider',
            frame={b=3},
            active=true,
            num_stops=16,
            get_idx_fn=function()
                return sliderVal
            end,
            on_change=function(idx)
                sliderVal = idx
                sliderValueChanged()
                self:updateLayout()
            end,
        },
        widgets.Divider{
            view_id='divider2',
            frame_style_l=false,
            frame_style_r=false,
            frame={b=2,l=0,h=1,w=54},
        },
        widgets.Slider{
            view_id='range_slider',
            frame={b=3},
            active=true,
            num_stops=16,
            get_idx_fn=function()
                return sliderVal2
            end,
            on_change=function(idx)
                sliderVal2 = idx
            end,
        },
    }

end

function CurveWidget.drawXAxisTick(dc, x, y, pen)
    dc:seek(x , y):char(nil, dfhack.pen.parse{ch=xTickChar, fg=pen.fg, bg=pen.bg})
end

function CurveWidget.drawYAxisTick(dc, x, y, pen)
    dc:seek(x , y):char(nil, dfhack.pen.parse{ch=yTickChar, fg=pen.fg, bg=pen.bg})
end

function CurveWidget.getLongestLabelLength(dc, x, y, w, h, pen)
    local longest_label_len = 0
    local min, max = pen._min or 0, pen._max or 1
    local nTicks = math.floor((h-2) / yTickDistance)
    local yTickPositions = {}
    for t = 1, nTicks do
        local j = h-1-t*yTickDistance
        if j >= 0 and j ~= h-2 then -- skip crossing
            -- Draw value label (right-aligned, left of axis)
            local value = min + (max-min) * (t*yTickDistance) / (h)
            local int_value = math.floor(value + 0.5)
            local label = tostring(int_value)
            if #label > longest_label_len then longest_label_len = #label end
        end
    end
    return longest_label_len
end

---@param dc gui.Painter
---@param x integer  # left position
---@param y integer  # top position
---@param w integer  # width
---@param h integer  # height
---@param pen table  # pen table (with fg, bg)
function CurveWidget.drawCoordinateSystem(dc, x, y, w, h, pen)



    -- Draw y axis ticks and value labels
    -- For value labels, we need min/max, so pass them as extra args (optional)
    local min, max = pen._min or 0, pen._max or 1
    local nTicks = math.floor((h) / yTickDistance)
    local longest_label_len = CurveWidget.getLongestLabelLength(dc, x, y, w, h, pen)
    local yTickPositions = {}
    for t = 1, nTicks do
        local j = h-bottomOffset-t*yTickDistance
        if j + bottomOffset >= 0 and j ~= h-bottomOffset then -- skip crossing
            -- Draw value label (right-aligned, left of axis)
            local value = min + (max-min) * ((t+2)*yTickDistance) / (math.min(max-min,h-heightSupression))
            local int_value = math.floor(value + 0.5)
            local label = tostring(int_value)

            CurveWidget.drawYAxisTick(dc, x + 1 + longest_label_len, y + j, pen)
            yTickPositions[j] = int_value
            local label_x = x + 1 - #label - 1 + longest_label_len
            label_x =1
            if label_x >= 0 then
                dc:seek(x, y + j):string(label, dfhack.pen.parse{fg=pen.fg, bg=pen.bg})
            end
        end
    end


    -- Offset axes by one tile into the negative x and y axis direction
    -- Draw horizontal axis (X axis) one tile above the bottom
    for i = 0, w-1 do
        dc:seek(x + i+longest_label_len, y + h - bottomOffset):char(nil, dfhack.pen.parse{ch=horizontalLineChar, fg=pen.fg, bg=pen.bg})
    end
    -- Draw vertical axis (Y axis) one tile right from the left
    for j = 0, h-bottomOffset + 1 do
        if not yTickPositions[j] then
             dc:seek(x + 1 + longest_label_len, y + j):char(nil, dfhack.pen.parse{ch=verticalLineChar, fg=pen.fg, bg=pen.bg})
        end
    end
    -- Draw crossing at the new origin (one tile up and right from bottom-left)
    dc:seek(x + 1 + longest_label_len, y + h - bottomOffset):char(nil, dfhack.pen.parse{ch=crossingLineChar, fg=pen.fg, bg=pen.bg})
    -- Draw x axis ticks and year labels
    local years = pen._years or nil
    local tick_idx = 1
    local startIdx = sliderVal - 1 or 1
    for i = xTickDistance+1, w-1, xTickDistance do
        if i ~= 1 then -- skip crossing
            local tick_x = x + i + longest_label_len
            CurveWidget.drawXAxisTick(dc, tick_x, y + h - bottomOffset, pen)
            -- Draw year label centered under tick
            local year
            local valueIdx = startIdx + tick_idx
            if years and years[valueIdx] then
                local tYear = years[valueIdx]
                if tYear > 999 then
                    year = tostring(tYear % 1000)
                else
                    year = tostring(tYear)
                end
            else
                year = tostring(valueIdx)
            end
            year = string.rep('0', 3 - #year) .. year
            local label_x = tick_x - 1
            local label_y = y + h + 1 - bottomOffset
            if label_x >= 0 and label_x + 2 < x + w then
                dc:seek(label_x, label_y):string(year, dfhack.pen.parse{fg=pen.fg, bg=pen.bg})
            end
            tick_idx = tick_idx + 1
        end
    end

    return x+1 + longest_label_len, y+1, longest_label_len -- x and y offsets for drawing values, and longest label length
end

function CurveWidget:updateValues(values)
    dfhack.gui.showAnnouncement("Updating curve values. New count: " .. tostring(#values), COLOR_LIGHTGREEN)
    self.values = values
    self:updateLayout()
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
    if n < 1 then return end
    -- Find min/max for scaling
    local min, max = values[1], values[1]
    for i = 2, n do
        if values[i] < min then min = values[i] end
        if values[i] > max then max = values[i] end
    end
    local height = rect.height 
    local width = rect.width
    local startIdx = (sliderVal-1)*xTickDistance+1 or 1
    --local valueIdx = startIdx + xTickDistance
    local endIdx = math.min(startIdx + width - 3, n)
    for i = startIdx, endIdx do
        local v = values[i]
        -- Calculate bar height (number of rows to fill)
        local barHeight = math.floor((v - min) / math.max(1, max - min) *  (math.min(max-min,height-heightSupression-bottomOffset)) + 0.5)
        for h = 0, barHeight - 1 do
            local y = height - bottomOffset - h -- -2 to stay above axis
            local _pen = dfhack.pen.parse{ ch = barChar, fg = COLOR_WHITE, bg = COLOR_BLACK }
            dc:seek(i - startIdx + 1 + xOffset, y - yOffset):char(nil, _pen)
        end
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
    -- Pass min/max/years via pen for Y tick labels and X axis years
    local pen = {}
    for k,v in pairs(self.pen) do pen[k]=v end
    pen._min = min
    pen._max = max
    if self.years then
        pen._years = self.years
    end
    local xOffset, yOffset, longest_label_len = CurveWidget.drawCoordinateSystem(dc, 0, 1, rect.width, rect.height-2,pen)
    CurveWidget.drawValues(dc, rect, values, xOffset, yOffset)
end

return CurveWidget



