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

function handler.error(fd, msg)
    gateserver.closeclient(fd)
end

function handler.warning(fd, size)
    skynet.error("warning fd = ", fd, "unsent data over 1MB")
end

function handler.open( source, conf )
    skynet.error("open by ", skynet.address(source))
    skynet.error("listen on ", conf.port)
    skynet.error("client max ", conf.maxclient)
    skynet.error("nodelay ", conf.nodelay)
end

gateserver.start(handler)
