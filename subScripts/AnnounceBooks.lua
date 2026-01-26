local eventful = require('plugins.eventful')
local dfhack = require('dfhack')
local args = { ... }
local toolName = "AnnounceBooks"
local command1 = args[1] or 'help'
local command2 = args[2] or nil

local modId = "ANNOUNCE_BOOK_CREATION"

local known_books = {}

function sortBooks(list, mode)
    if mode == "title" then  
        table.sort(list, function(a, b)
            return a.title:lower() < b.title:lower()
        end)
    elseif mode == "maker" then  
        table.sort(list, function(a, b)
            return Helper.getMakerName(a.makerId):lower() < Helper.getMakerName(b.makerId):lower()
        end)
    else  
        return list
    end

end



function histFigureIsPartOfFortress(histFigId)
    for _, unit in ipairs(df.global.world.units.active) do
        if dfhack.units.isCitizen(unit) and histFigId == unit.hist_figure_id then
            return true
        end
    end
    return false
end

function getFortressBooks()
    local books = {}
    for _, item in ipairs(df.global.world.items.all) do
        local title = dfhack.items.getBookTitle(item)
        if title ~= "" and histFigureIsPartOfFortress(item.maker) then
            table.insert(books, {
                id = item.id,
                title = title,
                makerId = item.maker,
                quality = item.quality
            })
        end
    end
    
    return books
end

function getFortressBookTitles()
    local books = {}
    for _, item in ipairs(df.global.world.items.all) do
        local title = dfhack.items.getBookTitle(item)
        if title ~= "" and histFigureIsPartOfFortress(item.maker) then
            table.insert(books, title)
        end
    end
    
    return books
end

function countFortressBooks()
    local count = 0
    for _, _ in pairs(getFortressBooks()) do
        count = count + 1
    end
    return count
end

function copyTable(orig)
    local copy = {}
    for i, v in ipairs(orig) do
        copy[i] = v
    end
    return copy
end

function printBooksOfFortress(sortmode)
    local books = getFortressBooks()
    local copy = copyTable(books)
    sortBooks(copy, sortmode)
    for id, book in pairs(copy) do
        print(book.title .. " | Maker: " .. Helper.getMakerName(book.makerId) )
    end
end

-- Function to check for new books and announce
function checkForNewBooks()
    local current_books = getFortressBookTitles()
    for id, book in pairs(current_books) do
        if not known_books[id] then
            local bookData = getFortressBooks()[id]
            dfhack.gui.showAnnouncement(Helper.getMakerName(bookData.makerId) .. " has written a new book titled '" .. bookData.title .. "'", COLOR_WHITE)
        end
    end
    known_books = current_books
end

local function startBookWatcher()
    dfhack.gui.showAnnouncement("Book watcher started.", COLOR_WHITE)
    -- Initial scan
    known_books = getFortressBookTitles()
    print(countFortressBooks() .. " books found in fortress")
    printBooksOfFortress()

    local function tick()
        checkForNewBooks()
        dfhack.timeout(10, 'ticks', tick)
    end
    tick()
end

function stopBookWatcher()
    eventful.onTickEnd[modId] = nil
    print("Book watcher stopped.")
end

function printHelp()
    print("Usage: " .. toolName .. " enable|disable|list [title|maker]")
    print(" enable - Start watching for new book creations.")
    print(" disable - Stop watching for new book creations.")
    print(" list - List all books currently in the fortress.")
    print(" list title - List all books sorted by title.")
    print(" list maker - List all books sorted by maker.")
end

-------------------------------------------------------------------------------------------------------------------------------------
-- Main command handling
-------------------------------------------------------------------------------------------------------------------------------------
if command1 == 'enable' then
    startBookWatcher()
elseif command1 == 'disable' then
    stopBookWatcher()
elseif command1 == 'list' and command2 == nil then
    print(countFortressBooks() .. " books found in fortress:")
    printBooksOfFortress()
elseif command1 == 'list' and command2 == "title" then
    print(countFortressBooks() .. " books found in fortress:")
    printBooksOfFortress("title")
elseif command1 == 'list' and command2 == "maker" then
    print(countFortressBooks() .. " books found in fortress:")
    printBooksOfFortress("maker")
else
    printHelp()
end


----------------------------------------------------------------------------------------------------------------------------------
