local skynet = require "skynet"
local snax = require "skynet.snax"

-- snax服务初始化时会调用该回调函数，可以获取到启动参数
function init( ... )
    skynet.error("snax server start: ", ...)
end

-- snax服务退出时会调用该回调函数，可以获取到退出参数
function exit( ... )
    skynet.error("snax server exit: ", ...)
end
