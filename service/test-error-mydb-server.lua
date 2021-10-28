local skynet = require "skynet"
require "skynet.manager"
local db = {}

local command = {};

function command.GET( key )
    return db[key]
end

function command.SET( key, value )
    db[key] = value
end

skynet.start(function (  )
    skynet.dispatch("lua", function ( session, address, cmd, ... )
        -- 这个协程接收消息
        skynet.error("lua dispatch ", coroutine.running( ))
        -- 开启一个新的协程来处理响应
        skynet.fork(function ( cmd, ... )
            skynet.error("fork ", coroutine.running( ))
            cmd = cmd:upper()
            local f = command[cmd]
            if f then
                skynet.retpack(f(...))
            else
                skynet.error(string.format( "Unknown command %s", tostring(cmd) ))
            end
        end, cmd, ...)
        
    end)

    skynet.register(".mydb")
end)
