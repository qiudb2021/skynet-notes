local skynet = require "skynet"
local socket = require "skynet.socket"

function echo( fd, addr )
    socket.start(fd)
    while true do
        local str = socket.read(fd)
        if str then
            skynet.error("recv from( ", addr, ")", str)
            socket.write(fd, string.upper( str ))
        else
            socket.close(fd)
            skynet.error(addr, ' disconnect')
            return
        end
    end
end

local function accept(fd, addr)
    skynet.error(addr, "accepted")
    -- 来一个连接，就开一个协程来处理客户端数据
    skynet.fork(echo, fd, addr)
end

skynet.start(function (  )
    local addr = "0.0.0.0:8001"
    skynet.error("listen "..addr)
    local fd = socket.listen(addr)
    assert(fd)
    socket.start(fd, accept)
end)
