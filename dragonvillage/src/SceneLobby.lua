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

    if (not DEVELOPMENT_SEONG_GOO_KIM) then
        UI_Lobby()
    else
        UI_LobbyNew()
    end
end