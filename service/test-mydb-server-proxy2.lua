local skynet = require "skynet"
require "skynet.manager"

-- 注册system消息
skynet.register_protocol({
    name = "system",
    id = skynet.PTYPE_SYSTEM,
    -- unpack直接返回不解包了
    unpack = function ( ... ) return ... end
})

local forward_map = {
    -- 发送到代理服务的lua消息全部
    [skynet.PTYPE_LUA] = skynet.PTYPE_SYSTEM,
    [skynet.PTYPE_RESPONSE] = skynet.PTYPE_RESPONSE
}

local realsrv = ...

skynet.forward_type(forward_map, function (  )
    skynet.dispatch("system", function( session, source, msg, sz )
        skynet.ret(skynet.rawcall(realsrv, "lua", msg, sz))
    end)
    skynet.register(".proxy")
end)