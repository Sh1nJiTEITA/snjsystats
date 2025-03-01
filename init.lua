local lib = require("lib")
local data = lib.ReadAllFile("/proc/stat")
local cpu_0 = string.sub(data, 0, string.find(data, "\n"))

-- cpu_0 = lib.CreateSingleCpuStat(cpu_0)

local stats = lib.GetCpuStats()

for i, stat in ipairs(stats) do
	print(i, M.toString(stat))
end
