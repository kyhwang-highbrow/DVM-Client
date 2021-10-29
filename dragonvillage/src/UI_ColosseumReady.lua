local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_ColosseumReady
-------------------------------------
UI_ColosseumReady = class(PARENT,{
        m_player2DDeck = 'UI_2Ddeck',
        m_bClosedTag = 'boolean', -- 시즌이 종료되어 처리를 했는지 여부
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ColosseumReady:init()
    self.m_bClosedTag = nil

    local vars = self:load('colosseum_ready.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ColosseumReady')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_ColosseumReady:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ColosseumReady'
    self.m_bVisible = true
    self.m_titleStr = Str('콜로세움')
    self.m_bUseExitBtn = true

    -- 입장권 타입 설정
    self.m_staminaType = 'pvp'
    self.m_subCurrency = 'honor'
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ColosseumReady:initUI()
    local vars = self.vars

    -- 스태미나 아이콘
    local icon = IconHelper:getStaminaInboxIcon('pvp')
    vars['staminaNode']:removeAllChildren()
    vars['staminaNode']:addChild(icon)

    -- 스태미나 갯수
    vars['actingPowerLabel']:setString('1')

    do -- 플레이어 유저 덱
        local t_pvp_deck = g_colosseumData.m_playerUserInfo.m_pvpAtkDeck

        local player_2d_deck = UI_2DDeck()
        player_2d_deck:setDirection('left')
        vars['formationNode1']:addChild(player_2d_deck.root)
        player_2d_deck:initUI()

        local l_dragon_obj = g_colosseumData.m_playerUserInfo:getAtkDeck_dragonList()
        local leader = t_pvp_deck and t_pvp_deck['leader'] or 0
        player_2d_deck:setDragonObjectList(l_dragon_obj, leader)
        self.m_player2DDeck = player_2d_deck

        -- 진형 설정
        local formation = 'attack'
        if t_pvp_deck then
            formation = t_pvp_deck['formation'] or 'attack'
        end
        self.m_player2DDeck:setFormation(formation)
    end

    do -- 상대방 유저 덱
        local t_pvp_deck = g_colosseumData:getMatchUserInfo().m_pvpDefDeck

        local player_2d_deck = UI_2DDeck()
        player_2d_deck:setDirection('right')
        vars['formationNode2']:addChild(player_2d_deck.root)
        player_2d_deck:initUI()

        local l_dragon_obj = g_colosseumData:getMatchUserInfo():getDefDeck_dragonList()
        local leader = t_pvp_deck and t_pvp_deck['leader'] or 0
        player_2d_deck:setDragonObjectList(l_dragon_obj, leader)

        -- 진형 설정
        local formation = 'attack'
        if t_pvp_deck then
            formation = t_pvp_deck['formation'] or 'attack'
        end
        player_2d_deck:setFormation(formation)
    end

    -- UI가 enter로 진입되었을 때 update함수 호출
    self.root:registerScriptHandler(function(event)
        if (event == 'enter') then
            self.root:scheduleUpdateWithPriorityLua(function(dt) return self:update(dt) end, 0)
        end
    end)
    self.root:scheduleUpdateWithPriorityLua(function(dt) return self:update(dt) end, 0)

    self:initUI_userInfo()
end

-------------------------------------
-- function initUI_userInfo
-------------------------------------
function UI_ColosseumReady:initUI_userInfo()
    local vars = self.vars

    -- user_info의 class : StructUserInfoColosseum
    do
        -- 레벨, 닉네임
        local user_info = g_colosseumData.m_playerUserInfo
        vars['userLabel1']:setString(user_info:getUserText())

        -- 전투력
        local str = user_info:getAtkDeckCombatPower(true)
        vars['powerLabel1']:setString(Str('전투력 : {1}', comma_value(str)))

        -- 아이콘
        local icon = user_info:getAtkDeckTamerReadyIcon()
        vars['tamerNode1']:removeAllChildren()
        vars['tamerNode1']:addChild(icon)
    end

    do
        local user_info = g_colosseumData:getMatchUserInfo()

        -- 레벨, 닉네임
        vars['userLabel2']:setString(user_info:getUserText())

        -- 전투력
        local str = user_info:getDefDeckCombatPower()
        vars['powerLabel2']:setString(Str('전투력 : {1}', comma_value(str)))

        -- 아이콘
        local icon = user_info:getDefDeckTamerReadyIcon()
        vars['tamerNode2']:removeAllChildren()
        vars['tamerNode2']:addChild(icon)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ColosseumReady:initButton()
    local vars = self.vars
    vars['deckBtn']:registerScriptTapHandler(function() self:click_deckBtn() end)
    vars['startBtn']:registerScriptTapHandler(function() self:click_startBtn() end)
    vars['teamBonusBtn1']:registerScriptTapHandler(function() self:click_teamBonusBtn(true) end)
    vars['teamBonusBtn2']:registerScriptTapHandler(function() self:click_teamBonusBtn(false) end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ColosseumReady:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_deckBtn
-- @brief 출전 덱 변경
-------------------------------------
function UI_ColosseumReady:click_deckBtn()
    local ui = UI_ColosseumDeckSettings(COLOSSEUM_STAGE_ID, 'atk')
    local function close_cb()
        local t_pvp_deck = g_colosseumData.m_playerUserInfo.m_pvpAtkDeck

        local player_2d_deck = self.m_player2DDeck
        local l_dragon_obj = g_colosseumData.m_playerUserInfo:getAtkDeck_dragonList()
        local leader = t_pvp_deck and t_pvp_deck['leader'] or 0
        player_2d_deck:setDragonObjectList(l_dragon_obj, leader)

        -- 진형 설정
        local formation = 'attack'
        if t_pvp_deck then
            formation = t_pvp_deck['formation'] or 'attack'
        end
        self.m_player2DDeck:setFormation(formation)

        -- 유저 정보도 변경 (테이머가 갱신될 수 있음)
        self:initUI_userInfo()
    end
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_startBtn
-- @brief 시작 버튼
-------------------------------------
function UI_ColosseumReady:click_startBtn()

    -- 콜로세움 공격 덱이 설정되었는지 여부 체크
    local l_dragon_obj = g_colosseumData.m_playerUserInfo:getAtkDeck_dragonList()
    if (table.count(l_dragon_obj) <= 0) then
        local function yes()
            self:click_deckBtn()
        end
        MakeSimplePopup(POPUP_TYPE.YES_NO, Str('콜로세움 출전 덱이 설정되지 않았습니다.\n출전 덱을 설정하시겠습니까?'), yes)
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

                local scene = SceneGameColosseum()
                scene:runScene()
            end

            g_colosseumData:request_colosseumStart(is_cash, g_colosseumData.m_matchUserID, cb)
        end

        if (not g_staminasData:checkStageStamina(COLOSSEUM_STAGE_ID)) then
            is_cash = true
            local cash = 50
            local msg = Str('입장권을 모두 소모하였습니다.\n{1}다이아몬드를 사용하여 진행하시겠습니까?', cash)
            MakeSimplePopup_Confirm('cash', cash, msg, request)
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
function UI_ColosseumReady:click_manageBtn()
    local ui = UI_DragonManageInfo()
    local function close_cb()
        local function func()
            -- 콜로세움 덱(atk, def)에 출전 중인 드래곤은
            -- 삭제(작별or판매)가 불가하기 때문에 덱 정보가 변경되지 않는다는 가정 하에
            -- refresh 작업을 별도로 하지 않음
        end
        local ui = UIManager:getLastUI()
        ui:sceneFadeInAction(func)
    end
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_teamBonusBtn
-------------------------------------
function UI_ColosseumReady:click_teamBonusBtn(mine)
    local l_deck
    -- 내 덱
    if (mine) then
        l_deck = g_colosseumData.m_playerUserInfo:getAtkDeck_dragonList()
    -- 상대 덱
    else
        l_deck = g_colosseumData:getMatchUserInfo():getDefDeck_dragonList()
    end

    local ui = UI_TeamBonus(TEAM_BONUS_MODE.TOTAL, l_deck)
    if (not mine) then
        ui:setOnlyMyTeamBonus()
    end
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ColosseumReady:click_exitBtn()
    self:close()
end

-------------------------------------
-- function update
-------------------------------------
function UI_ColosseumReady:update(dt)
    -- UI내에서 시즌이 종료되는 경우 예외처리
    if self.m_bClosedTag then
        return

    elseif (not g_colosseumData:isOpenColosseum()) then
        local function ok_cb()
            -- 로비로 이동
            UINavigator:goTo('lobby')
        end
        MakeSimplePopup(POPUP_TYPE.OK, Str('콜로세움 시즌이 종료되었습니다.'), ok_cb)
        self.m_bClosedTag = true
        return
    end

    local vars = self.vars

    do -- 연승 버프 텍스트 출력
        local time_str, active = g_colosseumData:getStraightTimeText()

        local text = nil
        if active then
            local title = g_colosseumData:getStraightBuffTitle()
            local text = g_colosseumData:getStraightBuffText()
            vars['buffLabel1']:setString(title)
            vars['buffLabel2']:setString(time_str)
            vars['buffLabel3']:setString(text)
        else
            vars['buffLabel1']:setString(Str('연승 버프'))
            vars['buffLabel2']:setString(Str('연승 버프 없음'))
            vars['buffLabel3']:setString('')
        end
    end
end

--@CHECK
UI:checkCompileError(UI_ColosseumReady)
