local skynet = require "skynet"
local socket = require "client.socket"
skynet.start(function (  )
    skynet.error("test-gateserver-client")
    local fd = socket.connect("127.0.0.1", 8001)
    assert(fd)
    local bytes = string.pack(">Hc13", 13, "login,101,134")
    socket.send(fd, bytes)
end)