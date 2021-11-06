package.cpath = "../skynet/luaclib/?.so"
package.path = "../skynet/lualib/?.lua;../skynet/examples/?.lua;./?.lua"
local socket = require "client.socket"
local fd = socket.connect("127.0.0.1", 8001)
assert(fd)
local bytes = string.pack(">s2", "learn skynet")
socket.send(fd, bytes)