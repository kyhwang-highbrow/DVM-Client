-------------------------------------
-- class SceneAdventure
-------------------------------------
SceneAdventure = class(PerpleScene, {
    })

-------------------------------------
-- function init
-------------------------------------
function SceneAdventure:init()
    
end

-------------------------------------
-- function onEnter
-------------------------------------
function SceneAdventure:onEnter()
    PerpleScene.onEnter(self)
    SoundMgr:playBGM('bgm_title')
    UI_AdventureSceneNew()
end