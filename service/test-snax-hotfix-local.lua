local skynet = require "skynet"
local snax = require "skynet.snax"

skynet.start(function ( )
    local obj = snax.newservice("test-snax-service")

    obj.post.hello()

    local r = snax.hotfix(obj, [[
        local skynet
        local i
        function accept.hello( ... )
            skynet.error("fix hello ", i, gname)
            skynet.error("ing...")
        end

        function hostfix( ... )
            local temp = i
            i = 100
            gname = "skynet v2"
            return temp
        end
    ]])

    skynet.error("hotfiix return: ", r)

    obj.post.hello()
    obj.post.quit()
    skynet.exit()
end)