local PARENT = UI_ReadySceneNew

-------------------------------------
-- class UI_ChallengeModeDeckSettings
-------------------------------------
UI_ChallengeModeDeckSettings = class(PARENT,{
        m_currTamerID = 'number',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_ChallengeModeDeckSettings:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ChallengeModeDeckSettings'
    self.m_bVisible = true
    --self.m_titleStr = nil -- refresh에서 스테이지명 설정
    self.m_bUseExitBtn = true
    self.m_subCurrency = 'valor'

    -- 입장권 타입 설정
    self.m_staminaType = TableDrop:getStageStaminaType(self.m_stageID)

    
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
function UI_ChallengeModeDeckSettings:init(stage_id, sub_info)
    local vars = self.vars


    -- 덱 변경만 가능
    if sub_info then
        vars['actingPowerNode']:setVisible(false)
        vars['startBtn']:registerScriptTapHandler(function() self:click_backBtn() end)
        vars['startBtnLabel']:setPositionX(0)
        vars['startBtnLabel']:setString(Str('변경 완료'))
    end
end

-------------------------------------
-- function refresh_buffInfo_TamerBuff
-------------------------------------
function UI_ChallengeModeDeckSettings:refresh_buffInfo_TamerBuff()
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
function UI_ChallengeModeDeckSettings:getCurrTamerID()
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
function UI_ChallengeModeDeckSettings:click_tamerBtn()
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
function UI_ChallengeModeDeckSettings:click_backBtn()
	self:click_exitBtn()
end

-------------------------------------
-- function click_startBtn
-- @brief 시작 버튼
-------------------------------------
function UI_ChallengeModeDeckSettings:click_startBtn()
    -- 콜로세움 공격 덱이 설정되었는지 여부 체크
    local l_dragon_list = self.m_readySceneDeck.m_lDeckList
    if (table.count(l_dragon_list) <= 0) then
        MakeSimplePopup(POPUP_TYPE.OK, Str('콜로세움 덱이 설정되지 않았습니다.'))
        return
    end

    local check_dragon_inven
    local check_item_inven
    local check_stamina
    local start_game

    -- 드래곤 가방 확인(최대 갯수 초과 시 획득 못함)
    check_dragon_inven = function()
        local function manage_func()
            self:click_manageBtn()
        end
        g_dragonsData:checkMaximumDragons(check_item_inven, manage_func)
    end

    -- 아이템 가방 확인(최대 갯수 초과 시 획득 못함)
    check_item_inven = function()
        local function manage_func()
            -- UI_Inventory() @kwkang 룬 업데이트로 룬 관리쪽으로 이동하게 변경 
            UI_RuneForge('manage')
        end
        g_inventoryData:checkMaximumItems(check_stamina, manage_func)
    end

    check_stamina = function()
        -- 스태미너 소모 체크
        local stage = g_challengeMode:getSelectedStage()
        local req_count = g_challengeMode:getChallengeMode_staminaCost(stage)

        if g_staminasData:hasStaminaCount('st', req_count) then
            start_game()
        else
            local function finish_cb()
            end
            local b_use_cash_label = false
            local b_open_spot_sale = true
            local st_charge_popup = UI_StaminaChargePopup(b_use_cash_label, b_open_spot_sale, finish_cb)
            UIManager:toastNotificationRed(Str('날개가 부족합니다.'))
            --MakeSimplePopup(POPUP_TYPE.YES_NO, Str('날개가 부족합니다.\n상점으로 이동하시겠습니까?'), function() g_shopData:openShopPopup('st', finish_cb) end)
        end
    end

    start_game = function()
        -- 콜로세움 시작 요청
        local function cb(ret)
            -- 시작이 두번 되지 않도록 하기 위함
            UI_BlockPopup()
            local scene = SceneGameChallengeMode(g_challengeMode.m_gameKey)
            scene:runScene()
        end

        -- 덱 변경 확인후 api 요청
        self:checkChangeDeck(function()
            g_challengeMode:request_challengeModeStart(cb)
        end)

    end

    check_dragon_inven()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ChallengeModeDeckSettings:refresh()
    PARENT.refresh(self)

    local stage = g_challengeMode:getSelectedStage()
    local cost = g_challengeMode:getChallengeMode_staminaCost(stage)
    self.vars['actingPowerLabel']:setString(tostring(cost))
end