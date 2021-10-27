local skynet = require "skynet"
require "skynet.manager"
local harbor = require "skynet.harbor"

skynet.start(function (  )
    local handle = skynet.localname(".testalias")
    skynet.error("localname .testalias handle", skynet.address(handle))

    handle = skynet.localname("testalias")
    skynet.error("localname testalias handle", skynet.address(handle))

    -- 查询本地别名不阻塞
    handle = harbor.queryname(".testalias")
    skynet.error("harbor.queryname .testalias handle ", skynet.address(handle))

    -- 查询全局别名阻塞
    handle = harbor.queryname("testalias")
    skynet.error("harbor.queryname testalias handle ", skynet.address(handle))
    
end)