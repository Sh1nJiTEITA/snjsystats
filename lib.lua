M = {}

-- local utils = require("utils")
local desc = require("descriptor")
local m_stat = require("statfiles.stat")

function M.readStatFileOnce()
   desc.openDescriptorFileInternal(desc.DescriptorTypes.STAT_FILE)
   local data = desc.readFileData(desc.DescriptorTypes.STAT_FILE)
   return m_stat.readStatFile(data)
end
return M
