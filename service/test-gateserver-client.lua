local skynet = require "skynet"
local socket = require "client.socket"
local netpack = require "skynet.netpack"

skynet.start(function (  )
    local fd = socket.connect("127.0.0.1", 8001)
    socket.send(fd, string.pack(">s2", "skynet"))
    skynet.exit()
end)