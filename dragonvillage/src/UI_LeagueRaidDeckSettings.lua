local PARENT = UI_ReadySceneNew

-------------------------------------
-- class UI_LeagueRaidDeckSettings
-------------------------------------
UI_LeagueRaidDeckSettings = class(PARENT,{
        m_changeMode = 'boolean', -- true : 덱 변경만 가능, false : 덱변경 후 시작
        m_currTamerID = 'number',
    })

local NEED_CASH = 50 -- 유료 입장 다이아 개수

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_LeagueRaidDeckSettings:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_LeagueRaidDeckSettings'
    self.m_bVisible = true
    --self.m_titleStr = nil -- refresh에서 스테이지명 설정
    self.m_bUseExitBtn = true
    self.m_subCurrency = 'honor'
    self.m_addSubCurrency = 'valor'

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
function UI_LeagueRaidDeckSettings:init(stage_id, sub_info, bChangeMode)
    local vars = self.vars
    self.m_changeMode = bChangeMode or false -- 바로 시작인지 덱만 바꾸는 건지
    self.m_subInfo = sub_info
    cclog('UI_LeagueRaidDeckSettings' .. self.m_subInfo)
    -- 덱 변경만 가능
    if (self.m_changeMode) then
        vars['actingPowerNode']:setVisible(false)
        vars['startBtn']:registerScriptTapHandler(function() self:click_backBtn() end)
        vars['startBtnLabel']:setPositionX(0)
        vars['startBtnLabel']:setString(Str('변경 완료'))

    -- itemMenu에 입장권 체크하는 스케쥴러 등록
    else 
        -- 유료 입장권
        local icon = IconHelper:getItemIcon(ITEM_ID_CASH)
        icon:setScale(0.5)
        vars['staminaExtNode']:addChild(icon)
        vars['actingPowerExtLabel']:setString(NEED_CASH)

        vars['itemMenu']:scheduleUpdateWithPriorityLua(function(dt) self:update_stamina(dt) end, 0.1)
    end
end

-------------------------------------
-- function update_stamina
-- @brief
-------------------------------------
function UI_LeagueRaidDeckSettings:update_stamina(dt)    
    local vars = self.vars
    local is_enough = g_staminasData:checkStageStamina(ARENA_STAGE_ID)
    local is_enough_ext = g_staminasData:hasStaminaCount('arena_ext', 1)

    -- 기본 입장권 없을 경우엔 유료 입장권 개수 보여줌
    vars['actingPowerNode']:setVisible(is_enough)
    vars['actingPowerExtNode']:setVisible(not is_enough)
    vars['timeLabel']:setVisible(not is_enough)
    vars['staminaExtLabel']:setVisible(not is_enough)

    if (not is_enough) then
        local stamina_type = 'arena_ext'

        local time_str = g_staminasData:getChargeRemainText(stamina_type)
        vars['timeLabel']:setString(time_str)

        local st_ad = g_staminasData:getStaminaCount(stamina_type)
        local max_cnt = g_staminasData:getStaminaMaxCnt(stamina_type)
        local str = Str('{1}/{2}', comma_value(st_ad), comma_value(max_cnt))
        vars['staminaExtLabel']:setString(str)
    end

    -- 기본 입장권 & 유료 입장권 둘다 부족한 경우 - 시작 버튼 비활성화
    vars['startBtn']:setEnabled(is_enough or is_enough_ext)
end

-------------------------------------
-- function refresh_buffInfo_TamerBuff
-------------------------------------
function UI_LeagueRaidDeckSettings:refresh_buffInfo_TamerBuff()
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
function UI_LeagueRaidDeckSettings:getCurrTamerID()
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
function UI_LeagueRaidDeckSettings:click_tamerBtn()
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
function UI_LeagueRaidDeckSettings:click_backBtn()
	self:click_exitBtn()
end

-------------------------------------
-- function click_startBtn
-- @brief 시작 버튼
-------------------------------------
function UI_LeagueRaidDeckSettings:click_startBtn()
    -- 콜로세움 공격 덱이 설정되었는지 여부 체크
    local l_dragon_list = self.m_readySceneDeck.m_lDeckList
    if (table.count(l_dragon_list) <= 0) then
        MakeSimplePopup(POPUP_TYPE.OK, Str('콜로세움 덱이 설정되지 않았습니다.'))
        return
    end

    local check_dragon_inven
    local check_item_inven
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
        g_inventoryData:checkMaximumItems(start_game, manage_func)
    end

    start_game = function()
        -- 콜로세움 시작 요청
        local is_cash = false
        local function request()
            local function cb(ret)
                -- 시작이 두번 되지 않도록 하기 위함
                UI_BlockPopup()
                -- 스케쥴러 해제 (씬 이동하는 동안 입장권 모두 소모시 다이아로 바뀌는게 보기 안좋음)
                self.vars['itemMenu']:unscheduleUpdate()
                local scene = SceneGameArenaNew() -- PVP 개편 테스트용 임시 커밋
                scene:runScene()
            end

            -- 덱 변경 확인후 api 요청
            self:checkChangeDeck(function()
                g_arenaNewData:request_arenaStart(is_cash, nil, cb)
            end)
        end

        -- 기본 입장권 부족시
        if (not g_staminasData:checkStageStamina(ARENA_STAGE_ID)) then
            -- 유료 입장권 체크
            local is_enough, insufficient_num = g_staminasData:hasStaminaCount('arena_ext', 1)
            if (is_enough) then
                is_cash = true
                local msg = Str('입장권을 모두 소모하였습니다.\n{1}다이아몬드를 사용하여 진행하시겠습니까?', NEED_CASH)
                MakeSimplePopup_Confirm('cash', NEED_CASH, msg, request)

            -- 유료 입장권 부족시 입장 불가 
            else
                -- 스케쥴러에서 버튼 비활성화로 막음
            end
        else
            is_cash = false
            request()
        end
    end

    check_dragon_inven()
end