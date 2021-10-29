local skynet = require "skynet"
require "skynet.manager"
local queue = require "skynet.queue"
local cs = queue()

local db = {}

local command = {};

function command.GET( key )
    skynet.sleep(1000)
    return db[key]
end

function command.SET( key, value )
    db[key] = value
end

skynet.start(function (  )
    skynet.dispatch("lua", function ( session, address, cmd, ... )
        cmd = cmd:upper()
        local f = command[cmd]
        if f then
            skynet.retpack(cs(f(...)))
        else
            skynet.error(string.format( "Unknown command %s", tostring(cmd) ))
        end
    end)

    skynet.register(".mydb")
end)
