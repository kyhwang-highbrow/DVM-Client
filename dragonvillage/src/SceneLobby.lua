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
    SoundMgr:playBGM('bgm_lobby')

    -- UI 캐싱
    getUIFile('dragon_info_mini.ui')

	-- self.m_bUseLoadingUI가 false라면 prepare가 동작하지 않으므로 별도로 선언
	if (not self.m_bUseLoadingUI) then
        UI_Lobby()
	end
end

-------------------------------------
-- function prepare
-------------------------------------
function SceneLobby:prepare()
	self:addLoading(function()
        UI_Lobby()
	end)
end

-------------------------------------
-- function prepareDone
-------------------------------------
function SceneLobby:prepareDone()
end 