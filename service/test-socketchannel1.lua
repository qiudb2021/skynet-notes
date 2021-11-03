local skynet = require "skynet"
require "skynet.manager"
local sc = require "skynet.socketchannel"

local channel = sc.channel({
    host = "127.0.0.1",
    port = 8001
})

local function response(sock)
    return true, sock:read()
end

local function task()
    local resp = nil
    local i = 0
    while i < 3 do
        resp = channel:request("data"..i.."\n", response)
        skynet.error("recv",resp)
        i = i + 1
    end

    channel:close()
    skynet.exit()
end

skynet.start(function(  )
    skynet.fork(task)
end)