package.cpath = "../skynet/luaclib/?.so"
local crypt = require "client.crypt"

-- 8 byte random
local clientkey = "11111111";
print("clientkey: ", clientkey)

local ckey = crypt.dhexchange(clientkey)
print("ckey:\t", crypt.hexencode(ckey))