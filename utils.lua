M = {}

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

function M.createEnum(tbl)
	return setmetatable({}, {
		__index = tbl,
		__newindex = function(_, key, _)
			error("Attempt to modify enum: " .. tostring(key), 2)
		end,
	})
end
return M
