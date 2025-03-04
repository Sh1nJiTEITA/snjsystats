Desc = {}

---@class Desc.DataFile
---@field path string|nil
---@field file file*|nil

Desc.DataFile = {}
Desc.DataFile.__index = Desc.DataFile

---@param data string
---@return table
function Desc.DataFile:parse(data)
   error("parse method for DataFile must be implemented")
end

---@return Desc.DataFile
function Desc.DataFile.New()
   local self = setmetatable({}, Desc.DataFile)
   self.path = nil
   self.file = nil
   return self
end

---
function Desc.DataFile:validate()
   print("validating...")
   if self.path == nil or self.file == nil then
      error("DataFile is not valid")
   end
end

function Desc.DataFile:read()
   self.file:seek("set", 0)
   return self.file:read("*a")
end

return Desc
