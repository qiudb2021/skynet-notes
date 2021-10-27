--[[
    3.3 环境变量
​ 1、预先加载的环境变量是在conf中配置的，加载完成后，所有的service都能去获取这些变量。

​ 2、也可以去设置环境变量，但是不能修改已经存在的环境变量。

​ 3、环境变量设置完成后，当前节点上的所有服务都能访问的到。

​ 4、环境变量设置完成后，及时服务退出了，环境变量依然存在，所以不要滥用环境变量。

    例如在conf中添加：
    myname = "Dmaker"
    myage = 20
]]

local skynet = require "skynet"
skynet.start(function()
    local name = skynet.getenv("myname")
    local age = skynet.getenv("myage")
    skynet.error("Myname is ", name, ", ", age, " years old.")
end)