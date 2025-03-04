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

---@class MemoryBuffersCache
---@field buffers integer [Buffers] Temporary storage element in memory (usually ≤ 20 MB)
---@field cached integer [Cached] Page cache size (cache for files read from disk, includes tmpfs and shmem, excludes SwapCached)

---@class MemorySwapSpace
---@field swap_cached integer [SwapCached] Recently used swap memory, speeds up I/O
---@field swap_total integer [SwapTotal] Total swap space available in the system
---@field swap_free integer [SwapFree] Unused swap space (moved temporarily from RAM to disk)

---@class MemoryDiskWriteBack
---@field active integer [Active] Recently used memory, less suitable for new applications
---@field inactive integer [Inactive] Less recently used memory, more suitable for new applications
---@field active_anon integer [Active(anon)] Active anonymous memory
---@field inactive_anon integer [Inactive(anon)] Inactive anonymous memory
---@field active_file integer [Active(file)] Active file-backed memory
---@field inactive_file integer [Inactive(file)] Inactive file-backed memory

---@class MemoryMapped
---@field dirty integer [Dirty] Memory waiting to be written back to disk
---@field writeback integer [Writeback] Memory currently being written back
---@field writeback_tmp integer [WritebackTmp] Temporary buffer for writebacks used by the FUSE module

---@class MemoryShared
---@field shmem integer [Shmem] memory used by shared memory and tmpfs filesystem
---@field shmem_huge_pages integer [ShmemHugePages] memory used by shared memory and tmpfs with huge pages
---@field shmem_pmd_mapped integer [ShmemPmdMapped] userspace-mapped shared memory with huge pages

---@class MemoryKernel
---@field k_reclaimable integer [KReclaimable] reclaimable kernel memory
---@field slab integer [Slab] kernel-level data structures cache
---@field s_reclaimable integer [SReclaimable] reclaimable parts of Slab
---@field s_unreclaim integer [SUnreclaim] unreclaimable parts of Slab
---@field kernel_stack integer [KernelStack] memory for kernel stacks of tasks

---@class MemoryAllocationAvailability
---@field commit_limit integer [CommitLimit] amount of memory currently available for allocation
---@field committed_as integer [Committed_AS] amount of memory already allocated on the system

---@class MemoryVirtual
---@field page_tables integer [PageTables] memory consumed by page tables
---@field vmalloc_total integer [VmallocTotal] total size of vmalloc memory space
---@field vmalloc_used integer [VmallocUsed] size of used vmalloc memory space
---@field vmalloc_chunk integer [VmallocChunk] largest free contiguous block of vmalloc memory

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

---@class MemoryOther
---@field unevictable integer [Unevictable] Unreclaimable memory consumed by userspace (e.g., mlock-lock, ramfs backing, anonymous memfd pages)
---@field mlocked integer [Mlocked] Amount of memory locked with mlock
---@field nfs_unstable integer [NFS_Unstable] Network File System pages written to disk but not yet committed to stable storage (always zero)
---@field bounce integer [Bounce] Amount of memory for bounce buffers, low-level memory areas enabling devices to copy and write data
---@field percpu integer [Percpu] Memory used for the percpu interface allocations
---@field hardware_corrupted integer [HardwareCorrupted] Memory detected by the kernel as corrupted

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
---@field other MemoryOther

--- Read / parse /proc/stat file
---@param data string
---@return StatFileResult
function MemoryModule.FileHandleMemory:parse(data)
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

   local patterns = {
      general = {
         { "MemTotal", "total" },
         { "MemFree", "free" },
         { "MemAvailable", "available" },
      },
      buffers_cache = {
         { "Buffers", "buffers" },
         { "Cached", "cached" },
      },
      swap_space = {
         { "SwapCached", "swap_cached" },
         { "SwapTotal", "swap_total" },
         { "SwapFree", "swap_free" },
      },
      disk_write_back = {
         { "Active%(anon%)", "active_anon" },
         { "Inactive%(anon%)", "inactive_anon" },
         { "Active%(file%)", "active_file" },
         { "Inactive%(file%)", "inactive_file" },
         { "Active", "active" },
         { "Inactive", "inactive" },
      },
      mapped = {
         { "Dirty", "dirty" },
         { "WritebackTmp", "writeback_tmp" },
         { "Writeback", "writeback" },
      },
      shared = {
         { "ShmemHugePages", "shmem_huge_pages" },
         { "ShmemPmdMapped", "shmem_pmd_mapped" },
         { "Shmem", "shmem" },
      },
      kernel = {
         { "KReclaimable", "k_reclaimable" },
         { "Slab", "slab" },
         { "SReclaimable", "s_reclaimable" },
         { "SUnreclaim", "s_unreclaim" },
         { "KernelStack", "kernel_stack" },
      },
      allocation_availability = {
         { "CommitLimit", "commit_limit" },
         { "Committed_AS", "committed_as" },
      },
      virtual = {
         { "PageTables", "page_tables" },
         { "VmallocTotal", "vmalloc_total" },
         { "VmallocUsed", "vmalloc_used" },
         { "VmallocChunk", "vmalloc_chunk" },
      },
      huge_pages = {
         { "AnonHugePages", "anon_huge_pages" },
         { "FileHugePages", "file_huge_pages" },
         { "FilePmdMapped", "file_pmd_mapped" },
         { "HugePages_Total", "huge_pages_total" },
         { "HugePages_Free", "huge_pages_free" },
         { "HugePages_Rsvd", "huge_pages_rsvd" },
         { "HugePages_Surp", "huge_pages_surp" },
         { "Hugepagesize", "huge_page_size" },
         { "Hugetlb", "hugetlb" },
      },
      other = {
         { "Unevictable", "unevictable" },
         { "Mlocked", "mlocked" },
         { "NFS_Unstable", "nfs_unstable" },
         { "Bounce", "bounce" },
         { "Percpu", "percpu" },
         { "HardwareCorrupted", "hardware_corrupted" },
      },
   }

   -- Обработка каждой категории и её полей
   for category, patterns_list in pairs(patterns) do
      for _, pattern in ipairs(patterns_list) do
         local key, field = pattern[1], pattern[2]
         for line in string.gmatch(data, "[^\n]+") do
            if line:match("^" .. key) then
               total[category][field] = tonumber(utils.getWordAfterPrefix(line, key))
            end
         end
      end
   end

   return total
end

return MemoryModule
