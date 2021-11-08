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
print("skey:\t", crypt.hexencode(skey))

local cserect = crypt.dhsecret(skey, clientkey);
print("use skey clientkey dhsecret: ", crypt.hexencode(cserect));

local sserect = crypt.dhsecret(ckey, serverkey)
print("use ckey serverkey dhsecret: ", crypt.hexencode(sserect))

local sserect = crypt.dhsecret(ckey, skey)
print("user ckey skey dhsecret:\t", crypt.hexencode(sserect))