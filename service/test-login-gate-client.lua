package.path = "./skynet/lualib/?.so"

local socket = require "client.socket"
local crypt = require "client.crypt"

if _VERSION ~= "Lua 5.4" then
    error "Use Lua 5.4"
end

local fd = assert(socket.connect("127.0.0.1", 8001))

local function writeline(fd, text)
    socket.send(fd, text.."\n")
end

local function unpack_line(text)
    local from = string.find( text,"\n", true )
    if from then
        return text:sub(1, from - 1), text:sub(from + 1);
    end
end

local last = ""
local function unpack_f(f)
    local function try_recv(fd, last)
        local result = nil
        result, last = f(last)
        if result then
            return result, last
        end
        local r = socket.recv(fd)
        if not r then
            return nil, last
        end

        if r == "" then
            error "Server closed."
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

local readline = unpack_f(unpack_line);
local challenge = crypt.base64decode(readline())

local clientkey = crypt.randomkey()
-- 把clientkey换算成ckey后发送给服务器
local ckey = crypt.dhexchange(clientkey)
writeline(fd, crypt.base64encode(ckey))

local skey = crypt.base64decode(readline())
local secret = crypt.dhsecret(skey, clientkey)

print("secret is ", crypt.hexencode(secret))

local hmac = crypt.hmac64(challenge, secret)
writeline(fd, crypt.base64encode(hmac))

local token = {
    server = "sample",
    user = "skynet",
    pass = "password"
}

local function encode_token(token)
    return string.format( "%s@%s:%s",
        crypt.base64encode(token.user),
        crypt.base64encode(token.server),
        crypt.base64encode(token.pass)
    )
end

-- 使用des加密token得到etoken
local etoken = crypt.desencode(secret, encode_token(token))
writeline(fd, crypt.base64encode(etoken))

-- 读取最终返回的结果
local result = readline()
print(result)

local code = tonumber(string.sub( result, 1, 3 ))
assert(code == 200)
-- 关闭也loginserver的连接
socket.close(fd)

local subid = crypt.base64decode(string.sub( result, 5 ))
print("login ok, subid=", subid)
