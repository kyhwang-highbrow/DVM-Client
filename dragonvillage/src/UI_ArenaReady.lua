local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_ArenaReady
-------------------------------------
UI_ArenaReady = class(PARENT,{
        m_player2DDeck = 'UI_2Ddeck',
        m_bClosedTag = 'boolean', -- 시즌이 종료되어 처리를 했는지 여부
        m_historyID = 'number',
    })

local NEED_CASH = 50 -- 유료 입장 다이아 개수

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaReady:init()
    self.m_bClosedTag = nil
    -- 해당 UI는 재도전, 복수전일 경우에만 진입 가능 
    self.m_historyID = g_arenaData:getMatchUserInfo().m_history_id

    local vars = self:load('arena_ready.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ArenaReady')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    -- 유료 입장권
    local icon = IconHelper:getItemIcon(ITEM_ID_CASH)
    icon:setScale(0.5)
    vars['staminaExtNode']:addChild(icon)
    vars['actingPowerExtLabel']:setString(NEED_CASH)

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update_stamina(dt) end, 0.1)
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_ArenaReady:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ArenaReady'
    self.m_bVisible = true
    self.m_titleStr = Str('콜로세움')
    self.m_bUseExitBtn = true
    self.m_subCurrency = 'honor'
    self.m_addSubCurrency = 'valor'

    -- 입장권 타입 설정
    self.m_staminaType = TableDrop:getStageStaminaType(ARENA_STAGE_ID)
    self.m_uiBgm = 'bgm_dungeon_ready'
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ArenaReady:initUI()
    local vars = self.vars

	-- 클랜전 메뉴 초기화
    vars['clanWarMenu']:setVisible(false)
    vars['clanWarBgSprite']:setVisible(false)

    -- 스태미나 아이콘
    local stamina = TableDrop:getStageStaminaType(ARENA_STAGE_ID)
    local icon = IconHelper:getStaminaInboxIcon(stamina)
    vars['staminaNode']:removeAllChildren()
    vars['staminaNode']:addChild(icon)

    -- 스태미나 갯수
    vars['actingPowerLabel']:setString('1')

    do -- 플레이어 유저 덱
        local user_info = g_arenaData:getPlayerArenaUserInfo()
        local t_pvp_deck = user_info.m_pvpDeck

        local player_2d_deck = UI_2DDeck(true, true)
        player_2d_deck:setDirection('left')
        vars['formationNode1']:addChild(player_2d_deck.root)
        player_2d_deck:initUI()

        local l_dragon_obj = user_info:getDeck_dragonList()
        local leader = t_pvp_deck and t_pvp_deck['leader'] or 0
        player_2d_deck:setDragonObjectList(l_dragon_obj, leader)
        
        -- 진형 설정
        local formation = 'attack'
        if t_pvp_deck then
            formation = t_pvp_deck['formation'] or 'attack'
        end
        player_2d_deck:setFormation(formation)
    end

    do -- 상대방 유저 덱
        local user_info = g_arenaData:getMatchUserInfo()
        local t_pvp_deck = user_info.m_pvpDeck

        local player_2d_deck = UI_2DDeck(true, true)
        player_2d_deck:setDirection('right')
        vars['formationNode2']:addChild(player_2d_deck.root)
        player_2d_deck:initUI()

        local l_dragon_obj = user_info:getDeck_dragonList()
        local leader = t_pvp_deck and t_pvp_deck['leader'] or 0
        player_2d_deck:setDragonObjectList(l_dragon_obj, leader)

        -- 진형 설정
        local formation = 'attack'
        if t_pvp_deck then
            formation = t_pvp_deck['formation'] or 'attack'
        end
        player_2d_deck:setFormation(formation)
    end

    self:initUI_userInfo()
end

-------------------------------------
-- function initUI_userInfo
-------------------------------------
function UI_ArenaReady:initUI_userInfo()
    local vars = self.vars

    do -- 플레이어 유저 정보
        local user_info = g_arenaData:getPlayerArenaUserInfo()
        
        -- 레벨, 닉네임
        vars['userLabel1']:setString(user_info:getUserText())

        -- 전투력
        local str = user_info:getDeckCombatPower(true)
        vars['powerLabel1']:setString(Str('전투력 : {1}', str))

        -- 아이콘
        icon = user_info:getDeckTamerIcon()
        if (icon) then
            vars['tamerNode1']:removeAllChildren()
            vars['tamerNode1']:addChild(icon)
        end
    end

    do -- 상대방 유저 정보
        local user_info = g_arenaData:getMatchUserInfo()

        -- 레벨, 닉네임
        vars['userLabel2']:setString(user_info:getUserText())

        -- 전투력
        local str = user_info:getDeckCombatPower()
        vars['powerLabel2']:setString(Str('전투력 : {1}', str))

        -- 아이콘
        icon = user_info:getDeckTamerIcon()
        if (icon) then
            vars['tamerNode2']:addChild(icon)
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ArenaReady:initButton()
    local vars = self.vars
    vars['deckBtn']:registerScriptTapHandler(function() self:click_deckBtn() end)
    vars['startBtn']:registerScriptTapHandler(function() self:click_startBtn() end)
    vars['teamBonusBtn1']:registerScriptTapHandler(function() self:click_teamBonusBtn(true) end)
    vars['teamBonusBtn2']:registerScriptTapHandler(function() self:click_teamBonusBtn(false) end)
end

-------------------------------------
-- function update_stamina
-- @brief
-------------------------------------
function UI_ArenaReady:update_stamina(dt)    
    local vars = self.vars
    local is_enough = g_staminasData:checkStageStamina(ARENA_STAGE_ID)
    local is_enough_ext = g_staminasData:hasStaminaCount('arena_ext', 1)

    -- 기본 입장권 없을 경우엔 유료 입장권 개수 보여줌
    vars['staminaNode']:setVisible(is_enough)
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
-- function refresh
-------------------------------------
function UI_ArenaReady:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_deckBtn
-- @brief 출전 덱 변경
-------------------------------------
function UI_ArenaReady:click_deckBtn()
    local vars = self.vars 
    local deck_change_mode = true
    local ui = UI_ArenaDeckSettings(ARENA_STAGE_ID, deck_change_mode)
    local function close_cb()
        local user_info = g_arenaData:getPlayerArenaUserInfo()
        local t_pvp_deck = user_info.m_pvpDeck

        local player_2d_deck = UI_2DDeck(true, true)
        player_2d_deck:setDirection('left')

        vars['formationNode1']:removeAllChildren()
        vars['formationNode1']:addChild(player_2d_deck.root)
        player_2d_deck:initUI()

        local l_dragon_obj = user_info:getDeck_dragonList()
        local leader = t_pvp_deck and t_pvp_deck['leader'] or 0
        player_2d_deck:setDragonObjectList(l_dragon_obj, leader)
        
        -- 진형 설정
        local formation = 'attack'
        if t_pvp_deck then
            formation = t_pvp_deck['formation'] or 'attack'
        end
        player_2d_deck:setFormation(formation)

        -- 유저 정보도 변경 (테이머가 갱신될 수 있음)
        self:initUI_userInfo()
    end
    ui:setCloseCB(close_cb)
end


-------------------------------------
-- function click_startBtn
-- @brief 시작 버튼
-------------------------------------
function UI_ArenaReady:click_startBtn()
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
                self.root:unscheduleUpdate()
                local scene = SceneGameArena()
                scene:runScene()
            end

            -- self.m_historyID이 nil이 아닌 경우 재도전, 복수전
            g_arenaData:request_arenaStart(is_cash, self.m_historyID, cb)
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


-------------------------------------
-- function click_manageBtn
-- @brief 시작 버튼
-------------------------------------
function UI_ArenaReady:click_manageBtn()
    local ui = UI_DragonManageInfo()
    local function close_cb()
        local function func()
            -- 콜로세움 덱(atk, def)에 출전 중인 드래곤은
            -- 삭제(작별or판매)가 불가하기 때문에 덱 정보가 변경되지 않는다는 가정 하에
            -- refresh 작업을 별도로 하지 않음
        end
        self:sceneFadeInAction(func)
    end
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_teamBonusBtn
-------------------------------------
function UI_ArenaReady:click_teamBonusBtn(mine)
    local l_deck
    -- 내 덱
    if (mine) then
        l_deck = g_arenaData.m_playerUserInfo:getDeck_dragonList()
    -- 상대 덱
    else
        l_deck = g_arenaData:getMatchUserInfo():getDeck_dragonList()
    end

    local ui = UI_TeamBonus(TEAM_BONUS_MODE.TOTAL, l_deck)
    if (not mine) then
        ui:setOnlyMyTeamBonus()
    end
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ArenaReady:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_ArenaReady)