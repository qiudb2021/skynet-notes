package.cpath = "../skynet/luaclib/?.so"
local crypt = require "client.crypt"

-- 8 byte random
local clientkey = "11111111";
print("clientkey: ", clientkey)

local ckey = crypt.dhexchange(clientkey)
print("ckey:\t", crypt.hexencode(ckey))

local serverkey = "22222222"
print("serverkey: ", serverkey)
local skey = crypt.dhexchange(serverkey)
print("skey:\t", crypt.hexencode(skey));