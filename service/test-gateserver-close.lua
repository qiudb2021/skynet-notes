local skynet = require "skynet"
local gateserver = ...

skynet.start(function (  )
    skynet.call(gateserver, "lua", "close")
    skynet.exit()
end)