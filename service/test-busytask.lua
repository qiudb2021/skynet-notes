local skynet = require "skynet"

function task( name )
    local i = 0
    skynet.error(name, "begin task")
    while i < 2000*10000*10 do
        i = i + 1
    end
    skynet.error(name, "end task", i)
end

skynet.start(function (  )
    skynet.fork(task, "task1")
    skynet.fork(task, "task2")
end)
