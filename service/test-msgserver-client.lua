local skynet = require "skynet"

skynet.start(function (  )
    local gate = skynet.newservice("test-msgserver")
    skynet.call(gate, "lua", "open", {
        port = 8001,
        maxclient = 64,
        servername = "sample"
    })

    local uid = "skynet001"
    local secret = "12345678"
    -- 告诉msgserver，uid这个用户可以登录
    local subid = skynet.call(gate, "lua", "login", uid, secret)
    skynet.error("lua login subid ", subid)

    -- 告诉msgserver, uid登出
    skynet.call(gate, "lua", "logout", uid, subid)

    -- 告诉msgserver, 踢出uid连接
    skynet.call(gate, "lua", "kick", uid, subid)

    -- 关闭gate，也就是关掉监听套接字
    skynet.call(gate, "lua", "close")
end)