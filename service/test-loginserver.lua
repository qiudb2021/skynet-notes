local skynet = require "skynet"
local login = require "snax.loginserver"
local crypt = require "skynet.crypt"

local server = {
    host = "0.0.0.0",
    port = 8001,
    multilogin = false,
    name = "login_master",
}

function server.auth_handler( token )
    -- the token is base64(user)@base64(server):base64(password)
    -- 通过正则表达式，解析出各个参数
    local user, server, password = token:match("([^@]+)@([^:+]):(.+)")
    user = crypt.base64decode(user)
    server = crypt.base64decode(server)
    password = crypt.base64decode(password)
    skynet.error(string.format( "%s@%s:%s", user, server, password ))
    -- 密码不对直接报错中断当前协程，千万不要返回nil，一定要用assert中断或者error报错终止掉当前协程
    assert(password == "password", "Invalid password")
    return server, user
end

local subid = 0
function server.login_handler( server, uid, secret )
    skynet.error(string.format( "%s@%s is login, secret is %s",uid, server, crypt.hexencode(secret) ))
    subid = subid + 1
    return subid
end

local CMD = {}
function CMD.register_gate( server, address )
    skynet.error("cmd register_gate")
end

function  server.command_handler( command, ... )
    local f = assert(CMD[command])
    return f(...)
end

-- 服务启动
login(server)