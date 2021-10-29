local skynet = require "skynet"
require "skynet.manager"

local realsvr = ...

skynet.start(function (  )
    skynet.dispatch("lua", function ( session, source, ... )
        skynet.ret(skynet.rawcall(realsvr, "lua", skynet.pack(...)))
    end)
    skynet.register(".proxy")
end)