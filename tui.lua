local curses = require("curses")
local socket = require("socket")

local m_memory = require("statfiles.memory")

local function printf(fmt, ...)
   return print(string.format(fmt, ...))
end

local function printMemory(window, memoryfile)
   local file_data = memoryfile:parse()
   local i = 1
   for key, value in pairs(file_data.general) do
      window:mvaddstr(i, 1, string.format("%-15s: %-10d kB", key, value))
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

local function processInput(window)
   local c = string.char(window:getch())
   if c == "q" then
      return true
   end
   return false
end

---
---@param window table
---@param files table<string, DataFileHandle>
local function loop(window, files)
   window:nodelay(true)
   window:border()
   local timedelta = 1
   local last_update = socket.gettime() - timedelta
   while true do
      local now = socket.gettime()
      if now - last_update >= timedelta then
         printMemory(window, files.memory)
         window:refresh()
         last_update = now
      end
      -- socket.sleep(1.5)
      if processInput(window) then
         break
      end
   end
end

local function main()
   local stdscr = curses.initscr()
   curses.cbreak()
   curses.echo(false)
   curses.nl(false)
   curses.curs_set(0)

   local files = initFiles()
   loop(stdscr, files)
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
