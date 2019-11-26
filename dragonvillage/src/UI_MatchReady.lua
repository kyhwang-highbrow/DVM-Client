local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_MatchReady
-------------------------------------
UI_MatchReady = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_MatchReady:init()
    local vars = self:load('arena_ready.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_MatchReady')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_MatchReady:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_MatchReady'
    self.m_bVisible = true
    self.m_titleStr = Str('VS')
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
function UI_MatchReady:initUI()
    local vars = self.vars
    
	-- 클랜전 메뉴 초기화
	vars['clanWarMenu']:setVisible(false)
    vars['clanWarBgSprite']:setVisible(false)

    self:initStaminaInfo()

    do -- 플레이어 유저 덱
        local user_info = self:getStructUserInfo_Player()
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
    end

    do -- 상대방 유저 덱
        local user_info = self:getStructUserInfo_Opponent()
        local t_pvp_deck = user_info.m_pvpDeck

        local player_2d_deck = UI_2DDeck(true, true)
        player_2d_deck:setDirection('right')
        vars['formationNode2']:removeAllChildren()
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
function UI_MatchReady:initUI_userInfo()
    local vars = self.vars

    do -- 플레이어 유저 정보
        local user_info = self:getStructUserInfo_Player()
        
        -- 레벨, 닉네임
        vars['userLabel1']:setString(user_info:getUserText())

        -- 전투력
        local str = user_info:getDeckCombatPower(true)
        str = comma_value(str)
        vars['powerLabel1']:setString(Str('전투력 : {1}', str))

        -- 아이콘
        icon = user_info:getDeckTamerIcon()
        if (icon) then
            vars['tamerNode1']:removeAllChildren()
            vars['tamerNode1']:addChild(icon)
        end
    end

    do -- 상대방 유저 정보
        local user_info = self:getStructUserInfo_Opponent()

        -- 레벨, 닉네임
        vars['userLabel2']:setString(user_info:getUserText())

        -- 전투력
        local str = user_info:getDeckCombatPower()
        str = comma_value(str)
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
function UI_MatchReady:initButton()
    local vars = self.vars
    vars['deckBtn']:registerScriptTapHandler(function() self:click_deckBtn() end)
    vars['startBtn']:registerScriptTapHandler(function() self:click_startBtn() end)
    vars['teamBonusBtn1']:registerScriptTapHandler(function() self:click_teamBonusBtn(true) end)
    vars['teamBonusBtn2']:registerScriptTapHandler(function() self:click_teamBonusBtn(false) end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_MatchReady:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_manageBtn
-- @brief 드래곤 관리 버튼
-------------------------------------
function UI_MatchReady:click_manageBtn()
    local ui = UI_DragonManageInfo()
    local function close_cb()
        local function func()
            self:initUI()
        end
        self:sceneFadeInAction(func)
    end
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_teamBonusBtn
-------------------------------------
function UI_MatchReady:click_teamBonusBtn(mine)
    local l_deck
    -- 내 덱
    if (mine) then
        l_deck = self:getStructUserInfo_Player():getDeck_dragonList()
    -- 상대 덱
    else
        l_deck = self:getStructUserInfo_Opponent():getDeck_dragonList()
    end

    local ui = UI_TeamBonus(TEAM_BONUS_MODE.TOTAL, l_deck)
    if (not mine) then
        ui:setOnlyMyTeamBonus()
    end
end






-------------------------------------
-- function initStaminaInfo
-------------------------------------
function UI_MatchReady:initStaminaInfo()
    error() -- 자식 클래스에서 정의할 것
end

-------------------------------------
-- function getStructUserInfo_Player
-------------------------------------
function UI_MatchReady:getStructUserInfo_Player()
    error() -- 자식 클래스에서 정의할 것
end

-------------------------------------
-- function getStructUserInfo_Opponent
-------------------------------------
function UI_MatchReady:getStructUserInfo_Opponent()
    error() -- 자식 클래스에서 정의할 것
end

-------------------------------------
-- function click_deckBtn
-- @brief 출전 덱 변경
-------------------------------------
function UI_MatchReady:click_deckBtn()
    error() -- 자식 클래스에서 정의할 것
end


-------------------------------------
-- function click_startBtn
-- @brief 시작 버튼
-------------------------------------
function UI_MatchReady:click_startBtn()
    error() -- 자식 클래스에서 정의할 것
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_MatchReady:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_MatchReady)