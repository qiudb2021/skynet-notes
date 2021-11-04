local skynet = require "skynet"
local snax = require "skynet.snax"

skynet.start(function(  )
    local obj = snax.newservice("simplesnax",123,"abc",false)
    skynet.error("snax service", obj, "startup")

    local r = obj.post.hello(123, "abc", false)
    skynet.error("hello return: ", r)
    obj.post.quit("exit now")
end)