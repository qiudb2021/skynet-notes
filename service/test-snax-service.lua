local skynet = require "skynet"
local snax = require "skynet.snax"



function init( ... )
    skynet.error("snax server start: ", ...)
end

function exit( ... )
    skynet.error("snax server exit: ", ...)
end