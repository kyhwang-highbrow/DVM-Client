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
    -- 상단 유저정보창 비활성화
    self.m_bShowTopUserInfo = false
end

-------------------------------------
-- function onEnter
-------------------------------------
function SceneTitle:onEnter()
    PerpleScene.onEnter(self)

    --[[
    local player_id = nil
    local uid = '130'
    local idfa = '한글테스트123!@#'
    local deviceOS = '3'
    local pushToken = 'temp'

    local success_cb = function(ret)
        ccdump(ret)
        local test_str = ret['idfa']
        cclog(test_str)
    end

    local fail_cb = function(ret)
        ccdump(ret)
    end

    Network_platform_guest_login(player_id, uid, idfa, deviceOS, pushToken, success_cb, fail_cb)
    --]]

    UI_TitleScene()
end