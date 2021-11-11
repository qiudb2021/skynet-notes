local msgserver = require "snax.msgserver"
local crypt = require "skynet.crypt"
local skynet = require "skynet"

local subid = 0
-- 一张表，里面需要实现前面提到的所有回调接口
local server = {}
local servername

-- 注册可以登录的用户名
function server.login_handler( uid, secret )
    skynet.error("login_handler invoke ", uid, secret)
    subid = subid + 1
    -- 通过uid, subid, servername获得username
    local username = msgserver.username(uid, subid, servername)
    skynet.error("uid ", uid, "login, username ", username)

    -- 正在登录，给登录名注册一个secret
    msgserver.login(username, secret)
    return subid
end

function server.logout_handler( uid, subid )
    skynet.error("logout_handler invoke ", uid, subid)
    local username = msgserver.username(uid, subid, servername)
    msgserver.logout(username)
end

function server.kick_handler( uid, subid )
    skynet.error("kick_handler invoke ", uid, subid)
end

-- 当客户端断开连接时，这个回调函数会被调用
function server.disconnect_handler( username )
    skynet.error(username, "disconnect")
end

-- 当接收到客户端请求，这个回调函数会被调用，你需要提供应答
function server.request_handler( username, msg )
    skynet.error("recv ", msg, "from", username)
end

-- 监听成功会调用该函数，name为当前服务名
function server.register_handler( name )
    skynet.error("register_handler invoked name ", name)
    servername = name
end
msgserver.start(server)