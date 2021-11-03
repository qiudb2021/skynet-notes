local skynet = require "skynet"
local cmd, domain = ...

local function task()
    local ip, ips = skynet.call(".dnsservice", "lua", cmd, domain)
    skynet.error("dnsservice Test: ", domain, ip)
    skynet.exit()
end

skynet.start(function (  )
    skynet.fork(task)
end)