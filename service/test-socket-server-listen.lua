-- 专门负责监听
local skynet = require "skynet"
local socket = require "skynet.socket"

skynet.start(function ( ... )
    local addr = "0.0.0.0:8001"
    skynet.error("listen ", addr)
    local fd = socket.listen(addr)
    socket.start(fd, function ( clientfd, clientaddr )
        skynet.error(addr, " accepted")
        skynet.newservice("test-socket-server-agent", clientfd, clientaddr)
    end)
end)