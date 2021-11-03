local skynet = require "skynet"
local socket = require "skynet.socket"

local function client(id)
    local i = 0
    while i < 3 do
        skynet.error("send data"..i)
        socket.write(id, "data"..i.."\n")
        local str = socket.readline(id)
        if str then
            skynet.error("recv "..str)
        else
            skynet.error("disconnect")
        end
        i = i + 1;
    end
    socket.close(id)
    skynet.exit()
end

skynet.start(function (  )
    local serveraddr = "127.0.0.1:8001"
    skynet.error("connect "..serveraddr)
    local id = socket.open(serveraddr)
    skynet.fork(client, id)
end)
