local skynet = require "skynet"
require "skynet.manager"

skynet.start(function (  )
    skynet.register('.testsendmsg')

    local testluamsg = skynet.localname(".testluamsg")
    -- 发送lua类型的消息给testluamsg，发送成功后立即返回，r的值为0
    -- 申请了c内存(msg, sz)已经用于发送，所以不用自己再释放内存
    local r = skynet.send(testluamsg, "lua", 1, "skynet", true)
    skynet.error("skynet.send return value: ", r)

    r = skynet.rawsend(testluamsg, "lua", skynet.pack(2, "skynet", false))
    skynet.error("skynet.rawsend return value: ", r)
end)