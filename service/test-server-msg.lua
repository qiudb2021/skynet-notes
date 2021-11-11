local msgserver = require "snax.msgserver"
local crypt = require "skynet.crypt"
local skynet = require "skynet"

-- 从启动参数获取登录服务器地址
local loginservers = tonumber(...)
-- 里面需要实现前面提到的所有回调接口
local server = {}
local servername
local subid = 0;

-- 外部发来消息调用，一般是loginserver发消息来，需要产生唯一的subid
-- 如果loginserver不允许multilogin，那么这个函数也不会重入
function server.login_handler( uid, serect )
    subid = subid + 1
    local username = msgserver.username(uid, subid, servername)
    skynet.error("uid ", uid, "login, username ", username)
    msgserver.login(username, serect);
    return subid
end

-- 外部发来消息调用，登出uid对应的登录名
function server.logout_handler( uid, subid )
    local username = msgserver.username(uid, subid, servername)
    msgserver.logout(username)
    skynet.error("uid ", uid, "logout, username ", username)
end

-- 一般给loginserver发消息，可以作为登出操作
function server.kick_handler( uid, subid )
    server.logout_handler(uid, subid)
end

-- 当客户端断开了连接时，这个回调函数会被调用
function server.disconnect_handler( username )
    skynet.error("username ", username, "disconnect")
end

-- 当收到客户端的网络请求时，这个回调函数会被调用，需要给予应答
function server.request_handler( username, msg )
    skynet.error("recv ", msg, " from ", username);
    return string.upper( msg )
end

-- 注册一下登录点服务，主要是先搞loginserver有这个登录点存在
function server.register_handler(name)
    servername = name
    skynet.call(loginserver, "lua", "register_gate", servername, skynet.self())
end

msgserver.start(server)
