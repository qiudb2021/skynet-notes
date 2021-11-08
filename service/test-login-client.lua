package.cpath = "./skynet/luaclib/?.so"

local socket = require "client.socket"
local crypt = require "client.crypt"

if _VERSION ~= "Lua 5.4" then
    error "Use lua 5.4"
end

local fd = socket.connect("127.0.0.1", 8001)

local function writeline(fd, text)
    socket.send(fd, text .."\n")
end

local function unpack_line(text)
    local from = text:find("\n", 1, true)
    if from then
        return text:sub(1, from - 1), text:sub(from + 1)
    end
    return nil, text
end

local last = ""

local function unpack_f(f)
    local function try_recv(fd, last)
        local result
        result, last = f(last)
        if result then
            return result, last
        end
        local r = socket.recv(fd)
        if not r then
            return nil, last
        end
        if r == "" then
            error "Server Close"
        end
        return f(last..r)
    end

    return function (  )
        while true do
            local result
            result, last = try_recv(fd, last)
            if result then
                return result
            end
            socket.usleep(100)
        end
    end
end

local readline = unpack_f(unpack_line)
-- 接收chanellenge
local challenge = crypt.base64decode(readline())

local clientkey = crypt.randomkey()

-- 把clientkey换算成ckey，发送给服务器
local ckey = crypt.dhexchange(clientkey)
writeline(fd, crypt.base64encode(ckey))

-- 服务器也把serverkey通过dhexchange换算成skey发送给客户端，客户端用clientkey与skey得出secret
local secret = crypt.dhsecret(crypt.base64decode(readline()), clientkey)
-- secret 一般是8个字节数据流，需要转换16字节的hex字符串显示
print("secret is ", crypt.hexencode(secret))

-- 加密时，需要直接传递secret字节流
local chmac = crypt.hmac64(challenge, secret)
writeline(fd, crypt.base64encode(chmac))

local token = {
    server = "sample",
    user = "hello",
    pass = "password"
}

local function encode_token(token)
    return string.format( "%s@%s:%s", 
        crypt.base64encode(token.user),
        crypt.base64encode(token.server),
        crypt.base64encode(token.pass)
    )
end

print("token ", encode_token(token))
-- 使用DES加密token得到etoken，etoken是字节流
local etoken = crypt.desencode(secret, encode_token(token))
etoken = crypt.base64encode(etoken)
-- 发送etoken, loginserver将会调用auth_handler回调函数，以及login_handler
writeline(fd, etoken)

-- 读取最终返回的结果
local result = readline()
print("result ", result)
local code = tonumber(string.sub( result, 1, 3 ))
assert(code == 200)
-- 关闭socket连接
socket.close(fd)

-- 解析subid
local subid = crypt.base64decode(string.sub(result, 5))
print("login ok, subid = ", subid)
