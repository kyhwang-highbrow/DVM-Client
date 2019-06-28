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

    self:init_loadingGuideType()
    self.m_loadingUIDuration = 1
end

-------------------------------------
-- function init_loadingGuideType
-- @brief 로딩가이드 타입
-------------------------------------
function SceneLobby:init_loadingGuideType()
	-- 튜토리얼 시작전 로비 진입 로딩화면이라면 in_tutorial_lobby 로딩 가이드 사용
    local b_before_first_tutorial = TutorialManager.getInstance():beforeFirstTutorialDone()
    if (b_before_first_tutorial) then
        self.m_loadingGuideType = 'in_tutorial_lobby'
    else
	    self.m_loadingGuideType = 'all'
	end
end

-------------------------------------
-- function onEnter
-------------------------------------
function SceneLobby:onEnter()
    PerpleScene.onEnter(self)

    -- 연속 모드 해제
    g_autoPlaySetting:setAutoPlay(false)

    -- title 이후 끊기는것을 방지하기 위해..!
    SoundMgr:playBGM('bgm_lobby')

    -- UI 캐싱
    getUIFile('dragon_info_mini.ui')

	-- self.m_bUseLoadingUI가 false라면 prepare가 동작하지 않으므로 별도로 선언
	if (not self.m_bUseLoadingUI) then
        UI_Lobby()
	end

    -- 절전모드 활성화
    SetSleepMode(true)
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