local skynet = require "skynet"
local gateserver = require "snax.gateserver"
local netpack = require "skynet.netpack"

local handler = {}
local CMD = {}
local agents = {}

skynet.register_protocol({
    name = "client",
    id = skynet.PTYPE_CLIENT,
})

function CMD.kick(source, fd)
    skynet.error("source: ", skynet.address(source), "kick fd: ", fd);
    gateserver.closeclient(fd)
end

function handler.connect( fd, addr )
    skynet.error("client addr ", addr, "fd: ", fd)
    gateserver.openclient(fd)
    
    -- 连接成功就创建一个agent来代理
    local agent = skynet.newservice("test-gateserver-agent", fd)
    agents[fd] = agent
end

function handler.disconnect( fd )
    skynet.error("fd: ", fd, "disconnect")
    local agent = agents[fd]
    if agent then
        -- 通过发送quit消息的方式退出服务
        skynet.send(agent, "lua", "quit")
        agents[fd] = nil
    end
end

function handler.message( fd, msg, sz )
    skynet.error("recv message from fd: ", fd, netpack.tostring(msg, sz))
    local agent = agents[fd]
    skynet.redirect(agent, 0, "client", 0, msg, sz)
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

function handler.command( cmd, source, ... )
    local f = assert(CMD[cmd])
    return f(source, ...)
end
gateserver.start(handler)
