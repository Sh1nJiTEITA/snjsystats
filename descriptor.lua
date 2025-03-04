Desc = {}

local utils = require("utils")

---@enum DescriptorType
Desc.DescriptorTypes = utils.createEnum({
   STAT_FILE = 1,
})

--- Default base descriptor info class
---@class DescriptorInfo
---@field path string
---@field file file*|nil
---@field other table

---@type table<DescriptorType, DescriptorInfo>
DescriptorInfo = {
   [Desc.DescriptorTypes.STAT_FILE] = {
      path = "/proc/stat",
      file = nil,
      other = {},
   },
}

--- Opens system data file by enum DescriptorTypes
--- and returns file descriptor
---@param descriptor_type DescriptorType
local function openDescriptorFile(descriptor_type)
   return io.open(DescriptorInfo[descriptor_type].path, "r")
end

--- Opens system data file and saves descriptor inside
--- internal DescriptorFiles table
---@param descriptor_type DescriptorType
function Desc.openDescriptorFileInternal(descriptor_type)
   DescriptorInfo[descriptor_type].file = openDescriptorFile(descriptor_type)
end

--- Returns true if descriptor file is opened false otherwise
---@param descriptor_type DescriptorType
---@return boolean
function Desc.isDescriptorFileOpened(descriptor_type)
   return DescriptorInfo[descriptor_type].file ~= nil
end

--- Checks and raises error & aborts if input descriptor
--- file are not registered via OpenDescriptorFile
---@param descriptor_type DescriptorType
function Desc.validateDescriptorFile(descriptor_type)
   if not Desc.isDescriptorFileOpened(descriptor_type) then
      error("Descriptor file with path " .. DescriptorInfo[descriptor_type].file .. " are nil")
   end
end

---@param descriptor_type DescriptorType
---@return string
function Desc.readFileData(descriptor_type)
   Desc.validateDescriptorFile(descriptor_type)
   local file = DescriptorInfo[descriptor_type].file
   ---@cast file file* Validation is not needed nil check
   --- it was made inside Desc.ValidateDescriptorFile
   file:seek("set", 0)
   return file:read("*a")
end

return Desc
