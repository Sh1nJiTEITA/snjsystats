-- #! /usr/bin/env lua

local utils = require("utils")
local m_stat = require("statfiles.stat")
local m_memory = require("statfiles.memory")
local m_cpu = require("statfiles.cpu")
local m_desc = require("statfiles.desc")

local raw = m_stat.StatFileHandle:new()
local raw = m_memory.FileHandleMemory:new()
-- local raw = m_cpu.FileHandleCpu:new()

-- print(utils.toSnakeCase("SomeWord(After)"))

print(raw:tostring())
--
local stat_res = raw:parse()

print(utils.dump(stat_res))
