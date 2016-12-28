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

    UI_LobbyOld()
end