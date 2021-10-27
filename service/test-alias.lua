local skynet = require "skynet"
require "skynet.manager"
local harbor = require "skynet.harbor"

skynet.start(function (  )
    local handler = skynet.newservice("test")
    -- 本地别名
    skynet.name(".testalias", handler)
    -- 全局别名
    skynet.name("testalias", handler)

    handler = skynet.localname('.testalias')
    skynet.error("localname .testalias handler ", skynet.address(handler))

    -- 只能查询本地别名，不能查询全局别名
    handler = skynet.localname("testalias")
    skynet.error("localname testalias handler ", skynet.address(handler))

    handler = harbor.queryname(".testalias")
    skynet.error("queryname .testalias handler ", skynet.address(handler))

    handler = harbor.queryname("testalias")
    skynet.error("queryname testalias handler ", skynet.address(handler))
end)