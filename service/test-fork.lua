local skynet = require "skynet"

function task( timeout )
    skynet.error("start co: ", coroutine.running( ))
    skynet.error("begin sleep")
    skynet.sleep(timeout)
    skynet.error("begin end")
end

skynet.start(function (  )
    skynet.error("start co: ", coroutine.running( ))
    skynet.fork(task, 5000)
end)
