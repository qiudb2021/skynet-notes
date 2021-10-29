local skynet = require "skynet"

local source, dest = ...
skynet.start(function (  )
    source = skynet.localname(source)
    dest = skynet.localname(dest)
    skynet.redirect(source, dest, "lua",0, skynet.pack("skynet", 8.8, false))
end)
