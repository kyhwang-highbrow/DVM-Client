-------------------------------------
-- class SceneColosseum
-------------------------------------
SceneColosseum = class(PerpleScene, {
        m_startStageID = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function SceneColosseum:init()
end

-------------------------------------
-- function onEnter
-------------------------------------
function SceneColosseum:onEnter()
    PerpleScene.onEnter(self)
    SoundMgr:playBGM('bgm_title')

    UI_Colosseum()
end