M = {}

package.path = package.path .. ";../?.lua;./?.lua;./statfiles/?.lua"

local desc = require("desc")
local utils = require("utils")

M.StatFileHandle = desc.DataFileHandle:new({})

function M.StatFileHandle:new(o)
   o = o or {}
   o.path = "/proc/stat"
   o.file = io.open(o.path, "r")
   setmetatable(o, self)
   self.__index = self
   return o
end

--- Cpu statistics from /proc/stat
---@class CpuStat
---@field name string    Cpu name
---@field user number    1. Normal processes executing in user mode
---@field nice number	 2. Niced processes executing in user mode
---@field system number  3. Processes executing in kernel mode
---@field idle number    4. Twiddling thumbs
---@field iowait number  5. Waiting for I/O to complete
---@field irq number     6. Servicing interrupts
---@field softirq number 7. Servicing softirqs

---@class SoftirqStat
---@field total number        1. Number of total softirq calls
---@field net_rx number       1. Number of processed input packets
---@field net_tx number       2. Number of processed output packets
---@field block number        3. Number of blocks
---@field irq_poll number     4. Number of processing of tasks in the kernel that require periodic interrupt polling
---@field tasklet number      5. Number of tasks processed in tasklet
---@field timer number        6. Number of processing of timers
---@field net_rx_error number 7. Number of errors related to processing incoming network packates
---@field sched number        8. Number of processings of tasks related to process scheduling

--- Special class from handling info from /proc/stat
---@class StatFileResult
---@field agg_cpu CpuStat      Aggregated cpu data
---@field cpus CpuStat[]       Cpu data for each core
---@field intr number          Count of interrupts since boot time
---@field ctxt number          Count of all context switches across all CPUs
---@field btime number         Timestamp at which system was booted
---@field processes number     Count of created processes/threads within fork() & clone()
---@field procs_running number Count of currently running processes on CPUs
---@field procs_blocked number Count of currently blocked processes, waiting for i/o
---@field softirq SoftirqStat  ...

local function createSingleCpuStat(line)
   local cpu_name = line:match("^%S+")
   local words = utils.getWordsAfterPrefix(line, cpu_name)
   return {
      name = cpu_name,
      user = words[1],
      nice = words[2],
      system = words[3],
      idle = words[4],
      iowait = words[5],
      irq = words[6],
      softirq = words[7],
   }
end

--- Read / parse /proc/stat file
---@param data string
---@return StatFileResult
function M.StatFileHandle:parse(data)
   data = data or self:read()

   -- local data = desc.ReadFileData(lib.DescriptorTypes.STAT_FILE)
   local stats = { cpus = {} }

   for line in string.gmatch(data, "[^\n]+") do
      -- stylua: ignore start

      -- [ agg_cpu ] -- Aggregated cpu data
      if line:match("^" .. "cpu ") then
         local stat = createSingleCpuStat(line)
         if stat ~= nil then
            stats["agg_cpu"] = stat
         end

      -- [ cpus[] ] -- Cpu core data
      elseif line:match("^" .. "cpu") then
            local stat = createSingleCpuStat(line)
            if stat ~= nil then
               table.insert(stats.cpus, stat)
            end

      -- [ intr ] -- Count of interrupts since boot time
      elseif line:match("^" .. "intr") then
            stats["intr"] = tonumber(utils.getWordAfterPrefix(line, "intr"))
      elseif line:match("^" .. "ctxt") then
            stats["ctxt"] = tonumber(utils.getWordAfterPrefix(line, "ctxt"))
      elseif line:match("^" .. "btime") then
            stats["btime"] = tonumber(utils.getWordAfterPrefix(line, "btime"))
      elseif line:match("^" .. "processes") then
            stats["processes"] = tonumber(utils.getWordAfterPrefix(line, "processes"))
      elseif line:match("^" .. "procs_running") then
            stats["procs_running"] = tonumber(utils.getWordAfterPrefix(line, "procs_running", "%s+"))
      elseif line:match("^" .. "procs_blocked") then
            stats["procs_blocked"] = tonumber(utils.getWordAfterPrefix(line, "procs_blocked", "%s+"))
      elseif line:match("^" .. "softirq") then
            local softirq_data = utils.map(utils.getWordsAfterPrefix(line, "softirq"), tonumber)
            stats["softirq"] =  {
	    	net_rx = softirq_data[1],
	    	net_tx = softirq_data[2],
	    	block = softirq_data[3],
	    	irq_poll = softirq_data[4],
	    	tasklet = softirq_data[5],
	    	timer = softirq_data[6],
	    	net_rx_error = softirq_data[7],
	    	sched = softirq_data[8],
            }
      end
      -- stylua: ignore end
   end
   return stats
end

return M
