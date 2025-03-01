M = {}

local utils = require("utils")

function M.ReadAllFile(path)
	io.input(path)
	local data = io.read("*all")
	return data
end

function M.GetCpuStats()
	io.input("/proc/stat")
	local stats = {}
	while true do
		local str = io.read("*l")
		if not string.find(str, "cpu") then
			break
		end
		local stat = M.CreateSingleCpuStat(str)
		if stat == nil then
			break
		end
		table.insert(stats, stat)
	end
	return stats
end

---@class SingleCpuStat
---@field name string    Cpu name
---@field user number    1. Normal processes executing in user mode
---@field nice number	 2. Niced processes executing in user mode
---@field system number  3. Processes executing in kernel mode
---@field idle number    4. Twiddling thumbs
---@field iowait number  5. Waiting for I/O to complete
---@field irq number     6. Servicing interrupts
---@field softirq number 7. Servicing softirqs

--- Returns SingleCpuStat as string
---@param stat SingleCpuStat
---@return string
function M.toString(stat)
	return "CpuStat("
		.. "name: "
		.. stat.name
		.. ", user: "
		.. stat.user
		.. ", nice: "
		.. stat.nice
		.. ", system: "
		.. stat.system
		.. ", idle: "
		.. stat.idle
		.. ", iowait: "
		.. stat.iowait
		.. ", irq: "
		.. stat.irq
		.. ", softirq: "
		.. stat.softirq
		.. ")"
end

---@param input_string string Input string from file '/proc/stat'
---@return SingleCpuStat | nil
function M.CreateSingleCpuStat(input_string)
	local values = {}
	local i = 1
	for word in string.gmatch(input_string, "%w+") do
		values[i] = word
		i = i + 1
	end

	if #values < 7 + 1 then
		return nil
	end

	return {
		name = values[1],
		-- 1. Normal processes executing in user mode
		user = values[2],
		-- 2. Niced processes executing in user mode
		nice = values[3],
		-- 3. Processes executing in kernel mode
		system = values[4],
		-- 4. Twiddling thumbs
		idle = values[5],
		-- 5. Waiting for I/O to complete
		iowait = values[6],
		-- 6. Servicing interrupts
		irq = values[7],
		-- 7. Servicing softirqs
		softirq = values[8],
	}
end

--- Calculates load of input cpu
---@param cpu_stat SingleCpuStat
---@return number
function M.CalculateIdle(cpu_stat)
	return (cpu_stat.idle * 100)
		/ (
			cpu_stat.user
			+ cpu_stat.nice
			+ cpu_stat.system
			+ cpu_stat.iowait
			+ cpu_stat.irq
			+ cpu_stat.softirq
			+ cpu_stat.idle
		)
end

return M
