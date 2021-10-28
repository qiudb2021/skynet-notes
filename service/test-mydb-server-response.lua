local skynet = require "skynet"
require "skynet.manager"

local db = {}
local command = {}
function command.GET( key )
    return db[key]
end

function command.SET( key, value )
    db[key] = value
end

skynet.start(function (  )
    skynet.dispatch("lua", function ( session, address, cmd, ... )
        local response = skynet.response(skynet.pack)
        skynet.fork(function ( cmd, ... )
            skynet.sleep(500)
            cmd = cmd:upper()
            local f = command[cmd]
            if f then
                response(true, f(...))
            else
                skynet.error(string.format( "Unknown command %s", tostring(cmd) ))
            end
        end, cmd, ...)
    end)
    skynet.register(".mydb")
end)
