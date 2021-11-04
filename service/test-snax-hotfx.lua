local skynet = require "skynet"
local snax = require "skynet.snax"

skynet.start(function (  )
    local obj = snax.newservice("test-snax-service")
    -- before hotfix
    obj.post.hello()

    -- start hotfix
    local r = snax.hotfix(obj, [[
        local skynet
        local i
        function accept.hello( ... )
            skynet.error("fix hello ", i, gname)
            skynet.error("ing...")
        end
    ]])

    skynet.error("hotfix return ", r)

    -- after hotfix
    obj.post.hello()
    obj.post.quit()
end)