local AnnounceBooks = {}


local eventful = require('plugins.eventful')
local dfhack = require('dfhack')
local args = { ... }
local toolName = "AnnounceBooks"
local command1 = args[1] or 'help'
local command2 = args[2] or nil

local script_dir = dfhack.getDFPath() .. '/dfhack-config/scripts/'
package.path = script_dir .. '?.lua;' .. script_dir .. '?/init.lua;' .. package.path
local Helper = require('Helper')

local modId = "ANNOUNCE_BOOK_CREATION"

local known_books = {}


function AnnounceBooks.sortBooks(list, mode)
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



function AnnounceBooks.histFigureIsPartOfFortress(histFigId)
    for _, unit in ipairs(df.global.world.units.active) do
        if dfhack.units.isCitizen(unit) and histFigId == unit.hist_figure_id then
            return true
        end
    end
    return false
end

function AnnounceBooks.getFortressBooks()
    local books = {}
    for _, item in ipairs(df.global.world.items.all) do
        local title = dfhack.items.getBookTitle(item)
        if title ~= "" and AnnounceBooks.histFigureIsPartOfFortress(item.maker) then
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

function AnnounceBooks.getFortressBookTitles()
    local books = {}
    for _, item in ipairs(df.global.world.items.all) do
        local title = dfhack.items.getBookTitle(item)
        if title ~= "" and AnnounceBooks.histFigureIsPartOfFortress(item.maker) then
            table.insert(books, title)
        end
    end
    
    return books
end

function AnnounceBooks.countFortressBooks()
    local count = 0
    for _, _ in pairs(AnnounceBooks.getFortressBooks()) do
        count = count + 1
    end
    return count
end

function AnnounceBooks.copyTable(orig)
    local copy = {}
    for i, v in ipairs(orig) do
        copy[i] = v
    end
    return copy
end

function AnnounceBooks.printBooksOfFortress(sortmode)
    local books = AnnounceBooks.getFortressBooks()
    local copy = AnnounceBooks.copyTable(books)
    AnnounceBooks.sortBooks(copy, sortmode)
    for id, book in pairs(copy) do
        print(book.title .. " | Maker: " .. Helper.getMakerName(book.makerId) )
    end
end

local last_logged_message = ""

-- Function to check for new books and announce
function AnnounceBooks.checkForNewBooks()
    local current_books = AnnounceBooks.getFortressBooks()
    -- Build a set of known titles for fast lookup
    local known_titles = {}
    for _, book in ipairs(known_books) do
        known_titles[book.title] = true
    end
    -- Announce any new book whose title is not in known_titles
    for _, book in ipairs(current_books) do
        if not known_titles[book.title] then
            local message = Helper.getMakerName(book.makerId) .. " has written a new book titled '" .. book.title .. "'"
            if last_logged_message ~= message then
                dfhack.gui.showAnnouncement(message, COLOR_WHITE)
                last_logged_message = message
            end
            
            known_books = AnnounceBooks.copyTable(current_books)
            return
        end
    end
    -- Update known_books to the current list
end


local BookWatcherActive = true
function AnnounceBooks.startBookWatcher()
    dfhack.gui.showAnnouncement("Book watcher started.", COLOR_WHITE)
    -- Initial scan
    known_books = AnnounceBooks.getFortressBookTitles()
    print(AnnounceBooks.countFortressBooks() .. " books found in fortress")
    AnnounceBooks.printBooksOfFortress()

    local function tick()
        if not BookWatcherActive then
            return
        end
        AnnounceBooks.checkForNewBooks()
        dfhack.timeout(10, 'ticks', tick)
    end
    tick()
end

function AnnounceBooks.stopBookWatcher()
    BookWatcherActive = false
    print("Book watcher stopped.")
end

function AnnounceBooks.printHelp()
    print("Usage: " .. toolName .. " enable|disable|list [title|maker]")
    print(" enable - Start watching for new book creations.")
    print(" disable - Stop watching for new book creations.")
    print(" list - List all books currently in the fortress.")
    print(" list title - List all books sorted by title.")
    print(" list maker - List all books sorted by maker.")
end

function main(command1, command2)
    print("Command 1: " .. tostring(command1) .. ", Command 2: " .. tostring(command2))
    if command1 == 'enable' then
        AnnounceBooks.startBookWatcher()
    elseif command1 == 'disable' then
        AnnounceBooks.stopBookWatcher()
    elseif command1 == 'list' and command2 == nil then
        print(AnnounceBooks.countFortressBooks() .. " books found in fortress:")
        AnnounceBooks.printBooksOfFortress()
    elseif command1 == 'list' and command2 == "title" then
        print(AnnounceBooks.countFortressBooks() .. " books found in fortress:")
        AnnounceBooks.printBooksOfFortress("title")
    elseif command1 == 'list' and command2 == "maker" then
        print(AnnounceBooks.countFortressBooks() .. " books found in fortress:")
        AnnounceBooks.printBooksOfFortress("maker")
    else
        AnnounceBooks.printHelp()
    end
end
-------------------------------------------------------------------------------------------------------------------------------------
-- call main if script is run directly
-------------------------------------------------------------------------------------------------------------------------------------

main(command1, command2)

return AnnounceBooks
----------------------------------------------------------------------------------------------------------------------------------
