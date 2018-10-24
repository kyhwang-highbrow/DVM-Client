local PARENT = UI_GameArena

-------------------------------------
-- class UI_GameChallengeMode
-------------------------------------
UI_GameChallengeMode = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_GameChallengeMode:init(game_scene)
    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_pauseButton() end, 'UI_GameChallengeMode')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GameChallengeMode:initUI()
    PARENT.initUI(self)

    local vars = self.vars
    
    -- 그림자의 신전에서는 연속 전투를 제공하지 않음
    vars['autoStartButton']:setVisible(false)
end

-------------------------------------
-- function lockButton
-- @brief 그림자의 신전에서는 연속 전투를 제공하지 않음
-------------------------------------
function UI_GameChallengeMode:lockButton()
    local vars = self.vars

	-- 3회 초과 도전 시 수동/자동 선택 가능
	local stage = g_challengeMode:getSelectedStage()
    local is_auto_mode

    -- @sgkim 2018-10-23 조건 없이 첫번째 전투부터 선택 가능하도록 기획 변경
	--if (g_challengeMode:getChallengeModeStagePlayCnt(stage) + 1 > 3) then
    if (true) then
		-- g_autoPlaySetting의 auto_mode는 휘발성이므로 arena와 공유해도 상관 없음
		is_auto_mode = g_autoPlaySetting:get('auto_mode') or false
	else
		-- 3회 이하인 경우 고정
		is_auto_mode = true
	end
    
	vars['autoButton']:setVisible(not is_auto_mode)
    vars['autoVisual']:setVisible(is_auto_mode)
    vars['autoLockSprite']:setVisible(not vars['autoButton']:isVisible())

    -- 연속 전투 UI off
    vars['autoStartButton']:setVisible(false)
end
