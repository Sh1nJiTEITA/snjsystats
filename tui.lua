local curses = require("curses")
local socket = require("socket")

local m_memory = require("statfiles.memory")

local function printf(fmt, ...)
   return print(string.format(fmt, ...))
end

---@class MainWindow
---@field cwin table
MainWindow = {
   cwin = curses.initscr(),
}

function MainWindow:create()
   self.cwin:mvaddstr(0, 1, "snjsystats")
   -- self.cwin:mvaddch(1, 0, curses.ACS_LTEE)
end

function MainWindow:createTabs()
   local lines, cols = self.cwin:getmaxyx()
   -- print(lines, cols)
   self.twin = self.cwin:sub(3, cols - 2, 1, 1)
   local by, bx = self.twin:getbegyx()
   local ey, ex = self.twin:getmaxyx()
   self.twin:mvhline(by - 1, bx - 1, curses.ACS_HLINE, ex)
   self.twin:mvaddstr(0, 1, "Memory")
end

---
---@param window MainWindow
---@param memoryfile table
local function printMemory(window, memoryfile, y)
   local file_data = memoryfile:parse()
   local i = y
   for key, value in pairs(file_data.general) do
      window.cwin:mvaddstr(i, 1, string.format("%-15s: %-10d kB", key, value))
      i = i + 1
   end
end

---
---@return table<string, DataFileHandle>
local function initFiles()
   local files = {
      memory = m_memory.FileHandleMemory:new(),
   }
   return files
end

---
---@param window MainWindow
---@return boolean
local function processInput(window)
   local c = string.char(window.cwin:getch())
   if c == "q" then
      return true
   end
   return false
end

---
---@param window MainWindow
---@param files table<string, DataFileHandle>
local function loop(window, files)
   window.cwin:nodelay(true)
   window.cwin:border()
   window:create()
   window:createTabs()
   local timedelta = 1
   local last_update = socket.gettime() - timedelta
   while true do
      local now = socket.gettime()
      if now - last_update >= timedelta then
         printMemory(window, files.memory, 5)
         window.cwin:refresh()
         last_update = now
      end
      -- socket.sleep(1.5)
      if processInput(window) then
         break
      end
   end
end

local function main()
   -- local stdscr = curses.initscr()
   curses.cbreak()
   curses.echo(false)
   curses.nl(false)
   curses.curs_set(0)

   local files = initFiles()
   loop(MainWindow, files)
   -- stdscr:clear()
   -- local sub = stdscr:derive(10, 10, 10, 10)
   -- sub:border()
   -- local c = stdscr:getch()
   curses.endwin()
end

-- To display Lua errors, we must close curses to return to
-- normal terminal mode, and then write the error to stdout.
local function err(err)
   curses.endwin()
   print("Caught an error:")
   print(debug.traceback(err, 2))
   os.exit(2)
end

xpcall(main, err)
