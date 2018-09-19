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

	vars['arenaVisual']:setVisible(false)
	vars['challengeModeVisual']:setVisible(true)

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
    if (g_challengeMode:getChallengeModeStagePlayCnt(stage) + 1 > 3) then
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

-------------------------------------
-- function initUserInfo
-- @override
-------------------------------------
function UI_LoadingChallengeMode:initUserInfo(direction, struct_user_info)
	local vars = self.vars
    local icon

	local idx
    if (direction == 'left') then
        idx = 1
    elseif (direction == 'right') then
        idx = 2
    end

	-- 랭킹 숨김
	vars['rankLabel' .. idx]:setVisible(false)

    -- 닉네임
    vars['userLabel' .. idx]:setString(struct_user_info.m_nickname)
	vars['userLabel' .. idx]:setPositionX(-50 * (math_pow(-1, idx)))

    -- 클랜명 .. 그림자 신전 구조 상 클랜명만 받아오기 때문에 이와 같이 처리
	local clan_name = struct_user_info:getUserData() or ''
	vars['clanLabel' .. idx]:setString(clan_name)
	vars['clanLabel' .. idx]:setPositionX(-50 * (math_pow(-1, idx)))

    -- 전투력
    local str = struct_user_info:getDeckCombatPower()
    vars['powerLabel' .. idx]:setString(Str('전투력 : {1}', str))

    -- 아이콘
    icon = struct_user_info:getDeckTamerIcon()
    if (icon) then
        vars['tamerNode' .. idx]:addChild(icon)
    end
end

-------------------------------------
-- function setNextLoadingStr
-- @override
-------------------------------------
function UI_LoadingChallengeMode:setNextLoadingStr()
	local stage = g_challengeMode:getSelectedStage()
    if (g_challengeMode:getChallengeModeStagePlayCnt(stage) + 1 > 3) then
		PARENT.setNextLoadingStr(self)
	else
		self.vars['loadingLabel']:setString(Str('1~3회 도전은 자동전투만 가능합니다.'))
	end
end

-------------------------------------
-- function selectAuto
-- @override
-------------------------------------
function UI_LoadingChallengeMode:selectAuto(auto_mode)
    if (self.m_bSelected) then return end

    local vars = self.vars

    self.m_bSelected = true

	g_autoPlaySetting:set('auto_mode', auto_mode)

    vars['btnNode']:setVisible(false)
    vars['loadingNode']:setVisible(true)

    -- 서버 Log를 위해 임시저장
    g_challengeMode.m_tempLogData['is_auto'] = auto_mode
end

--@CHECK
UI:checkCompileError(UI_LoadingChallengeMode)
