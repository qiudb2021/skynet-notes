local skynet = require "skynet"
skynet.start(function (  )
    skynet.error("Unique Service Start")
    -- 不要尝试服务初始化阶段退出服务，唯一服会创建失败
    -- skynet.exit()
end)
