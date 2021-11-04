local skynet = require "skynet"
local snax = require "skynet.snax"

local i = 10
gname = "skynet"

function response.echo( str )
    skynet.error("echo ", str)
    return string.upper( str )
end

function accept.hello( ... )
    skynet.error("hello", i, gname, ...)
end

function accept.quit( ... )
    snax.exit(...)
end

function init( ... )
    skynet.error("snax server start: ", ...)
end

function exit( ... )
    skynet.error("snax server exit: ", ...)
end
