local skynet = require "skynet"
require "skynet.manager"

skynet.start(function (  )
    skynet.register(".testcallmsg")
    -- 发送lua类型的消息，发送成功，该函数将阻塞等待响应返回，r的值为响应返回值
    local r = skynet.call(".testluamsg", "lua", 1000, "skynet call", true)
    skynet.error("skynet.call return value ", r)

    r = skynet.unpack(skynet.rawcall(".testluamsg", "lua", skynet.pack(1001, "skynet rawcall", false)))
    skynet.error("skynet.rawcall return value ", r)

end)