local S = require("posix.sys.socket")
local utils = require("utils")

M = {}

function M.CreateEmptySocket(path)
	os.remove(path)

	local sockd = S.socket(S.AF_UNIX, S.SOCK_STREAM, 0)
	assert(S.bind(sockd, {
		family = S.AF_UNIX,
		path = path,
	}))
	return sockd
end

function M.RunSocket(socket)
	assert(S.listen(socket, 10))
	while true do
		local client, address = S.accept(socket)
		if client then
			local str, err = S.recv(client, 4096)
			if str then
				S.send(client, "hi where")
				if str == "hi" then
					print("jjj")
				end
			else
				print("Cant get import message: ", err)
			end

			S.shutdown(client, S.SHUT_RDWR)
		else
			print("Invalid connection" .. address)
		end
	end
end

print("Сервер работает и ждет подключения...")

local socket_path = "/home/snj/.local/share/stat_daemon"
local socket = M.CreateEmptySocket(socket_path)
M.RunSocket(socket)
