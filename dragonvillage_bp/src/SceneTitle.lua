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
	self.m_sceneName = 'SceneTitle'
end

-------------------------------------
-- function onEnter
-------------------------------------
function SceneTitle:onEnter()
    PerpleScene.onEnter(self)
    UI_TitleScene()
end