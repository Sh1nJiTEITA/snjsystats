-- #! /usr/bin/env lua

local utils = require("utils")
local m_cpu = require("statfiles.stat")
local m_memory = require("statfiles.memory")
local m_desc = require("statfiles.desc")

local raw = m_cpu.StatFileHandle:new()
local raw = m_memory.FileHandleMemory:new()

utils.toSnakeCase("SomeWordAfter")

--
-- print(raw:tostring())
-- --
-- local stat_res = raw:parse()
--
-- print(utils.dump(stat_res))
