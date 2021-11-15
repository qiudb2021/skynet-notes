local skynet = require "skynet"

skynet.start(function (  )
    -- 启动loginserver监听8001
    local loginserver = skynet.newservice("test-loginserver2")
    -- 启动msgserver传递loginserver地址
    local gate = skynet.newservice("test-msgserver2", loginserver)
    -- 网关服务器需要发送lua open来打开，open是保留命令
    skynet.call(gate, "lua", "open", {
        port = 8002,
        maxclient = 64,
        servername = "sample"
    })
end)