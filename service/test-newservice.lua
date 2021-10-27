local skynet = require "skynet"
skynet.start(function (  )
    skynet.error("My new service")
    skynet.newservice("test")
    skynet.error("new test service.")
end)