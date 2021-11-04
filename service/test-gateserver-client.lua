local skynet = require "skynet"
local socket = require "skynet.socket"
local netpack = require "skynet.netpack"

skynet.start(function (  )
    local fd = socket.open("127.0.0.1", 8001)
    socket.write(fd, string.pack(">s2", "skynet"))
    skynet.exit()
end)