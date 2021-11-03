local skynet = require "skynet"
require "skynet.manager"
local sc = require "skynet.socketchannel"

local function dispatch(sock)
    local r = sock:readline()
    local session = tonumber(strinbstring.sub( r, 5 ))
    return session, true, r
end

local channel = sc.channel({
    host = "127.0.0.1",
    port = 8001,
    response = dispatch
})

local function task()
    local resp
    local i = 0
    while i < 3 do
        skynet.fork(function ( session )
            resp = channel:request("data"..i.."\n", session)
            skynet.error("recv", resp, session)
        end)
    end
end

skynet.start(function(  )
    skynet.fork(task)
end)