local curses = require("curses")

local function printf(fmt, ...)
   return print(string.format(fmt, ...))
end

local function init() end

local function loop(window)
   local c = nil
   while true do
      -- window:clear()
      c = window:getch()
      window:addch(c)
      if string.char(c) == "q" then
         break
      end
   end
end

local function main()
   local stdscr = curses.initscr()
   curses.cbreak()
   curses.echo(false)
   curses.nl(false)
   curses.curs_set(2)

   -- stdscr:mvaddstr(0, 0, string.format("Number of cols: %x", curses.cols()))
   loop(stdscr)
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
