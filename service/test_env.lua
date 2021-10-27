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

    -- 错误：不要尝试设置已经存在的变量值，会报错
    --[[
        [:01000012] LAUNCH snlua test_env
        [:01000012] Myname is  Dmaker ,  20  years old.
        [:01000012] init service failed: ./lualib/skynet.lua:558: Can't setenv                                                                                                                                         exist key : myname
        stack traceback:
                [C]: in function 'assert'
                ./lualib/skynet.lua:558: in function 'skynet.setenv'
                ./../service/test_env.lua:23: in upvalue 'start'
                ./lualib/skynet.lua:935: in function <./lualib/skynet.lua:933>
                [C]: in function 'xpcall'
                ./lualib/skynet.lua:937: in function 'skynet.init_service'
                ./lualib/skynet.lua:950: in upvalue 'f'
                ./lualib/skynet.lua:253: in function <./lualib/skynet.lua:252>
        [:01000012] KILL sel
    ]]
    -- skynet.setenv("myname", 'coder')
    -- skynet.setenv("myage", 21)

    -- 设置一个新的环境变量
    skynet.setenv("mynewname", "coder")
    skynet.setenv("mynewage", 22)

    name = skynet.getenv("mynewname")
    age = skynet.getenv("mynewage")

    skynet.error("My new name is ", name, ", ", age, " years old soon.")
end)