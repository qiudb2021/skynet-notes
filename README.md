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
local harbor = require("skynet.harbor")
harbor.queryname(aliasname)
```
## 服务调度
```lua
local skynet = require "skynet"
-- 让当前任务等待time * 0.01s
skynet.sleep(time)
-- 启动一个新的任务去执行函数func，其实就是开了一个协程，函数调用完成将返回线程句柄
-- 虽然你也可以使用原生的coroutine.create来创建协程，但是会打断skynet的工作流程
skynet.fork(func, ...)
-- 让出当前任务执行流程，使本服务内其它任务有机会执行，随机继续执行
skynet.yield()
-- 让出当前任务执行流程，等待wakeup唤醒它
skynet.wait()
-- 唤醒用wait或sleep处于等待状态的任务
skynet.wakeup(co)
-- 设定一个定时触发函数func，在time*0.01s后触发
skynet.timeout(time, func)
-- 返回当前进程的启动UTC时间（秒）
skynet.starttime()
-- 返回当前进程启动后经过的时(0.0.s)
skynet.now()
-- 通过starttime和now计算出当前UTC时间
skynet.time()
```
