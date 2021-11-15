local login = require "snax.loginserver"
local crypt = require "skynet.crypt"
local skynet = require "skynet"
local server_list = {}

local server = {
    host = "127.0.0.1",
    port = 8001,
    multilogin = false,
    name = "login_master"
}

function server.auth_handler( token )
    local user, server, password = token:match "([^@]*)@([^#]*)#(.*)"
    user = crypt.base64decode(user)
    server = crypt.base64decode(server)
    password = crypt.base64decode(password)

    skynet.error(string.format( "%s@%s:%s",user, server, password ))
    assert(password == "password", "Invalid password")
    return server, user
end

function server.login_handler( server, uid, secret )
    local msgserver = assert(server_list[server], "unknow server")
    skynet.error(string.format( "%s@%s is login, secret is %s ", uid, server, crypt.hexencode(secret) ))
    -- 将uid以及secret发送给登录点，告诉登录点这个uid可以登录，并且让登录点返回一个subid
    local subid = skynet.call(msgserver, "lua", "login", uid, secret)
    return subid
end

local CMD = {}
function CMD.register_gate( server, address )
    skynet.error("cmd register gate")
    -- 记录已经启动的登录点
    server_list[server] = address
end

function server.command_handler( command, ... )
    local f = assert(CMD[cmd])
    return f(...)
end

login(server)