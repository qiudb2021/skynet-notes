local skynet = require "skynet"
require "skynet.manager"

skynet.start(function (  )
    skynet.dispatch("lua", function ( session, address, msg )
        skynet.retpack(msg:upper())
    end)
    skynet.register("globalluamsg")
end)