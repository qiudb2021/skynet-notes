local skynet = require "skynet"

skynet.start(function (  )
    skynet.error("begin sleep")
    skynet.sleep(500)
    skynet.error("begin end")
end)