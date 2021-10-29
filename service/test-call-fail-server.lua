local skynet = require "skynet"
require "skynet.manager"

skynet.start(function (  )
    skynet.dispatch('lua', function ( session, address, cmd, ... )
        -- 在接收到消息时退出服务
        skynet.exit()
    end)
    skynet.register("./noresponse")
end)