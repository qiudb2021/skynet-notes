local skynet = require "skynet"
local gateserver = require "snax.gateserver"
local netpack = require "skynet.netpack"

local handler = {}

function handler.connect( fd, addr )
    skynet.error("client addr ", addr, "fd: ", fd)
    gateserver.openclient(fd)
end

function handler.disconnect( fd )
    skynet.error("fd: ", fd, "disconnect")
end

function handler.message( fd, msg, sz )
    skynet.error("recv message from fd: ", fd, netpack.tostring(msg, sz))
end

gateserver.start(handler)
