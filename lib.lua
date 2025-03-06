local lib = {}

-- local utils = require("utils")
local desc = require("descriptor")
local m_stat = require("statfiles.stat")

function lib.readStatFileOnce()
	desc.openDescriptorFileInternal(desc.DescriptorTypes.STAT_FILE)
	local data = desc.readFileData(desc.DescriptorTypes.STAT_FILE)
	return m_stat.parse(data)
end
return lib
