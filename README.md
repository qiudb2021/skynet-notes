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
## 服务间消息通信
### 消息类型
```c
skynet.h

#define PTYPE_TEXT 0
#define PTYPE_RESPONSE 1    // 表示一个回应包
#define PTYPE_MULTICAST 2   // 广播消息
#define PTYPE_CLIENT 3      // 用来处理网络客户端的请求消息
#define PTYPE_SYSTEM 4      // 系统消息
#define PTYPE_HARBOR 5      // 跨节点消息
#define PTYPE_SOCKET 6      // 套接字消息
// read lualib/skynet.lua examples/simplemonitor.lua
#define PTYPE_ERROR 7	    // 错误消息
// read lualib/skynet.lua lualib/mqueue.lua lualib/snax.lua
#define PTYPE_RESERVED_QUEUE 8
#define PTYPE_RESERVED_DEBUG 9
#define PTYPE_RESERVED_LUA 10   //lua类型的消息
#define PTYPE_RESERVED_SNAX 11  //snax服务消息

#define PTYPE_TAG_DONTCOPY 0x10000
#define PTYPE_TAG_ALLOCSESSION 0x20000
```
```lua
local skynet = require "skynet"
-- 为type类型的消息设定消息处理函数func
-- 当一个服务收到消息时，Skynet会开启新的协程并调用它
skynet.dispatch(type, func)
-- session：消息的唯一id
-- source: 消息来源
-- cmd: 消息名
local func = function (session, source, cmd, ...)
    ...
end

-- 消息打包,返回两个参数：
-- 1. msg: (C指针)指向的数据包起始地址，
-- 2. sz: 数据包的长度
local msg, sz = skynet.pack(...)
-- 消息解包
skynet.unpack(msg, sz)
-- 用type类型向addr发送未打包的消息。该函数会自动把...参数列表进行打包，默认情况下lua消息使用skynet.pack打包
-- addr: 可以是服务句柄，也可以是服务别名
skynet.send(addr, type, ...)
-- 用type类型向 addr 发送一个打包消息
-- addr: 可以是服务句柄，也可以是服务别名
skynet.rawsend(addr, type, msg, sz)
-- 向addr发送type类型的未打包消息并等待返回响应，并对回应信息进行解包（自动打包与解包）
skynet.call(addr, type, ...)
-- 直接向addr发送type类型的打包消息，不对回应信息解包（需要自己打包与解包）
skynet.rawcall(addr, type, msg, sz)
-- 目标服务消息处理后需要通过该函数将结果返回
skynet.ret(msg, sz)
-- 目标服务将...参数列表的消息打包后调用skynet.ret回应
skynet.retpack(...)
```