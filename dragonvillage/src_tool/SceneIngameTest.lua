-------------------------------------
-- class SceneIngameTest
-------------------------------------
SceneIngameTest = class(PerpleScene, {
    })

-------------------------------------
-- function init
-------------------------------------
function SceneIngameTest:init()
    self.m_bShowTopUserInfo = false
end

-------------------------------------
-- function onEnter
-------------------------------------
function SceneIngameTest:onEnter()
    PerpleScene.onEnter(self)
    
    TABLE:init()
    SoundMgr:entry()
    ShaderCache:init()
    LocalData:getInstance():applySetting()
	
    local scene = SceneGame(nil, DEV_STAGE_ID, 'stage_dev', true)
    scene:runScene()
    return
end
