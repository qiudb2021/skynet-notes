local skynet = require "skynet"
local snax = require "skynet.snax"

function accept.hello( ... )
    skynet.error("hello", ...)
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