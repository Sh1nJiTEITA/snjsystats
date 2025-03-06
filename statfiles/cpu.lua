CpuModule = {}

package.path = package.path .. ";../?.lua;./?.lua;./statfiles/?.lua"

local desc = require("desc")
local utils = require("utils")

CpuModule.FileHandleCpu = desc.DataFileHandle:new({})

function CpuModule.FileHandleCpu:new(o)
	o = o or {}
	o.path = "/proc/cpuinfo"
	o.file = io.open(o.path, "r")
	setmetatable(o, self)
	self.__index = self
	return o
end

return CpuModule
