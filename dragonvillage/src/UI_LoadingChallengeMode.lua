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

    -- 연속 전투 상태 여부에 따라 버튼이나 로딩 게이지 표시
    do
        local is_autoplay = g_autoPlaySetting:isAutoPlay()
    
        vars['btnNode']:setVisible(not is_autoplay)
        vars['loadingNode']:setVisible(is_autoplay)
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
-- function update
-------------------------------------
function UI_LoadingChallengeMode:update(dt)
    if (self.m_bSelected) then return end

    local prev = math_floor(self.m_remainTimer)
    self.m_remainTimer = self.m_remainTimer - dt

    local next = math_floor(self.m_remainTimer)

    if (self.m_remainTimer <= 0) then
        -- 타임아웃시 자동모드 강제 설정
        self:selectAuto(true)

    elseif (prev ~= next) then
        local msg = Str('{1}초 후 전투가 시작됩니다.', next)
        local label = self.vars['countdownLabel']
        label:setString(msg)
        cca.uiReactionSlow(label)
    end
end

-------------------------------------
-- function setLoadingGauge
-------------------------------------
function UI_LoadingChallengeMode:setLoadingGauge(percent, is_not_use_label)
    local vars = self.vars

    vars['loadingGauge']:setPercentage(percent)
	if (not is_not_use_label) then
		self:setNextLoadingStr()
	end
end

-------------------------------------
-- function selectAuto
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
