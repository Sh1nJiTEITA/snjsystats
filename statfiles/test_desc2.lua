local desc = require("desc2")
local stat = require("stat2")

-- local raw = desc.DataFileHandle:new()
local raw = stat.StatFileHandle:new()

-- raw:parse()

print(raw:tostring())
