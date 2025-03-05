MemoryModule = {}

package.path = package.path .. ";../?.lua;./?.lua;./statfiles/?.lua"

local desc = require("desc")
local utils = require("utils")

MemoryModule.FileHandleMemory = desc.DataFileHandle:new({})

function MemoryModule.FileHandleMemory:new(o)
   o = o or {}
   o.path = "/proc/meminfo"
   o.file = io.open(o.path, "r")
   setmetatable(o, self)
   self.__index = self
   return o
end

-- Class structure from https://www.baeldung.com/linux/proc-meminfo

---@class MemoryGeneral
---@field total integer [MemTotal] Total usable RAM
---@field free integer [MemFree] Free RAM
---@field available integer [MemAvailable] Available RAM for allocation
local MemoryGeneral = {}
function MemoryGeneral.new(data)
   return {
      total = data.total or 0,
      free = data.free or 0,
      available = data.available or 0,
   }
end

---@class MemoryBuffersCache
---@field buffers integer [Buffers] Temporary storage element in memory (usually ≤ 20 MB)
---@field cached integer [Cached] Page cache size (cache for files read from disk, includes tmpfs and shmem, excludes SwapCached)
local MemoryBuffersCache = {}
MemoryBuffersCache.__index = MemoryBuffersCache

---@param data table
---@return MemoryBuffersCache
function MemoryBuffersCache.new(data)
   return setmetatable({
      buffers = data.buffers or 0,
      cached = data.cached or 0,
   }, MemoryBuffersCache)
end

---@class MemorySwapSpace
---@field swap_cached integer [SwapCached] Recently used swap memory, speeds up I/O
---@field swap_total integer [SwapTotal] Total swap space available in the system
---@field swap_free integer [SwapFree] Unused swap space (moved temporarily from RAM to disk)
local MemorySwapSpace = {}
MemorySwapSpace.__index = MemorySwapSpace

---@param data table
---@return MemorySwapSpace
function MemorySwapSpace.new(data)
   return setmetatable({
      swap_cached = data.swap_cached or 0,
      swap_total = data.swap_total or 0,
      swap_free = data.swap_free or 0,
   }, MemorySwapSpace)
end

---@class MemoryDiskWriteBack
---@field active integer [Active] Recently used memory, less suitable for new applications
---@field inactive integer [Inactive] Less recently used memory, more suitable for new applications
---@field active_anon integer [Active(anon)] Active anonymous memory
---@field inactive_anon integer [Inactive(anon)] Inactive anonymous memory
---@field active_file integer [Active(file)] Active file-backed memory
---@field inactive_file integer [Inactive(file)] Inactive file-backed memory
local MemoryDiskWriteBack = {}
MemoryDiskWriteBack.__index = MemoryDiskWriteBack

---@param data table
---@return MemoryDiskWriteBack
function MemoryDiskWriteBack.new(data)
   return setmetatable({
      active = data.active or 0,
      inactive = data.inactive or 0,
      active_anon = data.active_anon or 0,
      inactive_anon = data.inactive_anon or 0,
      active_file = data.active_file or 0,
      inactive_file = data.inactive_file or 0,
   }, MemoryDiskWriteBack)
end

---@class MemoryMapped
---@field dirty integer [Dirty] Memory waiting to be written back to disk
---@field writeback integer [Writeback] Memory currently being written back
---@field writeback_tmp integer [WritebackTmp] Temporary buffer for writebacks used by the FUSE module
local MemoryMapped = {}
MemoryMapped.__index = MemoryMapped

---@param data table
---@return MemoryMapped
function MemoryMapped.new(data)
   return setmetatable({
      dirty = data.dirty or 0,
      writeback = data.writeback or 0,
      writeback_tmp = data.writeback_tmp or 0,
   }, MemoryMapped)
end

---@class MemoryShared
---@field shmem integer [Shmem] memory used by shared memory and tmpfs filesystem
---@field shmem_huge_pages integer [ShmemHugePages] memory used by shared memory and tmpfs with huge pages
---@field shmem_pmd_mapped integer [ShmemPmdMapped] userspace-mapped shared memory with huge pages
local MemoryShared = {}
MemoryShared.__index = MemoryShared

---@param data table
---@return MemoryShared
function MemoryShared.new(data)
   return setmetatable({
      shmem = data.shmem or 0,
      shmem_huge_pages = data.shmem_huge_pages or 0,
      shmem_pmd_mapped = data.shmem_pmd_mapped or 0,
   }, MemoryShared)
end

---@class MemoryKernel
---@field k_reclaimable integer [KReclaimable] reclaimable kernel memory
---@field slab integer [Slab] kernel-level data structures cache
---@field s_reclaimable integer [SReclaimable] reclaimable parts of Slab
---@field s_unreclaim integer [SUnreclaim] unreclaimable parts of Slab
---@field kernel_stack integer [KernelStack] memory for kernel stacks of tasks
local MemoryKernel = {}
MemoryKernel.__index = MemoryKernel

---@param data table
---@return MemoryKernel
function MemoryKernel.new(data)
   return setmetatable({
      k_reclaimable = data.k_reclaimable or 0,
      slab = data.slab or 0,
      s_reclaimable = data.s_reclaimable or 0,
      s_unreclaim = data.s_unreclaim or 0,
      kernel_stack = data.kernel_stack or 0,
   }, MemoryKernel)
end

---@class MemoryAllocationAvailability
---@field commit_limit integer [CommitLimit] amount of memory currently available for allocation
---@field committed_as integer [Committed_AS] amount of memory already allocated on the system
local MemoryAllocationAvailability = {}
MemoryAllocationAvailability.__index = MemoryAllocationAvailability

---@param data table
---@return MemoryAllocationAvailability
function MemoryAllocationAvailability.new(data)
   return setmetatable({
      commit_limit = data.commit_limit or 0,
      committed_as = data.committed_as or 0,
   }, MemoryAllocationAvailability)
end

---@class MemoryVirtual
---@field page_tables integer [PageTables] memory consumed by page tables
---@field vmalloc_total integer [VmallocTotal] total size of vmalloc memory space
---@field vmalloc_used integer [VmallocUsed] size of used vmalloc memory space
---@field vmalloc_chunk integer [VmallocChunk] largest free contiguous block of vmalloc memory
local MemoryVirtual = {}
MemoryVirtual.__index = MemoryVirtual

---@param data table
---@return MemoryVirtual
function MemoryVirtual.new(data)
   return setmetatable({
      page_tables = data.page_tables or 0,
      vmalloc_total = data.vmalloc_total or 0,
      vmalloc_used = data.vmalloc_used or 0,
      vmalloc_chunk = data.vmalloc_chunk or 0,
   }, MemoryVirtual)
end

---@class MemoryHugePages
---@field anon_huge_pages integer [AnonHugePages] anonymous huge pages mapped into page tables
---@field file_huge_pages integer [FileHugePages] memory consumed by page cache allocated with huge pages
---@field file_pmd_mapped integer [FilePmdMapped] mapped page cache in userspace with huge pages
---@field huge_pages_total integer [HugePages_Total] total size of huge pages pool
---@field huge_pages_free integer [HugePages_Free] amount of unallocated huge pages
---@field huge_pages_rsvd integer [HugePages_Rsvd] reserved huge pages for guaranteed allocation
---@field huge_pages_surp integer [HugePages_Surp] surplus huge pages above the base value
---@field huge_page_size integer [Hugepagesize] default size of huge pages
---@field hugetlb integer [Hugetlb] total amount of memory allocated for huge pages
local MemoryHugePages = {}
MemoryHugePages.__index = MemoryHugePages

---@param data table
---@return MemoryHugePages
function MemoryHugePages.new(data)
   return setmetatable({
      anon_huge_pages = data.anon_huge_pages or 0,
      file_huge_pages = data.file_huge_pages or 0,
      file_pmd_mapped = data.file_pmd_mapped or 0,
      huge_pages_total = data.huge_pages_total or 0,
      huge_pages_free = data.huge_pages_free or 0,
      huge_pages_rsvd = data.huge_pages_rsvd or 0,
      huge_pages_surp = data.huge_pages_surp or 0,
      huge_page_size = data.huge_page_size or 0,
      hugetlb = data.hugetlb or 0,
   }, MemoryHugePages)
end

---@class FileResultMemory
---@field general MemoryGeneral
---@field buffers_cache MemoryBuffersCache
---@field swap_space MemorySwapSpace
---@field disk_write_back MemoryDiskWriteBack
---@field mapped MemoryMapped
---@field shared MemoryShared
---@field kernel MemoryKernel
---@field allocation_availability MemoryAllocationAvailability
---@field virtual MemoryVirtual
---@field huge_pages MemoryHugePages
---@field other table
local FileResultMemory = {}
FileResultMemory.__index = FileResultMemory

---@param data table
---@return FileResultMemory
function FileResultMemory.new(data)
   return setmetatable({
      general = MemoryGeneral.new(data or {}),
      buffers_cache = MemoryBuffersCache.new(data or {}),
      swap_space = MemorySwapSpace.new(data or {}),
      disk_write_back = MemoryDiskWriteBack.new(data or {}),
      mapped = MemoryMapped.new(data or {}),
      shared = MemoryShared.new(data or {}),
      kernel = MemoryKernel.new(data or {}),
      allocation_availability = MemoryAllocationAvailability.new(data or {}),
      virtual = MemoryVirtual.new(data or {}),
      huge_pages = MemoryHugePages.new(data or {}),
      other = data or {},
   }, FileResultMemory)
end

--- Read / parse /proc/stat file
---@param data string
---@return FileResultMemory
function MemoryModule.FileHandleMemory:parse2(data)
   data = data or self:read()
   local total = {
      general = {},
      buffers_cache = {},
      swap_space = {},
      disk_write_back = {},
      mapped = {},
      shared = {},
      kernel = {},
      allocation_availability = {},
      virtual = {},
      huge_pages = {},
      other = {},
   }
   for line in string.gmatch(data, "[^\n]+") do
      -- stylua: ignore start
      if line:match("^" .. "MemTotal") then total["general"]["total"] = tonumber(utils.getWordAfterPrefix(line, "MemTotal"))
      elseif line:match("^" .. "MemFree") then total["general"]["free"] = tonumber(utils.getWordAfterPrefix(line, "MemFree"))
      elseif line:match("^" .. "MemAvailable") then total["general"]["available"] = tonumber(utils.getWordAfterPrefix(line, "MemAvailable"))
      --
      elseif line:match("^" .. "Buffers") then total["buffers_cache"]["buffers"] = tonumber(utils.getWordAfterPrefix(line, "Buffers"))
      elseif line:match("^" .. "Cached") then total["buffers_cache"]["cached"] = tonumber(utils.getWordAfterPrefix(line, "Cached"))
      --
      elseif line:match("^" .. "SwapCached") then total["swap_space"]["swap_cached"] = tonumber(utils.getWordAfterPrefix(line, "SwapCached"))
      elseif line:match("^" .. "SwapTotal") then total["swap_space"]["swap_total"] = tonumber(utils.getWordAfterPrefix(line, "SwapTotal"))
      elseif line:match("^" .. "SwapFree") then total["swap_space"]["swap_free"] = tonumber(utils.getWordAfterPrefix(line, "SwapFree"))

      --
      elseif line:match("^" .. "Active%(anon%)") then total["disk_write_back"]["active_anon"] = tonumber(utils.getWordAfterPrefix(line, "Active(anon)", {"%s", ":"}))
      elseif line:match("^" .. "Inactive%(anon%)") then total["disk_write_back"]["inactive_anon"] = tonumber(utils.getWordAfterPrefix(line, "Inactive(anon)", {"%s", ":"}))
      elseif line:match("^" .. "Active%(file%)") then total["disk_write_back"]["active_file"] = tonumber(utils.getWordAfterPrefix(line, "Active(file)", {"%s", ":"}))
      elseif line:match("^" .. "Inactive%(file%)") then total["disk_write_back"]["inactive_file"] = tonumber(utils.getWordAfterPrefix(line, "Inactive(file)", {"%s", ":"}))
      elseif line:match("^" .. "Active") then total["disk_write_back"]["active"] = tonumber(utils.getWordAfterPrefix(line, "Active"))
      elseif line:match("^" .. "Inactive") then total["disk_write_back"]["inactive"] = tonumber(utils.getWordAfterPrefix(line, "Inactive"))

      --
      elseif line:match("^" .. "Dirty") then total["mapped"]["dirty"] = tonumber(utils.getWordAfterPrefix(line, "Dirty"))
      elseif line:match("^" .. "WritebackTmp") then total["mapped"]["writeback_tmp"] = tonumber(utils.getWordAfterPrefix(line, "WritebackTmp"))
      elseif line:match("^" .. "Writeback") then total["mapped"]["writeback"] = tonumber(utils.getWordAfterPrefix(line, "Writeback"))

      --
      elseif line:match("^" .. "ShmemHugePages") then total["shared"]["shmem_huge_pages"] = tonumber(utils.getWordAfterPrefix(line, "ShmemHugePages"))
      elseif line:match("^" .. "ShmemPmdMapped") then total["shared"]["shmem_pmd_mapped"] = tonumber(utils.getWordAfterPrefix(line, "ShmemPmdMapped"))
      elseif line:match("^" .. "Shmem") then total["shared"]["shmem"] = tonumber(utils.getWordAfterPrefix(line, "Shmem"))

      --
      elseif line:match("^" .. "KReclaimable") then total["kernel"]["k_reclaimable"] = tonumber(utils.getWordAfterPrefix(line, "KReclaimable"))
      elseif line:match("^" .. "Slab") then total["kernel"]["slab"] = tonumber(utils.getWordAfterPrefix(line, "Slab"))
      elseif line:match("^" .. "SReclaimable") then total["kernel"]["s_reclaimable"] = tonumber(utils.getWordAfterPrefix(line, "SReclaimable"))
      elseif line:match("^" .. "SUnreclaim") then total["kernel"]["s_unreclaim"] = tonumber(utils.getWordAfterPrefix(line, "SUnreclaim"))
      elseif line:match("^" .. "KernelStack") then total["kernel"]["kernel_stack"] = tonumber(utils.getWordAfterPrefix(line, "KernelStack"))

      --
      elseif line:match("^" .. "CommitLimit") then total["allocation_availability"]["commit_limit"] = tonumber(utils.getWordAfterPrefix(line, "CommitLimit"))
      elseif line:match("^" .. "Committed_AS") then total["allocation_availability"]["committed_as"] = tonumber(utils.getWordAfterPrefix(line, "Committed_AS", {"%s", ":"}))

      --
      elseif line:match("^" .. "PageTables") then total["virtual"]["page_tables"] = tonumber(utils.getWordAfterPrefix(line, "PageTables"))
      elseif line:match("^" .. "VmallocTotal") then total["virtual"]["vmalloc_total"] = tonumber(utils.getWordAfterPrefix(line, "VmallocTotal"))
      elseif line:match("^" .. "VmallocUsed") then total["virtual"]["vmalloc_used"] = tonumber(utils.getWordAfterPrefix(line, "VmallocUsed"))
      elseif line:match("^" .. "VmallocChunk") then total["virtual"]["vmalloc_chunk"] = tonumber(utils.getWordAfterPrefix(line, "VmallocChunk"))

      --
      elseif line:match("^" .. "AnonHugePages") then total["huge_pages"]["anon_huge_pages"] = tonumber(utils.getWordAfterPrefix(line, "AnonHugePages"))
      elseif line:match("^" .. "FileHugePages") then total["huge_pages"]["file_huge_pages"] = tonumber(utils.getWordAfterPrefix(line, "FileHugePages"))
      elseif line:match("^" .. "FilePmdMapped") then total["huge_pages"]["file_pmd_mapped"] = tonumber(utils.getWordAfterPrefix(line, "FilePmdMapped"))
      elseif line:match("^" .. "HugePages_Total") then total["huge_pages"]["huge_pages_total"] = tonumber(utils.getWordAfterPrefix(line, "HugePages_Total", {"%s", ":"}))
      elseif line:match("^" .. "HugePages_Free") then total["huge_pages"]["huge_pages_free"] = tonumber(utils.getWordAfterPrefix(line, "HugePages_Free", {"%s", ":"}))
      elseif line:match("^" .. "HugePages_Rsvd") then total["huge_pages"]["huge_pages_rsvd"] = tonumber(utils.getWordAfterPrefix(line, "HugePages_Rsvd", {"%s", ":"}))
      elseif line:match("^" .. "HugePages_Surp") then total["huge_pages"]["huge_pages_surp"] = tonumber(utils.getWordAfterPrefix(line, "HugePages_Surp", {"%s", ":"}))
      elseif line:match("^" .. "Hugepagesize") then total["huge_pages"]["huge_page_size"] = tonumber(utils.getWordAfterPrefix(line, "Hugepagesize"))
      elseif line:match("^" .. "Hugetlb") then total["huge_pages"]["hugetlb"] = tonumber(utils.getWordAfterPrefix(line, "Hugetlb"))

      --
      elseif line:match("^" .. "Unevictable") then total["other"]["unevictable"] = tonumber(utils.getWordAfterPrefix(line, "Unevictable"))
      elseif line:match("^" .. "Mlocked") then total["other"]["mlocked"] = tonumber(utils.getWordAfterPrefix(line, "Mlocked"))
      elseif line:match("^" .. "NFS_Unstable") then total["other"]["nfs_unstable"] = tonumber(utils.getWordAfterPrefix(line, "NFS_Unstable", {"%s", ":"}))
      elseif line:match("^" .. "Bounce") then total["other"]["bounce"] = tonumber(utils.getWordAfterPrefix(line, "Bounce"))
      elseif line:match("^" .. "Percpu") then total["other"]["percpu"] = tonumber(utils.getWordAfterPrefix(line, "Percpu"))
      elseif line:match("^" .. "HardwareCorrupted") then total["other"]["hardware_corrupted"] = tonumber(utils.getWordAfterPrefix(line, "HardwareCorrupted"))

      -- stylua: ignore end
      end
   end
   return total
end

function MemoryModule.FileHandleMemory:parse(data)
   data = data or self:read()
   local parsed = {}
   for line in data:gmatch("[^\n]+") do
      local key = nil
      local value = nil
      for word in line:gmatch("[^:%s]+") do
         if word ~= "kB" then
            local num = tonumber(word)
            if num ~= nil then
               value = num
            else
               key = word
            end
         end
         if key and value then
            parsed[key] = value
            key = nil
            value = nil
         end
      end
   end
   return FileResultMemory.new(parsed)
end

return MemoryModule
