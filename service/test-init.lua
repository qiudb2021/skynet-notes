--[[
    skynet.init用来注册服务初始化之前，需要执行的函数。也就是在skynet.start之前运行。
]]
local skynet = require "skynet"

skynet.init = function (  )
    skynet.error("service init.")
end

skynet.start = function (  )
    skynet.error("service start") 
end