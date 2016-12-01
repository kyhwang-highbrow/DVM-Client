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
    ServerData:getInstance():applySetting()
    UserData:getInstance()
	
    local scene = SceneGame(nil, 99999, 'stage_dev', true)
    scene:runScene()
    return
end
