local PARENT = UI_ReadySceneNew

local NEED_CASH = 50 -- 유료 입장 다이아 개수

-------------------------------------
-- class UI_GrandArenaDeckSettings
-------------------------------------
UI_GrandArenaDeckSettings = class(PARENT,{
        m_currTamerID = 'number',
    })


-------------------------------------
-- function init
-------------------------------------
function UI_GrandArenaDeckSettings:init(stage_id, sub_info)
    local vars = self.vars

    -- 유료 입장권
    local icon = IconHelper:getItemIcon(ITEM_ID_CASH)
    icon:setScale(0.5)
    vars['staminaExtNode']:addChild(icon)
    vars['actingPowerExtLabel']:setString(NEED_CASH)
    vars['itemMenu']:scheduleUpdateWithPriorityLua(function(dt) self:update_stamina(dt) end, 0.1)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_GrandArenaDeckSettings:initButton()
    PARENT.initButton(self)
    local vars = self.vars

    -- 연습전 기간일 경우
    local grand_arena_state = g_grandArena:getGrandArenaState()
    if (grand_arena_state == ServerData_GrandArena.STATE['PRESEASON']) then
        vars['startBtn']:registerScriptTapHandler(function() self:click_startBtn_preseason() end)

        -- 연속 전투 버튼 숨김
        vars['autoStartOnBtn']:setVisible(false)
        vars['manageBtn']:setPositionX(80)
        vars['teamBonusBtn']:setPositionX(-80)
    end
end

-------------------------------------
-- function getCurrTamerID
-------------------------------------
function UI_GrandArenaDeckSettings:getCurrTamerID()
    if (not self.m_currTamerID) then
        local l_deck, formation, deckname, leader, tamer_id = g_deckData:getDeck('grand_arena_up')
        self.m_currTamerID = tamer_id
    end
    return self.m_currTamerID
end

-------------------------------------
-- function click_tamerBtn
-- @breif
-------------------------------------
function UI_GrandArenaDeckSettings:click_tamerBtn()
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
-- function update_stamina
-- @brief
-------------------------------------
function UI_GrandArenaDeckSettings:update_stamina(dt)
    local vars = self.vars
    local is_enough = g_staminasData:checkStageStamina(GRAND_ARENA_STAGE_ID)
    local is_enough_ext = g_staminasData:hasStaminaCount('grand_arena_ext', 1)

    -- 기본 입장권 없을 경우엔 유료 입장권 개수 보여줌
    vars['actingPowerNode']:setVisible(is_enough)
    vars['actingPowerExtNode']:setVisible(not is_enough)
    vars['timeLabel']:setVisible(not is_enough)
    vars['staminaExtLabel']:setVisible(not is_enough)

    if (not is_enough) then
        local stamina_type = 'grand_arena_ext'

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
-- function click_startBtn
-- @brief 시작 버튼
-------------------------------------
function UI_GrandArenaDeckSettings:click_startBtn()
    local check_change_deck
    local check_deck_setting
    local check_dragon_inven
    local check_item_inven
    local confirm
    local check_stamina_type
        local confirm_cash_stamina -- 상황에 따라 호출되는 함수여서 들여쓰기함
    local request_match_list
    local open_match_list_ui
    local start_game


    -- 덱 변경 확인 (덱이 변경되었으면 갱신 통신)
    check_change_deck = function()
        self:checkChangeDeck(check_deck_setting)
    end

    -- 그랜드 콜로세움 덱이 설정되었는지 여부 체크
    check_deck_setting = function()
        -- 상단, 하단 덱 모두 체크
        local multi_deck_mgr = self.m_multiDeckMgr
        if (not multi_deck_mgr:checkDeckCondition()) then
            return
        end

        check_dragon_inven()
    end

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
            UI_Inventory()
        end
        g_inventoryData:checkMaximumItems(confirm, manage_func)
    end

    -- 입장권이 소모가 됨을 알림
    confirm = function()

        -- 최초 1회만 안내 팝업을 띄움
        local save_key = ('event_grand_arena' .. '_stamina')
        local is_view = g_settingData:get('popup_only_once', save_key) or false
        if (is_view) then
            check_stamina_type()
            return
        else
            g_settingData:applySettingData(true, 'popup_only_once', save_key)
        end

        local msg1 = Str('그랜드 콜로세움에서는 입장권을 먼저 사용한 후 대전 상대를 선택합니다.')
        local msg2 = Str('입장권 사용 후에는 취소할 수 없으며 사용한 입장권은 복구되지 않습니다.')
        local msg = msg1 .. '\n' .. msg2
        local ok_cb = check_stamina_type
        MakeSimplePopup(POPUP_TYPE.YES_NO, msg, ok_cb)
    end

    -- 입장권 확인
    -- grand_arena를 사용하고 모두 소모하면 다이아와 함께 grand_arena_ext를 소모
    check_stamina_type = function()
        -- stage_id에 해당하는 stamina가 있는지 확인
        if (g_staminasData:checkStageStamina(GRAND_ARENA_STAGE_ID)) then
            request_match_list(false) -- param : is_cash
        else
            confirm_cash_stamina()
        end
    end

        -- 다이아로 입장이 필요한 경우 (상황에 따라 호출되는 함수여서 들여쓰기함)
        confirm_cash_stamina = function()
            -- 유료 입장권 체크
            local is_enough, insufficient_num = g_staminasData:hasStaminaCount('grand_arena_ext', 1)
            if (is_enough) then
                local function request()
                    request_match_list(true) -- param : is_cash
                end
                local msg = Str('입장권을 모두 소모하였습니다.\n{1}다이아몬드를 사용하여 진행하시겠습니까?', NEED_CASH)
                MakeSimplePopup_Confirm('cash', NEED_CASH, msg, request)

            -- 유료 입장권 부족시 입장 불가 
            else
                -- 스케쥴러에서 버튼 비활성화로 막혀있는 상태 (클릭이 불가능한 상황)
            end
        end

    -- 매치 리스트 정보 얻어옴
    request_match_list = function(is_cash)
        local finish_cb = open_match_list_ui
        g_grandArena:request_grandArenaGetMatchList(is_cash, finish_cb, nil) -- param : is_cash, finish_cb, fail_cb

        -- 스케쥴러 해제 (씬 이동하는 동안 입장권 모두 소모시 다이아로 바뀌는게 보기 안좋음)
        self.vars['itemMenu']:unscheduleUpdate()
    end

    -- 매치 리스트 UI 오픈
    open_match_list_ui = function()
        UI_GrandArenaMatchList()
    end


    -- 시작 함수 호출
    check_change_deck()
end

-------------------------------------
-- function click_startBtn_preseason
-- @brief 시작 버튼 (연습전 기간)
-------------------------------------
function UI_GrandArenaDeckSettings:click_startBtn_preseason()
    local check_change_deck
    local check_deck_setting
    local open_matchlist_ui

    -- 덱 변경 확인 (덱이 변경되었으면 갱신 통신)
    check_change_deck = function()
        self:checkChangeDeck(check_deck_setting)
    end

    -- 그랜드 콜로세움 덱이 설정되었는지 여부 체크
    check_deck_setting = function()
        -- 상단, 하단 덱 모두 체크
        local multi_deck_mgr = self.m_multiDeckMgr
        if (not multi_deck_mgr:checkDeckCondition()) then
            return
        end

        open_matchlist_ui()
    end

    -- 매치리스트
    open_matchlist_ui = function()

        -- 프리시즌용 데이터 설정 후 UI 이동
        g_grandArena:setPreseasonData()
        UI_GrandArenaMatchList(true) -- param : is_preseason
    end

    -- 시작 함수 호출
    check_change_deck()
end