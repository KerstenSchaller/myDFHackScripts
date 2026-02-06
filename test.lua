local width, height = 64, 36




-- Pixel data

local DARK_GRAY = string.char(160, 160, 160)
local BLACK = string.char(0, 0, 0)
local WHITE = string.char(255, 255, 255)

-- rgb color from hex string, e.g. "#FFAABB"
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
local BLACK_SHADE1 = hexToRGB("#241f28")
local BLACK_SHADE2 = hexToRGB("#28212c")
local BLACK_SHADE3 = hexToRGB("#28242b")
local BLACK_SHADE4 = hexToRGB("#29252a")
local BLACK_SHADE5 = hexToRGB("#29282c")
local BLACK_SHADE6 = hexToRGB("#2e2f30")
local BLACK_SHADE7 = hexToRGB("#4f4d49")
local BLACK_SHADE8 = hexToRGB("#6f6d68")
local BLACK_SHADE9 = hexToRGB("#a4a8ab")

function createImage(filename,color)
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
end


createImage("image.ppm",  BLACK_SHADE)
createImage("image1.ppm",  BLACK_SHADE1)
createImage("image2.ppm",  BLACK_SHADE2)
createImage("image3.ppm",  BLACK_SHADE3)
createImage("image4.ppm",  BLACK_SHADE4)
createImage("image5.ppm",  BLACK_SHADE5)
createImage("image6.ppm",  BLACK_SHADE6)
createImage("image7.ppm",  BLACK_SHADE7)


