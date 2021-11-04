local skynet = require "skynet"
require "skynet.manager"
local dns = require "skynet.dns"

local commands = {}

function commands.FLUSH(  )
    return dns.flush()
end

function commands.GETIP( domain )
    return dns.resolve(domain)
end

skynet.start(function (  )
    dns.server()
    skynet.dispatch("lua", function ( session, address, cmd, ... )
        cmd = cmd:upper()
        local f = commands[cmd]
        if f then
            skynet.retpack(f(...))
        else
            skynet.error(string.format( "Unknown command %s", tostring(cmd) ))
        end
    end)
    skynet.register(".dnsservice")
end)
