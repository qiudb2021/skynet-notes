local skynet = require "skynet"
local snax = require "skynet.snax"

skynet.start(function (  )
    local obj = snax.uniqueservice("test-snax-service", 123, "abc")
    obj = snax.queryservice("test-snax-service")
    snax.kill(obj, 123, "abc")

    local gobj = snax.globalservice("test-snax-service", 456, "efg")
    obj = snax.queryglobal("test-snax-service")
    snax.kill(obj, 456, 'efg')
end)