local skynet = require "skynet"

local gateserver, fd = ...
fd = tonumber(fd)

skynet.start(function (  )
    skynet.call(gateserver, "lua", "kick", fd);
    skynet.exit()
end)