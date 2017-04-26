-------------------------------------
-- class SceneLobby
-------------------------------------
SceneLobby = class(PerpleScene, {
    })

-------------------------------------
-- function init
-------------------------------------
function SceneLobby:init(class_ui)
end

-------------------------------------
-- function onEnter
-------------------------------------
function SceneLobby:onEnter()
    PerpleScene.onEnter(self)
    SoundMgr:playBGM('bgm_title')

    -- UI 캐싱
    getUIFile('dragon_info_mini.ui')

    UI_Lobby()
end