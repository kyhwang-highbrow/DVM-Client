local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_ColosseumReady
-------------------------------------
UI_ColosseumReady = class(PARENT,{
        m_player3DDeck = 'UI_3Ddeck',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ColosseumReady:init()
    local vars = self:load('colosseum_ready_new.ui')
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

    -- 연승 버프
    --vars['winBuffLabel']:setString(Str('연승버프 : {1}', ''))
    vars['winBuffLabel']:setString('')

    do -- 플레이어 유저 덱
        local player_3d_deck = UI_3DDeck()
        player_3d_deck.root:setPosition(-320, 76 - 100)
        self.root:addChild(player_3d_deck.root)
        player_3d_deck:initUI()

        local l_dragon_obj = g_colosseumData.m_playerUserInfo:getAtkDeck_dragonList()
        player_3d_deck:setDragonObjectList(l_dragon_obj)
        self.m_player3DDeck = player_3d_deck
    end

    do -- 상대방 유저 덱
        local player_3d_deck = UI_3DDeck()
        player_3d_deck.vars['formationNodeHelperXAxis']:setScale(-1)
        player_3d_deck.root:setPosition(320, 76 - 100)
        self.root:addChild(player_3d_deck.root)
        player_3d_deck:initUI()

        local l_dragon_obj = g_colosseumData:getMatchUserInfo():getDefDeck_dragonList()
        player_3d_deck:setDragonObjectList(l_dragon_obj)
    end    
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ColosseumReady:initButton()
    local vars = self.vars
    vars['deckBtn']:registerScriptTapHandler(function() self:click_deckBtn() end)
    vars['startBtn']:registerScriptTapHandler(function() self:click_startBtn() end)
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
    local with_friend = nil
    local ui = UI_ReadyScene(COLOSSEUM_STAGE_ID, with_friend, 'atk')
    local function close_cb()
        local player_3d_deck = self.m_player3DDeck
        local l_dragon_obj = g_colosseumData.m_playerUserInfo:getAtkDeck_dragonList()
        player_3d_deck:setDragonObjectList(l_dragon_obj)
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

    -- 콜로세움 시작 요청
    local is_cash = false
    local function request()
        local function cb(ret)
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

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ColosseumReady:click_exitBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_ColosseumReady)
