local skynet = require "skynet"
local snax = require "skynet.snax"

skynet.start(function (  )
    local obj = snax.newservice("test-snax-service", 123, "abc", false)
    skynet.error("snax service", obj, "startup")

    local r = obj.req.echo("skynet")
    skynet.error("echo return: ", r)
end)