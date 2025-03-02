M = {}

local utils = require("utils")

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

--- Calculates load of input cpu
---@param cpu_stat SingleCpuStat
---@return number
function M.CalculateLoad(cpu_stat)
	return 100 - M.CalculateIdle(cpu_stat)
end

--- Creates list of cpu stats
---@return SingleCpuStat[] # all available cores
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

--- Creates simple indent string output of cpu load
---@return string
function M.GetCpuLoadStr()
	local cpu_stats = M.GetCpuStats()
	local message = ""
	for _, stat in ipairs(cpu_stats) do
		message = message .. string.format("%-10s %-5f", stat.name, M.CalculateLoad(stat)) .. "\n"
	end
	return message
end

--- Calculates average cpu load among all cores
---@return number
function M.GetCpuLoadAverage()
	local cpu_stats = M.GetCpuStats()
	local sum = 0
	for _, stat in ipairs(cpu_stats) do
		sum = sum + M.CalculateLoad(stat)
	end
	return sum / #cpu_stats
end

---@class Stats
---@field cpu SingleCpuStat[] # cpu-core stats
---@field cpu_agg SingleCpuStat # Aggregated cpu stat
---@field ctxt number # The "ctxt" line gives the total number of context switches across all CPUs.
---@field btime number # timestamp of boot time
---@field processes number # Number of processes/threads created by fork/clone
---@field procs_running number # Number of running processes on cpu right now
---@field procs_blocked number # Number of waiting processes by i/o operations

---@enum DescriptorType
M.DescriptorTypes = utils.createEnum({
	STAT_FILE = 1,
})

-- DescriptorPaths = utils.createEnum({
-- 	[M.DescriptorTypes.STAT_FILE] = "/proc/stat",
-- })
--
-- ---@type table<DescriptorType, file*|nil>
-- DescriptorFiles = {
-- 	[M.DescriptorTypes.STAT_FILE] = nil,
-- }

---@class DescriptorInfo
---@field path string
---@field file file*|nil
---@field other table

---@type table<DescriptorType, DescriptorInfo>
DescriptorInfo = {
	[M.DescriptorTypes.STAT_FILE] = {
		path = "/proc/stat",
		file = nil,
		other = {},
	},
}

--- Opens system data file by enum DescriptorTypes
--- and returns file descriptor
---@param descriptor_type DescriptorType
function OpenDescriptorFile(descriptor_type)
	return io.open(DescriptorInfo[descriptor_type].path, "r")
end

--- Opens system data file and saves descriptor inside
--- internal DescriptorFiles table
---@param descriptor_type DescriptorType
function M.OpenDescriptorFileInternal(descriptor_type)
	DescriptorInfo[descriptor_type].file = OpenDescriptorFile(descriptor_type)
end

--- Returns true if descriptor file is opened false otherwise
---@param descriptor_type DescriptorType
---@return boolean
function M.IsDescriptorFileOpened(descriptor_type)
	return DescriptorInfo[descriptor_type].file ~= nil
end

--- Checks and raises error & aborts if input descriptor
--- file are not registered via OpenDescriptorFile
---@param descriptor_type DescriptorType
function M.ValidateDescriptorFile(descriptor_type)
	if not M.IsDescriptorFileOpened(descriptor_type) then
		error("Descriptor file with path " .. DescriptorInfo[descriptor_type].file .. " are nil")
	end
end

--- Read / parse /proc/stat file
function M.ReadStatFile()
	local type = M.DescriptorTypes.STAT_FILE
	M.ValidateDescriptorFile(type)
	local file = DescriptorInfo[type].file
	---@cast file file* Validation is not needed nil check
	--- was make inside M.ValidateDescriptorFile
	file:seek("set", 0)
	local data = file:read("*a")
	local stats = {}
	for line in string.gmatch(data, "[^\n]+") do
		local stat = M.CreateSingleCpuStat(line)
		if stat ~= nil then
			table.insert(stats, stat)
		else
			break
		end
	end
	return stats
end

return M
