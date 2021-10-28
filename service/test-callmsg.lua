local skynet = require "skynet"
require "skynet.manager"

skynet.start(function (  )
    skynet.register(".testcallmsg")
    -- 发送lua类型的消息，发送成功，该函数将阻塞等待响应返回，r的值为响应返回值
    local r = table.pack(skynet.call(".testluamsg", "lua", 1000, "skynet call", true))
    skynet.error("skynet.call return value ", r)

    r = table.pack(skynet.unpack(skynet.rawcall(".testluamsg", "lua", skynet.pack(1001, "skynet rawcall", false))))
    for k, v in pairs(r) do
        skynet.error("skynet.rawcall return value ", v)
        
    end
end)