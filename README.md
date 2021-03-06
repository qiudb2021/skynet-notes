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
-- 参数pack指定应答打包函数，不填默认使用skynet.pack，必须根据接收到的消息的打包函数一致
-- 返回值是一个闭包函数
local response = skynet.response(pack)
-- 闭包函数的使用方式
-- 参数ok的值可以是 "test",true,false,
-- test表示检查接收响应的服务是否存在
-- true表发送应答PTYPE_RESPONSE，为false时表示发送PTYPE_ERROR错误消息
response(ok, ...)

-- 服务临界区:
local queue = require "skynet.queue"
-- 获取一个执行队列
local cs = queue()
-- 将func丢到执行队列中去执行
cs(func, ...)

-- 使用source服务地址，发送typename类型的消息给dest服务，不需要接收响应(source/dest只能是服务ID)
-- msg, sz一般使用skynet.pack打包生成
skynet.redirect(dest, source, typename, session, msg, sz)
```
## 组播
```lua
local mc = require "skynet.multicast"
-- 创建一个频道，成功创建后，channel.channel是这个频道的id
local channel = mc.new()
-- 创建一个新频道，利用已知的频道 id 绑定一个已有频道
local channel2 = mc.new({
    -- 绑定上一个频道
    channel = channel.channel,
    -- 设置这个频道的处理消息
    dispatch = function (channel, source, ...) end
})

-- 向频道发布消息
channel:publish(...)
-- 订阅消息
channel:subscribe()
-- 取消订阅
channel:unsubscribe()
-- 回收频道
channel:delete()
```
##  skynet.socket 常用api
```lua
local socket = require "skynet.socket"
-- 建立一个 TCP 连接，返回一个数字 id
socket.open(address, port)
-- 关闭一个连接，这个API有可能阻塞住执行流。因为如果有其它coroute正在阻塞读这个id对应的连接，会先驱使读操作结束，close操作才返回
socket.close(id)
-- 在极其罕见的情况下，需要粗暴的直接关闭某个连接，而避免socket.close的阻塞等待流程，可以使用它
socket.close_fd(id)
-- 强行闭关一个连接。和close不同的是它不会等待可能存在的其它coroute的读操作
-- 一般不建议使用这个API，但如果你需要在__gc元方法中闭关连接的话，shutdown是一个比close更好的选择（因为gc中无法切换协程
socket.shutdown(id)
--[[
    从一个socket上读取sz指定的字节数。
    如果读到了指定长度的字符串，它把这个字符串返回
    如果是连接断开导致字节数不够，将返回一个false加上读到的字符串
    如果sz为nil，则返回尽可能多的字节数，但至少读到一个字节(若无新数据，会阻塞)
]]
socket.read(id, sz)
-- 从一个socket上读所有的数据，直到socket主动断开，或在其它协程用socket.close断开
socket.readall(id)
-- 从一个socket上读取一行数据。sep指行分割符。默认sep为"\n",读到的字符串是不包含这个分割符的。
-- 如果另一端关闭了，这个时候会返回nil,如果buff中有未读数据则作为第2个返回值返回
socket.readline(id, sep)
-- 等待一个socket可读
socket.blok(id)
-- 把一个字符串置入正常的写队列，skynet框架会在socket可写时发送给它
socket.write(id, str)
-- 把字符串写入低优先级队列。如果正常的写队列还有写操作未完成时，低优先级上的队列永远不会被发出。
-- 只有正常写队列为空时，才会处理低优先级队列。但是，每次写的字符串都可以被看成原子操作，不会只发送一半，然后转去发送正常写队列的数据
socket.lwrite(id, str)
-- 监听一个端口，返回一个id，供start使用
socket.listen(address, port)
--[[
    accept是一个函数。每当一个监听的id对应的socket上有连接接入的时候，都会调用accept函数。这个函数会得到接入连接的ide及ip地址。
    每当accpet函数获得一个新的socket id后，并不会立即收到这个socket上的数据。这是因为，我们有时候会希望把这个socket的操作权转让给别的服务去处理
]]
socket.start(id, accept)
--[[
    任何一个服务只有在调用socket.start(id)之后，才可以读到这个socket上的数据。向一个socket id写数据也需要先调用start
    socket的id对于整个skynet节点都是公开的。也就是说，你可以把这个id通过消息发送给其它服务，其他服务也可以去操作它。skynet框架是根据调用start这个api的位置来决定把对应socket上的数据转发到哪里去的
]]
socket.start(id)
-- 清除socket id在本服务内的数据结构，但并不关闭这个socket。这可以用于你把id发送给其它服务，以转交socket的控制权
socket.abandon(id)
--[[
    当id对应的socket上待发送的数据超过1MB后，系统将调用callback以示警告。
    function callback(id, size)回调函数接收两个参数id和size，size的单位是K。
    如果不设置回调，那么每增加64k则skynet.error写一行错误信息
]]
socket.warning(id, callback)
```
## socketchannel
```lua
local skynet = require "skynet"
local sc = require "skynet.socketchannel"
-- 1. 创建一个channel，其中host可以是ip地址或者域名，port：端口号
local channel = sc.channel({
    host = "127.0.0.1",
    port = 8001
});

--[[
    request: 是需要发送的请求 
    reponse: 是一个函数，用来接收响应的数据
        -- 接收响应的数据必须这么定义，sock就是与远端TCP连接的套接字，通过这个套接字可以把数据读出来
        function response(sock)
            -- 返回值必须要有两个，第一个如果是true则表示响应数据是有效的
            return true, sock:read()
        end
    -- 该函数阻塞，返回读到的内容
]]
channel:request(request, response, padding)
channel:close()

local channel = sc.channel({
    host = "127.0.0.1",
    port = 8001,
    --[[
        dispatch是一个解析回应包的函数，和上面提到的responsse解析函数类似。
        其返回值有3个，第1个是这个回应包的session，第2个是包解析是否正确，第3个是回应内容
    ]]
    response = dispatch
});
```
## 域名查询
```lua
local dns = require "skynet.dns"
-- 设置dns服务器，port默认值为53，如果不填写ip的话，将从/etc/resolv.conf中找到合适的ip
dns.server(ip, port)
-- 查询name对应的ip,如果ipv6为true的话则查询ipv6地址；默认为false。如果查询失败将抛出异常，成功则返回ip,以及一张包含所有ip的表。
dns.resolve(name, ipv6)
-- 默认情况下，模块会根据TTL值cache来查询结果。在查询超时的情况下，也可能返回之前的结果。可以用来清空cache。注意：cache保存在调用者的服务中，并非针对整个skynet进程。所以推荐写一个独立的 dns查询服务统一处理dns查询。
dns.flush()
```
## snax服务基础api
```lua
local snax = require "snax"
-- 可以把一个服务启动多份。传入服务名和参数，它会返回一个对象，用于和这个启动服务交互。
-- 如果多次调用newservice，即使名字相同，也会生成多份服务的实例，它们各自独立，由不同的对象区分。
-- 注意：返回的不是一个服务地址，而是一个对象
local obj = snax.newservice(name, ...)
-- 无响应请求，obj是snax对象，post表示无响应请求，CMD具体的请求指令，...为请求参数列表。发送完马上返回
obj.post.cmd(...)
-- 有响应请求，obj是snax对象，req表示有响应请求，CMD具体的请求指令，...为请求参数列表。发送完后等待响应
obj.req.cmd(...)
-- 在一个节点上只会启动一份同名服务。如果多次调用它，会返回相同的对象。
snax.uniqueservice(name, ...)
-- 整个skynet网络中只会有一个同名服务
snax.globalservice(name, ...)

-- 查询当前节点的具名服务，返回一个服务对象，如果服务尚未启动，那么一直阻塞等待它启动完毕
snax.queryservice(name)
-- 查询一个全局名字的服务，返回一个服务对象。如果服务尚未启动，那么一直阻塞等待它启动完毕
snax.queryglobal(name)
-- 用来获取自己这个服务对象，与skynet.self不同(它是服务句柄)
snax.self()

-- 让一个snax服务退出
snax.kill(obj, ...)
-- 退出当前服务等同于snax.kill(snax.self(), ...)
snax.exit()

-- 通过snax服务地址获取snax服务对象
-- 对于匿名服务，你无法在别处通过名字得到和它交互的对象。
-- 如果你有这个需求，可以把对象的handle通过消息发送给别人，handle是一个数字，即snax服务的skynet地址。
-- 把服务地址转换成服务对象，第2个参数需要传入服务的启动名，以用来了解这个服务有哪些远程方法可以供调用。
-- 当然你也可以直接把.type和.handle一起发送过去，而不必在源码上约定
snax.bind(handle, typename)

-- snax启动查找服务路径是config.path的snax变量来指定
snax = root.."examples/?.lua;"..root.."test/?.lua;".."my_workspace/?.lua"

--[[
  snax 是支持热更新的（只能热更新 snax 框架编写的 lua 服务）。
  但热更新更多的用途是做不停机的 bug 修复，不应用于常规的版本更新。
  所以，热更新的 api 被设计成下面这个样子。更适合打补丁。
]]
snax.hotfix(obj, patchcode) 
```
## 网关服务
### 1. 网关服务api
```lua
local gateserver = require "snax.gateserver"

-- 必须提供一张表，表里面定义connect message等相关回调函数
local handler = {}

-- 当一个客户端连接进来，gateserver自动处理连接，并且调用该函数
function handler.connect(id, addr)
    -- 连接成功不代表马上可以读到数据，需要打开这个套接字，允许fd接收数据
    gateserver.openclient(fd)
end
-- 当一个客户端断开连接后调用该函数，必须要有
function handler.disconnect(fd)
end

-- 当fd有数据到达了，会调用这个函数，前提是fd需要调用gateserver.openclient打开
function handler.message(fd, msg, sz)
end

-- 如果你希望监听端口打开的时候，做一些初始化操作，可以提供open这个方法
-- source：请求来源地址，conf 是开启 gate服务的参数列表(端口、连接数、是否延迟)
function handler.open(sourcce, conf)
end

-- 当一个连接异常(通常意味着断开)，error 方法被调用，除了fd，还会拿到错误信息 msg(通常用于log输出)
function handler.error(fd, msg)
end

-- 当fd上待发送的数据累积超过1MB后，将会调用这个方法
function handler.warning(fd, size)
end

-- 网关服务的入口函数
gatesever.start()
```
### 2. 打包与解包
打包与解包TCP网路数据可以使用skynet.netpack库
```lua
local netpack = require "skynet.netpack"
-- 打包数据str,返回一个C指针msg, sz(申请内存)
local msg, sz = netpack.pack(str)
-- 解包数据，返回一个lua的字符串，会释放内存
netpack.tostring(msg, sz)
```
### 3. skynet自带的网关服务
网关服务相关文件：
1. *service/gate.lua* 网关服务代码
2. *examples/watchdog.lua* 使用网关服务
3. *examples/agent.lua* 代理（watchdog中使用到agent）
4. 启动watchdog服务的代码在*examples/main.lua*
5. skynet网关架构图：
![Image text](./images/3-skynet网关架构.png)
* newservice watchdog 启动看门狗服务，lua start conf给看门狗发送lua消息start参数为conf
* newservice gate 启动网关服务，lua open conf给网关发送lua消息open，参数为conf
* new connection 客户端连接进来。
* lua socket open fd addr 给看门狗发送lua消息(socket open)参数为open fd addr
* new service agent 启动一个客户端代理服务，lua start {gate, fd, watchdog}给代理发送lua消息start, 参数为{gate, fd, watchdog}
* lua forward fd 给网关发送lua消息forward，参数为fd(到此，连接建立成功，可以进行网络通讯了)
* send request客户端发送请求给看门狗
* client 1 msg sz 看门狗把请求转发成client消息，session为1
* send response 代理直接给客户端发送响应。

按照从1到9的依次去看代码，需要强调的是：
* gate主要负责的是client连接创建与断开以及接收到的消息转发给agent
* watchdog主要负责gate的创建，agent的创建与退出
* agent主要负责接收gate转发的请求，处理业务，然后直接把应答发送给client
  
![Image text](images/4-skynet网关时序图.png)
---
## 14. 登录服务
登录服务需要解决的问题：
1. 用户登录信息保密工作
2. 实际登录点分配工作
### 14.1 加密算法
#### 14.1.1 DHexchange密钥交换算法
DHexchange密钥交换算法主要用来协商一个服务器与客户端的密钥
```lua
package.cpath = "lualib/?.so"
local crypt = require "client.crypt"
-- 如果在skynet中使用，则用
local crypt = require "skynet.crypt"

-- dhexchange转换8字节的key
crypt.dhexchange(key)
-- 通过key1与key2得到密钥
crypt.dhsecret(key1, key2)
```
#### 14.1.2 随机数
```lua
package.cpath = "lualib/?.so"
local crypt = require "client.crypt"
-- 如果在skynet中使用，则用
local crypt = require "skynet.crypt"

-- 产生一个8字节的随机数，一般作为加密算法的随机密钥
crypt.randomkey()
```
#### 14.1.3 hmac64哈希算法
主要用于密钥验证
```lua
package.cpath = "lualib/?.so"
local crypt = require "client.crypt"
-- 如果在skynet中使用，则用
local crypt = require "skynet.crypt"

-- HMAC64利用哈希算法，以一个密钥secret和一个消息challenge为输入，生成一个消息摘要hmax作为输出
local hmac = crypt.hmac64(challenge, secret)
```
#### 14.1.4 base64编码解码
Base64就是一种基于64个可打印字符来表示二进制数据的方法
```lua
package.cpath = "lualib/?.so"
local crypt = require "client.crypt"
-- 如果在skynet中使用，则用
local crypt = require "skynet.crypt"

-- 编码
crypt.base64encode(str)
-- 解码
crypt.base64decode(str)
```
#### 14.1.5 DES加密解密
```lua
package.cpath = "lualib/?.so"
local crypt = require "client.crypt"
-- 如果在skynet中使用，则用
local crypt = require "skynet.crypt"

-- 用key加密plaintext得到密文，key必须是8字节
crypt.desencode(key, plaintext)
-- 用key解密ciphertext得到明文，key必须是8字节
crypt.desdecode(key, ciphertext)
```
#### 14.1.6 hashkey算法
只能哈希小于8个字节的数据，返回8字节数据的hash
```lua
package.cpath = "lualib/?.so"
local crypt = require "client.crypt"
-- 如果在skynet中使用，则用
local crypt = require "skynet.crypt"

-- 只能哈希小于8个字节的数据，返回8字节数据的hash
crypt.hashkey(str)
```
### 14.2 loginserver原理图
skynet提供了一个通用的登录服务器模板snax.loginserver，框架原理图如下：
![Image text](images/5-loginserver.png)

login服务开始监听，客户端主动去连接login服务，他们之间的通讯协议是行结尾协议（每个数据包都是一行ascii字符，如果要发送byte字节流，则通过base64编码）。这里称login服务为L，客户端服务为C
1. L产生随机数challenge，并发送给C，主要用于最后验证密钥secret是否交换成功。
2. C产生随机数clientkey，clientkey是保密的，只有C知道，并通过dhexchange算法换算clientkey,得到ckey。把base64编码的ckey发送给L
3. L也产生随机数serverkey，serverkey是保密的，只有L知道，并通过dhexchange算法换算serverkey，得到skey。把base64编码的skey发送给L
4. C使用clientkey, skey通过hdserect算法得到最终安全密钥secret
5. L使用serverkey, ckey通过hdsecret算法得到最终安全密钥secret。C和L最终得到的secret是一样的，而传输过程只有ckey、skey是通过网络公开的，即使ckey、skey泄露了，也无法推算出secret.
6. 密钥交换完成后，需要验证一下双方的密钥是否是一致的。C使用密钥secret通过hmac64哈希算法加密第1步是接收到的challenge，得到SHmac，对比SHmac与CHmac，然后转码成base64 CHmac发送给L。
7. L收到CHmac后，自己也使用密钥ssecret通过hmac64哈希算法加密第1步中发送出去的challenge，得到SHmac，对比SHmac与Chmac是否一致，如果一致，则密钥交换成功。否则就断开连接。
8. C组合base64 user@base64 server:base64 passwd字符串（server为客户端具体想要登录的登录点，远端服务器可能有多个实际登录点），使用secret通过DES加密，得到etoken。
9. 使用sserect通过DES解密etoken，得到user@server:passwd，校验user与passwd是否正确，通知实际登录点server，传递user与secret给server, server生成subid返回，发送状态码200 base64 subid给C
10. C得到subid后就可以断开login服务的连接，然后去连接实际登录点server了。（实际登录点server，可以由L通知C，也可以C指定想要登录哪个点）
### 14.3 loginserver模板
```lua
local login = require "snax.loginserver"
local server = {
    host = "0.0.0.0", -- 监听地址，通常是0.0.0.0
    port = 8001,      -- 监听端口
    -- multilogin是一个boolean，默认是false。
    -- 关闭后当一个用户正在走登录流程时，禁止同一用户名进行登录。
    -- 如果你用户可以同时登录，可以打开这个开头，但需要自己处理好潜在的并行的状态管理问题
    multilogin = false, -- disallow multilogin
    -- name是一个内部使用的名字，不要和skynet其它服务重名。
    -- 在上面例子中，登录服务器会注册为.login_master名字，相当于skynet.register(".login_master")
    name = "login_master",
    -- config, etc...
}
login(server)

--[[
    对一个客户端发送过来的token进行验证。
    如果验证不能通过，可以通过error招聘异常。
    如果验证通过，需要返回用户希望进入的登陆点及用户名(登录点可以包含在token内由用户自行决定，也可以实现一个负载均衡器来选择)
]]
function server.auth_handler(token) end
--[[
    当用户已经验证通过后，该如何通知具体的登录点(server)。框架会交给你用户名(uid)和已经安全交换到的通讯密钥。
    你需要把它们交给登录点，并得到确认（等待登录点准备好后）才可以返回
]]
function server.login_handler(server, uid, secret) end
-- 用来处理lua消息，必须注册
function server.command_handler(command, ...) end
```
登录服务返回给客户端的状态码
```lua
200 [base64(subid)] -- 登录成功会返回一个subid，这个subid是这次登录的唯一标识
400 Bad Request -- 握手失败
401 Unauthorized -- 自定义的auth_handler不认可token
403 Forbidden -- 自定义的login_handler执行失败
406 Not Accpetable -- 该用户已经在登录中。（只发生在multilogin关闭时）
```
## 15 msgserver
### 15.1.1 api
```lua
-- uid, subid, server把一个登录名转换成uid, subid, servername三元组
msgserver.userid(username)
-- username把uid, subid, server三元组构造成一个登录名
msgserver.username(uid, subid, server)

-- 你需要在login_handler中调用它，注册一个登录名username对应 的secret
msgserver.login(username, secret)
-- 让一个登录名失效(登出)，通常在logout_handler里调用
msgserver.logout(username)
-- 查询一个登录名对应的连接的ip地址，如果没有关联的连接，会返回nil
msgserver.ip(username)
```
### 15.1.2 msgserver模板
```lua
local msgserver = require "snax.msgserver"
local server = {}
-- 服务初始化函数，要把server表传递进去
msgserver.start(server)

-- 在打开端口时，会触发这个 register_handler 函数，参数name是在配置信息中配置的当前登录点的名字
-- 需要在这个回调要做的事件是通知登录服务器，我这个登录点准备好了
function server.register_handler(name)
end

-- 在一个用户登录后，登录服务器会转交给你这个用户的 uid 和 secret，最终触发 login_handler 方法
-- 在这个函数里，你需要做的是判定这个用户是否真的可以登录。然后为用户生成一个subid，
-- （使用msg.username(uid, subid, servername)可以得到这个用户这次的登录名。servername是当前这个登录点的名字）
-- 在这个过程中，如果你发现一些意外情况，不希望用户进入，只需要用 error 抛出异常
function server.login_handler(uid, secret)
end

-- 当一个用户想登出时，这个函数会被调用，可以在里面做一些清除操作
function server.logout_handler(uid, subid)
end

-- 当外界（通常是登录服务器）希望一个用户登出时，会触发这个事件
-- 发起一个logout消息（最终会触发 logout_handler ）
function server.kick_handler(uid, subid)
end

-- 当用户的通讯连接断开后，会触发这个事件。可以利用这个事件做超时字处理（比如断开连接后一定时间不重新回来会就主动登出）
function server.disconnect_handler(username)
end

-- 如果用户提起了一个请求，request_handler 会被调用。这里隐藏了 session 信息，
-- 等处理完请求后，只需要返回一个字符串，这个字符串会回到框架，加上 session 回应客户端。
-- 这个函数允许抛出异常，框架会正确的捕获这个异常，并通过协议通知客户端。
function server.request_handler(username, msg, sz)
end
```
### 15.2 loginserver与msgserver
要使用msgserver一般都要跟loginserver一起使用；客户端登录时，一般先登录loginserver，然后再去连接实际登录点，msgserver一般充当真实登录点的角色，原理如下
![Image text](images/6-loginserver与msgserver.png)
![Image text](images/7-loginserver与msgserver.png)