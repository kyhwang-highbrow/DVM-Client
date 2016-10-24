local PARENT = PerpleScene

-------------------------------------
-- class SceneTitle
-------------------------------------
SceneTitle = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function SceneTitle:init()
end

-------------------------------------
-- function onEnter
-------------------------------------
function SceneTitle:onEnter()
    PerpleScene.onEnter(self)


    local player_id = nil
    local uid = nil
    local idfa = 'temp1'
    local deviceOS = 3
    local pushToken = 'temp'

    local success_cb = function(ret)
        ccdump(ret)
    end

    local fail_cb = function(ret)
        ccdump(ret)
    end

    Network_platform_guest_login(player_id, uid, idfa, deviceOS, pushToken, success_cb, fail_cb)
end