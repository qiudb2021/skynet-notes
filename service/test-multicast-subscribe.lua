local skynet = require "skynet"
local mc = require "skynet.multicast"
local channel
local channelID = ...
channelID = tonumber(channelID)

local function recvChannel(channel, source, msg, ...)
    skynet.error("channel ID: ", channel, "source: ", skynet.address(source), "msg: ", msg)
end

skynet.start(function (  )
    channel = mc.new({
        --- 绑定上一个频道
        channel = channelID,
        -- 设置这个频道的消息处理函数
        dispatch = recvChannel,
    })
    channel:subscribe()
    skynet.timeout(500, function (  )
        channel:delete()
    end)
end)