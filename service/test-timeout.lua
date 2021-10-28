local skynet = require "skynet"

function task(  )
    skynet.error("task", coroutine.running( ))
end

skynet.start(function (  )
    skynet.error("start", coroutine.running( ))
    -- 5秒后运行task函数：
    skynet.timeout(500, task)
end)