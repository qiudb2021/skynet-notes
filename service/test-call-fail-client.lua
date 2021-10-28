local skynet = require "skynet"

local function task()
    local r = skynet.call(".noresponse", "lua", "get")
    skynet.error("get Test",  r)
end

skynet.start(function (  )
    skynet.fork(task)
end)