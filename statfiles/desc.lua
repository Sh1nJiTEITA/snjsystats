M = {}

---@class DataFileHandle
---@field path string|nil
---@field file file*|nil
M.DataFileHandle = {
   path = nil,
   file = nil,
}

---
---@param o table
---@return DataFileHandle
function M.DataFileHandle:new(o)
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   return o
end

---
function M.DataFileHandle:destroy()
   if self.file ~= nil then
      io.close(self.file)
   end
end

---@return string
function M.DataFileHandle:read()
   self.file:seek("set", 0)
   return self.file:read("*a")
end

---@return table
function M.DataFileHandle:parse()
   error("Not implemented parse")
end

---@return string
function M.DataFileHandle:tostring()
   return string.format("DataFileHandle(path=%q, file=%s)", self.path, self.file)
end

return M
