#! /usr/bin/env lua
local lib = require("lib")
local utils = require("utils")

-- print(lib.GetCpuLoadStr())
-- print(lib.GetCpuLoadAverage())

-- print(lib.DescriptorTypes.STAT_FILE)
--
lib.OpenDescriptorFileInternal(lib.DescriptorTypes.STAT_FILE)

-- local cpu_stats = lib.ReadStatFile()

local function cpustr()
	local stats = lib.ReadStatFile()
	local message = ""
	for _, stat in ipairs(stats) do
		message = message .. string.format("%-10s %-5f", stat.name, M.CalculateLoad(stat)) .. "\n"
	end
	return message
end

print(cpustr())
