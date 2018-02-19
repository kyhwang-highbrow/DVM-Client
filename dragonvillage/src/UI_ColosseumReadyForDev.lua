local PARENT = UI_ColosseumReady

-------------------------------------
-- class UI_ColosseumReadyForDev
-------------------------------------
UI_ColosseumReadyForDev = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ColosseumReadyForDev:init()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_ColosseumReadyForDev:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ColosseumReadyForDev'
    self.m_bVisible = true
    self.m_titleStr = Str('콜로세움(테스트모드)')
    self.m_bUseExitBtn = true

    -- 입장권 타입 설정
    self.m_staminaType = 'pvp'
    self.m_subCurrency = 'honor'
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ColosseumReadyForDev:initUI()
    local vars = self.vars

    -- 스태미나 아이콘
    local icon = IconHelper:getStaminaInboxIcon('pvp')
    vars['staminaNode']:removeAllChildren()
    vars['staminaNode']:addChild(icon)

    -- 스태미나 갯수
    vars['actingPowerLabel']:setString('0')

    do -- 플레이어 유저 덱
        local t_pvp_deck = g_colosseumData.m_playerUserInfo.m_pvpAtkDeck

        local player_2d_deck = UI_2DDeck()
        player_2d_deck:setDirection('left')
        player_2d_deck.root:setPosition(-380, 76)
        self.root:addChild(player_2d_deck.root)
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
        local t_pvp_deck = g_colosseumData.m_playerUserInfo.m_pvpDefDeck

        local player_2d_deck = UI_2DDeck()
        player_2d_deck:setDirection('right')
        player_2d_deck.root:setPosition(380, 76)
        self.root:addChild(player_2d_deck.root)
        player_2d_deck:initUI()

        local l_dragon_obj = g_colosseumData.m_playerUserInfo:getDefDeck_dragonList()
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
function UI_ColosseumReadyForDev:initUI_userInfo()
    local vars = self.vars

    -- user_info의 class : StructUserInfoColosseum
    do
        -- 레벨, 닉네임
        local user_info = g_colosseumData.m_playerUserInfo
        vars['userLabel1']:setString(user_info:getUserText())

        -- 전투력
        local str = user_info:getAtkDeckCombatPower()
        vars['powerLabel1']:setString(Str('전투력 : {1}', str))

        -- 아이콘
        local icon = user_info:getAtkDeckTamerReadyIcon()
        vars['tamerNode1']:removeAllChildren()
        vars['tamerNode1']:addChild(icon)
    end

    do
        -- 레벨, 닉네임
        local user_info = g_colosseumData.m_playerUserInfo
        vars['userLabel2']:setString(user_info:getUserText())

        -- 전투력
        local str = user_info:getDefDeckCombatPower()
        vars['powerLabel2']:setString(Str('전투력 : {1}', str))

        -- 아이콘
        local icon = user_info:getDefDeckTamerReadyIcon()
        vars['tamerNode2']:removeAllChildren()
        vars['tamerNode2']:addChild(icon)
    end
end

-------------------------------------
-- function click_startBtn
-- @brief 시작 버튼
-------------------------------------
function UI_ColosseumReadyForDev:click_startBtn()

    -- 콜로세움 공격 덱이 설정되었는지 여부 체크
    local l_dragon_obj = g_colosseumData.m_playerUserInfo:getAtkDeck_dragonList()
    if (table.count(l_dragon_obj) <= 0) then
        local function yes()
            self:click_deckBtn()
        end
        MakeSimplePopup(POPUP_TYPE.YES_NO, Str('콜로세움 출전 덱이 설정되지 않았습니다.\n출전 덱을 설정하시겠습니까?'), yes)
        return
    end

    -- 콜로세움 시작
    do
        UI_BlockPopup()

        local scene = SceneGameColosseum(nil, nil, nil, true)
        scene:runScene()
    end
end
