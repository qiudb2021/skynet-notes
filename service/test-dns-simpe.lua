local skynet = require "skynet"
local dns = require "skynet.dns"

skynet.start(function (  )
    -- 设置dns服务器地址
    skynet.error('nameserver: ', dns.server())

    -- 调用成功，则把结果缓存到这个服务的内存中，便于下次使用
    local ip, ips = dns.resolve("github.com")
    skynet.error("dns.resolve return ", ip)

    for k, v in ipairs(ips) do
        skynet.error("github.com ", v)
    end
    dns.flush()
end)