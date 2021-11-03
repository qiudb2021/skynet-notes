local skynet = require "skynet"
local socket = require "skynet.socket"

local fd, addr = ...
fd = tonumber(fd)

local echo = function ( fd, addr )
    socket.start(fd)
    while true do
        local str = socket.read(fd)
        if str then
            skynet.error("recv "..str)
            socket.write(fd, string.upper( str ))
        else
            socket.close(fd)
            skynet.error(addr ..' disconnect')
        end
    end
end

skynet.start(function (  )
    skynet.fork(function(  )
        echo(fd, addr)
        skynet.exit()
    end)
end)