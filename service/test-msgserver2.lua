local msgserver = require "snax.msgserver"
local crypt = require "skynet.crypt"
local skynet = require "skynet"

-- 启动参数
local loginserver = tonumber(...)
local server = {}
local servername
local subid = 0

-- 外部发消息来调用，一般是通过loginserver发消息请求，你需要产生唯一的subid,
-- 如果loginserver不允许multilogin，那么这个函数也不会重入
function server.login_handler( uid, secret )
    subid = subid + 1;
    local username = msgserver.username(uid, subid, servername)
    skynet.error("uid ", uid, "login, username ", username)
    msgserver.login(username, secret)
    return subid
end

-- 外部发来消息调用，登录uid对应的登录名
function server.logout_handler( uid, subid )
    local username = msgserver.username(uid, subid, servername)
    msgserver.logout(username)
end

-- 一般给loginserver发消息来调用，可以作为使出操作
function server.kick_handler( uid, subid )
    server.logout_handler(uid, subid)
end

function server.disconnect_handler( username )
    skynet.error(username, " disconnect")
end

-- 当接收到客户端请求，这个回调函数会被调用，需要给予应答
function server.request_handler( username, msgserver )
    skynet.error("recv ", msg, " from ", username)
    return string.upper( msg )
end

-- 注册登录点服务，主要是告诉loginserver这个登录点存在
function server.register_handler( name )
    servername = name
    skynet.call(loginserver, "lua", "register_gate", servername, skynet.self())
end

msgserver.start(server)