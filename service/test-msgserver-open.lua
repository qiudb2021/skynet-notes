local skynet = require "skynet"

skynet.start(function (  )
    local gate = skynet.newservice("test-msgserver")
    -- 给网关服务器发送lua open消息来打开
    skynet.call(gate, "lua", "open", {
        port = 8001,
        maxclient = 64,
        servername = "sample"
    })
end)