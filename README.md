# skynet-notes
## 服务别名API
```lua
local skynet = require "skynet"
require "skynet.manager"

-- 给当前服务取一个别名，可以是全局别名，也可以是本地别名
skynet.register(aliasname)
-- 给指定servicehandler的服务定一个别名，可以是全局别名，也可以是本地别名
skynet.name(aliasname, servicehandler)
-- 查询本地别名为aliasname的服务，返回servicehandler不存在就返回nil
skynet.localname(aliasname)
--[[
    查询别名为aliasname为服务，可以是本地别名也可以是全局别名
    1. 当查询本地别名时，返回servicehandler,不存在就返回nil
    2. 当查询全局别名时，返回servicehandler,不存在就阻塞等待到该服务初始化完成
]]
local skynet = require("skynet.harbor")
skynet.queryname(aliasname)
```
