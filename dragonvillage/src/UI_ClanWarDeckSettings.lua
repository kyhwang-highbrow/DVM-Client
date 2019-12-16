local PARENT = UI_ReadySceneNew

-------------------------------------
-- class UI_ClanWarDeckSettings
-------------------------------------
UI_ClanWarDeckSettings = class(PARENT,{
        m_currTamerID = 'number',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_ClanWarDeckSettings:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ClanWarDeckSettings'
    self.m_bVisible = true
    --self.m_titleStr = nil -- refresh에서 스테이지명 설정
    self.m_bUseExitBtn = true
    self.m_subCurrency = 'honor'
    self.m_addSubCurrency = 'valor'

    -- 입장권 타입 설정
    -- 클랜전은 입장권 없음
    --self.m_staminaType = TableDrop:getStageStaminaType(self.m_stageID)

    
	-- 들어온 경로에 따라 sound가 다름
	if (self.m_gameMode == GAME_MODE_ADVENTURE) then
		self.m_uiBgm = 'bgm_dungeon_ready'
	else
		self.m_uiBgm = 'bgm_lobby'
	end
end

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarDeckSettings:init(stage_id, sub_info)
    local vars = self.vars
    
    vars['actingPowerNode']:setVisible(false)
    vars['startBtn']:registerScriptTapHandler(function() self:click_backBtn() end)
    vars['startBtnLabel']:setPositionX(0)
    vars['startBtnLabel']:setString(Str('변경 완료'))
end

-------------------------------------
-- function refresh_buffInfo_TamerBuff
-------------------------------------
function UI_ClanWarDeckSettings:refresh_buffInfo_TamerBuff()
    local vars = self.vars

    -- 테이머 버프
    local tamer_id = self:getCurrTamerID()
	local t_tamer_data = g_tamerData:getTamerServerInfo(tamer_id)
	local skill_mgr = MakeTamerSkillManager(t_tamer_data)
	--local skill_info = skill_mgr:getSkillIndivisualInfo_usingIdx(3)	-- 3번이 콜로세움 테이머 스킬
    local skill_info = skill_mgr:getSkillIndivisualInfo_usingIdx(2)	-- 2번이 패시브
	local tamer_buff = skill_info:getSkillDesc()

	vars['tamerBuffLabel']:setString(tamer_buff)
end

-------------------------------------
-- function getCurrTamerID
-------------------------------------
function UI_ClanWarDeckSettings:getCurrTamerID()
    if (not self.m_currTamerID) then
        local l_deck, formation, deckname, leader, tamer_id = g_deckData:getDeck()
        self.m_currTamerID = tamer_id
    end
    return self.m_currTamerID
end

-------------------------------------
-- function click_tamerBtn
-- @breif
-------------------------------------
function UI_ClanWarDeckSettings:click_tamerBtn()
    local tamer_id = self:getCurrTamerID()

    local ui = UI_TamerManagePopup_Colosseum(tamer_id)

    local function close_cb()
        self.m_currTamerID = ui.m_currTamerID
		self:refresh_tamer()
		self:refresh_buffInfo()
    end

	ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_backBtn
-------------------------------------
function UI_ClanWarDeckSettings:click_backBtn()
	self:click_exitBtn()
end
