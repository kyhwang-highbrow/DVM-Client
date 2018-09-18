local PARENT = UI_LoadingArena

-------------------------------------
-- class UI_LoadingChallengeMode
-------------------------------------
UI_LoadingChallengeMode = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_LoadingChallengeMode:init(curr_scene)
	self.m_uiName = 'UI_LoadingChallengeMode'
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_LoadingChallengeMode:initUI()
    local vars = self.vars

    -- 플레이어
    do
		local struct_user_info = g_challengeMode:getPlayerArenaUserInfo()
		if (struct_user_info) then
			-- 덱
			local l_dragon_obj = struct_user_info:getDeck_dragonList()
			local leader = struct_user_info.m_pvpDeck['leader']
			local formation = struct_user_info.m_pvpDeck['formation']
			self:initDeckUI('left', l_dragon_obj, leader, formation)

			-- 유저 정보
			self:initUserInfo('left', struct_user_info)
		end
    end

	 -- 상대방
    do
		local struct_user_info = g_challengeMode:getMatchUserInfo()
		if (struct_user_info) then
			-- 덱
			local l_dragon_obj = struct_user_info:getDeck_dragonList()
			local leader = struct_user_info.m_pvpDeck['leader']
			local formation = struct_user_info.m_pvpDeck['formation']
			self:initDeckUI('right', l_dragon_obj, leader, formation)

			-- 유저 정보
			self:initUserInfo('right', struct_user_info)
		end
    end

    -- 3회 이상 도전 시 수동/자동 선택 가능
	local stage = g_challengeMode:getSelectedStage()
    if (g_challengeMode:getChallengeModeStagePlayCnt(stage) > 3) then
        vars['btnNode']:setVisible(true)
        vars['loadingNode']:setVisible(false)
	-- 3회 이하는 자동만 가능
	else
		self:selectAuto(true)
    end
end

-------------------------------------
-- function initButton
-- @override
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_LoadingChallengeMode:initButton()
    PARENT.initButton(self)
end

-------------------------------------
-- function refresh
-- @override
-------------------------------------
function UI_LoadingChallengeMode:refresh()
	PARENT.refresh(self)
end

--@CHECK
UI:checkCompileError(UI_LoadingChallengeMode)
