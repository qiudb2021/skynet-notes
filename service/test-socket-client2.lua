local skynet = require "skynet"
local socket = require "skynet.socket"

local function recv(id)
    local i = 0
    while i < 3 do
        local str = socket.readline(id)
        if str then
            skynet.error("recv "..str)
        else
            skynet.error('disconnect')
        end
        i = i + 1
    end

    socket.close(id)
    skynet.exit()
end

local function send(id)
    local i = 0
    while i < 3 do
        skynet.error("send data"..i)
        socket.write(id, "data"..i.."\n")
        i = i + 1
    end
end

skynet.start(function ( )
    local addr = "127.0.0.1:8001"
    skynet.error("connect "..addr)
    local id = socket.open(addr)

    -- 启动读协程
    skynet.fork(recv, id)
    -- 启动写协程
    skynet.fork(send, id)
end)