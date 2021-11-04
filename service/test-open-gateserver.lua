local skynet = require "skynet"

skynet.start(function (  )
    skynet.error("Gate Server start")
    -- 启动网关服务
    local gateserver = skynet.newservice("test-gate-server")
    -- 需要给网关服务发送open消息，来启动监听
    skynet.call(gateserver, "lua", "open", {
        port = 8001, -- 监听端口
        maxclient = 50, -- 客户端最大连接数
        nodelay = true, -- 是否延迟TCP
    })

    skynet.error("gate server startup on ", 8001)
    skynet.exit()
end)