local skynet = require "skynet"
local mc = require "skynet.multicast"
local channel

local function task()
    local i = 0
    while i < 100 do
        skynet.sleep(100)
        --- 推送数据
        channel:publish("data "..i)
        i = i + 1
    end
end

skynet.start(function (  )
    channel = mc.new()
    skynet.error("new channel ID", channel.channel)
    skynet.fork(task)
end)