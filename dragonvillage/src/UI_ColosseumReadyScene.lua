local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_ColosseumReadyScene
-------------------------------------
UI_ColosseumReadyScene = class(PARENT,{
		m_stageAttr = 'str',
        m_tableViewExt = 'TableViewExtension',

        -- UI_ReadyScene_Deck 관련 변수
        m_readySceneDeck = 'UI_ReadyScene_Deck',

        -- 정렬 도우미
        m_dragonSortMgr = 'DragonSortManager',

        m_bOpenedFormationUI = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ColosseumReadyScene:init()
    local vars = self:load('colosseum_ready.ui')
    UIManager:open(self, UIManager.SCENE)

    -- 씬 전환 효과
    self:sceneFadeInAction()

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_backBtn() end, 'UI_ColosseumReadyScene')

	g_deckData:setSelectedDeck('pvp')
    
	self:initUI()
    self:initButton()
    self:refresh()

	self.m_stageAttr = nil
    self.m_readySceneDeck = UI_ColosseumReadyScene_Deck(self)
	self:init_sortMgr()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_ColosseumReadyScene:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ColosseumReadyScene'
    self.m_titleStr = Str('콜로세움 준비')
	self.m_staminaType = 'pvp'
    self.m_bVisible = true
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function init_sortMgr
-------------------------------------
function UI_ColosseumReadyScene:init_sortMgr(stage_id)
    self.m_dragonSortMgr = DragonSortManagerReady(self.vars, self.m_tableViewExt)

    local function func(doid)
        return self.m_readySceneDeck.m_tDeckMap[doid]
    end

    self.m_dragonSortMgr:setIsSettedDragonFunc(func)
    self.m_dragonSortMgr:changeSort()
end


-------------------------------------
-- function initUI
-------------------------------------
function UI_ColosseumReadyScene:initUI()
    self:init_dragonTableView()
    self:initFormationUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ColosseumReadyScene:initButton()
    local vars = self.vars
    vars['manageBtn']:registerScriptTapHandler(function() self:click_manageBtn() end)
	vars['autoBtn']:registerScriptTapHandler(function() self:click_autoBtn() end)
    vars['removeBtn']:registerScriptTapHandler(function() self:click_removeBtn() end)
    vars['startBtn']:registerScriptTapHandler(function() self:click_startBtn() end)

    vars['tamerBtn']:registerScriptTapHandler(function() self:click_tamerBtn() end)
    vars['tamerBtn']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)

    -- 진형 관린
    vars['fomationBtn']:registerScriptTapHandler(function() self:click_fomationBtn() end)
    vars['fomationSetColseBtn']:registerScriptTapHandler(function() self:click_fomationSetColseBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ColosseumReadyScene:refresh()
    local vars = self.vars

    do -- 필요 활동력 표시
        local stamina_type, stamina_value = self:getStageStaminaInfo()
        vars['actingPowerLabel']:setString(stamina_value)
    end

    self:refresh_tamer()
end

-------------------------------------
-- function refresh_tamer
-------------------------------------
function UI_ColosseumReadyScene:refresh_tamer()
    local vars = self.vars

    vars['tamerNode']:removeAllChildren()

	local tamer_res = g_userData:getTamerInfo('res_sd')
    local animator = MakeAnimator(tamer_res)
	if (animator) then
		animator:setDockPoint(0.5, 0.5)
		animator:setAnchorPoint(0.5, 0.5)
		animator:setScale(2)
		animator:setPosition(0, 50)
		vars['tamerNode']:addChild(animator.m_node)
	end
end

-------------------------------------
-- function init_dragonTableView
-------------------------------------
function UI_ColosseumReadyScene:init_dragonTableView()
    local list_table_node = self.vars['listView']
    list_table_node:removeAllChildren()

    local function create_func(ui, data)
        ui.root:setScale(0.7)

        local unique_id = data['id']
        self:refresh_dragonCard(unique_id)

        -- 드래곤 클릭 콜백 함수
        local function click_dragon_item()
            local t_dragon_data = data
            self:click_dragonCard(t_dragon_data)
        end

        ui.vars['clickBtn']:registerScriptTapHandler(function() click_dragon_item() end)
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size(110, 110)
    table_view_td.m_nItemPerCell = 4
    table_view_td:setCellUIClass(UI_DragonCard, create_func)

    -- 리스트 설정
    local l_dragon_list = g_dragonsData:getDragonsList()
    table_view_td:setItemList(l_dragon_list)

    self.m_tableViewExt = table_view_td
end

-------------------------------------
-- function click_backBtn
-------------------------------------
function UI_ColosseumReadyScene:click_backBtn()
    if (self.m_bOpenedFormationUI == true) then
        self:setFormationUIVisible(false)
    else
        self:click_exitBtn()
    end
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ColosseumReadyScene:click_exitBtn()
    local function next_func()
        self:close()
    end

    self:checkChangeDeck(next_func)
end

-------------------------------------
-- function click_dragonCard
-------------------------------------
function UI_ColosseumReadyScene:click_dragonCard(t_dragon_data, skip_sort)
    self.m_readySceneDeck:click_dragonCard(t_dragon_data, skip_sort)
end

-------------------------------------
-- function isSettedDragon
-------------------------------------
function UI_ColosseumReadyScene:isSettedDragon(unique_id)
    if (not self.m_lDeckDragonCard) then
        return false
    end

    for i,v in pairs(self.m_lDeckDragonCard) do
        if (v.m_dragonData['id'] == unique_id) then
            return i
        end
    end

    return false
end

-------------------------------------
-- function click_manageBtn
-- @breif 드래곤 관리
-------------------------------------
function UI_ColosseumReadyScene:click_manageBtn()
    local function next_func()
        local ui = UI_DragonManageInfo()
        local function close_cb()
            local function func()
                self:refresh()
                self:init_dragonTableView()
                self.m_readySceneDeck:init_deck()

                do -- 정렬 도우미
                    self.m_dragonSortMgr = DragonSortManagerReady(self.vars, self.m_tableViewExt)

                    local function func(doid)
                        return self.m_readySceneDeck.m_tDeckMap[doid]
                    end

                    self.m_dragonSortMgr:setIsSettedDragonFunc(func)
                    self.m_dragonSortMgr:changeSort()
                end
            end
            self:sceneFadeInAction(func)
        end
        ui:setCloseCB(close_cb)
    end

    -- 덱 저장 후 이동
    self:checkChangeDeck(next_func)
end

-------------------------------------
-- function click_autoBtn
-- @breif
-------------------------------------
function UI_ColosseumReadyScene:click_autoBtn()
    local stage_id = COLOSSEUM_STAGE_ID
    local formation = self.m_readySceneDeck.m_currFormation
    local l_dragon_list = g_dragonsData:getDragonsList()

    local helper = DragonAutoSetHelper(stage_id, formation, l_dragon_list)
    local l_auto_deck = helper:getAutoDeck()
    l_auto_deck = UI_ReadyScene_Deck:convertSimpleDeck(l_auto_deck)

    -- 1. 덱을 비움
    local skip_sort = true
    self.m_readySceneDeck:clear_deck(skip_sort)

    -- 2. 덱을 채움
    for i,t_dragon_data in pairs(l_auto_deck) do
        self.m_readySceneDeck:setFocusDeckSlotEffect(i)
        local skip_sort = true
        self:click_dragonCard(t_dragon_data, skip_sort)
    end

    -- 정렬
    self.m_dragonSortMgr:changeSort()
end

-------------------------------------
-- function click_removeBtn
-- @breif
-------------------------------------
function UI_ColosseumReadyScene:click_removeBtn()
    self.m_readySceneDeck:clear_deck()
end

-------------------------------------
-- function click_startBtn
-- @breif
-------------------------------------
function UI_ColosseumReadyScene:click_startBtn()
    if (self:getDragonCount() <= 0) then
        UIManager:toastNotificationRed('최소 1명 이상은 출전시켜야 합니다.')
        return
    end

    -- 날개 소모
    if (not g_staminasData:checkStageStamina(COLOSSEUM_STAGE_ID)) then
        self:askCashPlay()
        return
    end
        
    local function next_func()
        local is_cash = false
        self:networkGameStart(is_cash)
    end

    self:checkChangeDeck(next_func)
end

-------------------------------------
-- function askCashPlay
-- @breif
-------------------------------------
function UI_ColosseumReadyScene:askCashPlay()
    local function ok_btn_cb()
        local function next_func()
            local is_cash = true
            self:networkGameStart(is_cash)
        end

        self:checkChangeDeck(next_func)
    end

    local msg = Str('입장권이 부족합니다.\n{@impossible}다이아몬드 1개{@default}를 사용해 진행하시겠습니까?')
    UI_ConfirmPopup('cash', 1, msg, ok_btn_cb)
end

-------------------------------------
-- function click_fomationBtn
-- @breif
-------------------------------------
function UI_ColosseumReadyScene:click_fomationBtn()
    --UIManager:toastNotificationRed('"진형 선택"은 준비 중입니다.')
    self:toggleFormationUI()
end

-------------------------------------
-- function click_fomationSetColseBtn
-- @breif
-------------------------------------
function UI_ColosseumReadyScene:click_fomationSetColseBtn()
    self:setFormationUIVisible(false)
end

-------------------------------------
-- function click_tamerBtn
-- @breif
-------------------------------------
function UI_ColosseumReadyScene:click_tamerBtn()
    local ui = UI_TamerInfoPopup()
	ui:setCloseCB(function() self:refresh_tamer() end)
end

-------------------------------------
-- function networkGameStart
-- @breif
-------------------------------------
function UI_ColosseumReadyScene:networkGameStart(is_cash)
	local function cb(ret)
        local scene = SceneGameColosseum()
        scene:runScene()
    end

    g_colosseumData:request_colosseumStart(is_cash, cb)
end

-------------------------------------
-- function refresh_dragonCard
-- @brief 장착여부에 따른 카드 갱신
-------------------------------------
function UI_ColosseumReadyScene:refresh_dragonCard(doid)
    if (not self.m_readySceneDeck) then
        return
    end

    self.m_readySceneDeck:refresh_dragonCard(doid)
end

-------------------------------------
-- function checkChangeDeck
-------------------------------------
function UI_ColosseumReadyScene:checkChangeDeck(next_func)
    return self.m_readySceneDeck:checkChangeDeck(next_func)
end

-------------------------------------
-- function getDragonCount
-------------------------------------
function UI_ColosseumReadyScene:getDragonCount()
    return self.m_readySceneDeck:getDragonCount()
end

-------------------------------------
-- function getStageStaminaInfo
-- @brief stage_id에 해당하는 필요 스태미너 타입, 갯수 리턴
-------------------------------------
function UI_ColosseumReadyScene:getStageStaminaInfo()
    local cost_type = 'pvp'
    local cost_value = 1

    return cost_type, cost_value
end

-------------------------------------
-- function close
-------------------------------------
function UI_ColosseumReadyScene:close()
    UI.close(self)
end

-------------------------------------
-- function getFormationUIPos
-------------------------------------
function UI_ColosseumReadyScene:getFormationUIPos()
    local pos_x = -4
    local pos_y = -30
    return pos_x, pos_y
end

-------------------------------------
-- function initFormationUI
-- @breif 포메이션 설정 UI를 화면 오른쪽으로 이동, visible off
-------------------------------------
function UI_ColosseumReadyScene:initFormationUI()
    self.m_bOpenedFormationUI = false
    local pos_x, pos_y = self:getFormationUIPos()
    local node = self.vars['fomationSetmenu']
    local visibleSize = node:getContentSize()
    node:setPositionX(pos_x - visibleSize['width'])
    node:setVisible(false)
end

-------------------------------------
-- function toggleFormationUI
-------------------------------------
function UI_ColosseumReadyScene:toggleFormationUI()
    self:setFormationUIVisible(not self.m_bOpenedFormationUI)
end

-------------------------------------
-- function setFormationUIVisible
-------------------------------------
function UI_ColosseumReadyScene:setFormationUIVisible(visible)
    if (self.m_bOpenedFormationUI == visible) then
        return
    end

    self.m_bOpenedFormationUI = visible

    local node = self.vars['fomationSetmenu']
    local action_tag = 100

    local pos_x, pos_y = self:getFormationUIPos()

    if self.m_bOpenedFormationUI then
        node:setVisible(true)
        local action = cc.EaseInOut:create(cc.MoveTo:create(0.3, cc.p(pos_x, pos_y)), 2)
        cca.runAction(node, action, action_tag)
    else
        local visibleSize = node:getContentSize()
        local action = cc.EaseInOut:create(cc.MoveTo:create(0.3, cc.p(pos_x - visibleSize['width'], pos_y)), 2)
        action = cc.Sequence:create(action, cc.Hide:create())
        cca.runAction(node, action, action_tag)
    end
end

--@CHECK
UI:checkCompileError(UI_ColosseumReadyScene)
