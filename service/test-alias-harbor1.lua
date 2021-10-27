local skynet = require "skynet"
require "skynet.manager"
local harbor = require "skynet.harbor"

skynet.start(function (  )
    local handle = skynet.newservice("test")

    skynet.name(".testalias", handle)
    skynet.name("testalias", handle)
end)