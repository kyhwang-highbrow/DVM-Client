-------------------------------------
-- class SceneDragonManage
-------------------------------------
SceneDragonManage = class(PerpleScene, {
    })

-------------------------------------
-- function init
-------------------------------------
function SceneDragonManage:init()
end

-------------------------------------
-- function onEnter
-------------------------------------
function SceneDragonManage:onEnter()
    PerpleScene.onEnter(self)
    SoundMgr:playBGM('bgm_title')
    UI_DragonManageScene()
end