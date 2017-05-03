-------------------------------------
-- class SceneLobby
-------------------------------------
SceneLobby = class(PerpleScene, {
    })

-------------------------------------
-- function init
-------------------------------------
function SceneLobby:init(is_use_loading)
	self.m_sceneName = 'SceneLobby'

	self.m_bUseLoadingUI = is_use_loading
	self.m_loadingGuideType = 'all'
	self.m_loadingUIDuration = 1
end

-------------------------------------
-- function onEnter
-------------------------------------
function SceneLobby:onEnter()
    PerpleScene.onEnter(self)
    SoundMgr:playBGM('bgm_title')

    -- UI 캐싱
    getUIFile('dragon_info_mini.ui')

    UI_Lobby()
end