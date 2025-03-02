M = {}

--- Simple convert lua table to string
---@param tbl table to convert
---@param indent string start indent
---@return string
function M.dump(tbl, indent)
   indent = indent or ""
   local str = "{\n"
   local nextIndent = indent .. "  "

   for k, v in pairs(tbl) do
      local key = type(k) == "string" and string.format("%q", k) or k
      local value

      if type(v) == "table" then
         value = M.dump(v, nextIndent)
      elseif type(v) == "string" then
         value = string.format("%q", v)
      else
         value = tostring(v)
      end

      str = str .. nextIndent .. "[" .. key .. "] = " .. value .. ",\n"
   end

   return str .. indent .. "}"
end

--- Creates immutable table
---@param tbl table table to make immutable
---@return table
function M.createEnum(tbl)
   return setmetatable({}, {
      __index = tbl,
      __newindex = function(_, key, _)
         error("Attempt to modify enum: " .. tostring(key), 2)
      end,
   })
end

--- Default map from other languages.
--- Applies input function to values inside
--- table t
---@param t table table to work with
---@param func function func to apply at
---@return table
function M.map(t, func)
   local result = {}
   for k, v in pairs(t) do
      result[k] = func(v)
   end
   return result
end

--- Capture words divided by spaces after prefix
--- found in input line
---@param line string line to parse
---@param prefix string prefix to find before capturing values
---@param n integer? number of words to capture after prefix
---@param sep string|table<string>? possible separators
---@return table<string>
--- @example
--- line = "some_prefix 10 20 30 1499"
--- values = GetMultipleWordsAfterPrefix(line, "some_prefix" 3)
---
--- print(values)
--- =============
--- { 10, 20, 30}
function M.GetWordsAfterPrefix(line, prefix, n, sep)
   n = n or 0
   local pattern = "%w+"
   if sep == nil then
      pattern = "%w+"
   elseif type(sep) == "string" then
      pattern = "([^" .. sep .. "]+)"
   elseif type(sep) == "table" then
      pattern = "([^" .. table.concat(sep) .. "]+)"
   end

   local values = {}
   local found_prefix = false

   for word in string.gmatch(line, pattern) do
      if n ~= 0 and #values == n then
         break
      end
      if word == prefix then
         found_prefix = true
      elseif found_prefix then
         table.insert(values, word)
      end
   end

   if not found_prefix then
      error('Input prefix "' .. prefix .. '" was not found in input line')
   end

   return values
end

--- Captures single word from line divided by spaces
--- after prefix
---@param line string line to parse
---@param prefix string prefix to find
---@param sep? string|table<string> prefix to find
---@return string
function M.GetWordAfterPrefix(line, prefix, sep)
   return M.GetWordsAfterPrefix(line, prefix, 1, sep)[1]
end

return M
