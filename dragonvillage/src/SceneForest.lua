-------------------------------------
-- class SceneForest
-------------------------------------
SceneForest = class(PerpleScene, {
    })

-------------------------------------
-- function init
-------------------------------------
function SceneForest:init()
	self.m_sceneName = 'SceneForest'

	self.m_bUseLoadingUI = true
	self.m_loadingGuideType = 'all'
end

-------------------------------------
-- function onEnter
-------------------------------------
function SceneForest:onEnter()
    PerpleScene.onEnter(self)
end

-------------------------------------
-- function prepare
-------------------------------------
function SceneForest:prepare()
	self:addLoading(function()
        UI_Forest()
	end)
end