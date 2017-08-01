-------------------------------------
-- class SceneAncientTower
-------------------------------------
SceneAncientTower = class(PerpleScene, {})

-------------------------------------
-- function init
-------------------------------------
function SceneAncientTower:init()
end

-------------------------------------
-- function onEnter
-------------------------------------
function SceneAncientTower:onEnter()
    PerpleScene.onEnter(self)
    SoundMgr:playBGM('bgm_lobby')
    
    UI_AncientTower()
end