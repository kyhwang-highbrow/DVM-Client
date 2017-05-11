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
		m_sortManagerDragon = '',
    })

local DC_SCALE = 0.61

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
    self.m_readySceneDeck = UI_ReadyScene_Deck(self)
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
-- function condition_deck_idx
-------------------------------------
function UI_ColosseumReadyScene:condition_deck_idx(a, b)
	for doid, v in pairs(self.m_readySceneDeck.m_tDeckMap) do
	end

    local a_deck_idx = self.m_readySceneDeck.m_tDeckMap[a['data']['id']] or 999
    local b_deck_idx = self.m_readySceneDeck.m_tDeckMap[b['data']['id']]  or 999
	 
    -- 덱에 설정된 데이터로 우선 정렬
    if (a_deck_idx ~= b_deck_idx) then
        return a_deck_idx < b_deck_idx
    end
end

-------------------------------------
-- function init_sortMgr
-------------------------------------
function UI_ColosseumReadyScene:init_sortMgr(stage_id)

	-- 정렬 매니저 생성
    self.m_sortManagerDragon = SortManager_Dragon()

	-- 나중에 정리
	do
		local function cond(a, b)
			return self:condition_deck_idx(a, b)
		end
		self.m_sortManagerDragon:addPreSortType('deck_idx', false, cond)
	end

    -- 정렬 UI 생성
    local vars = self.vars
    local uic_sort_list = MakeUICSortList_dragonManage(vars['sortBtn'], vars['sortLabel'], UIC_SORT_LIST_TOP_TO_BOT)
    --self.m_uicSortList = uic_sort_list
    

	    -- 버튼을 통해 정렬이 변경되었을 경우
    local function sort_change_cb(sort_type)
        self.m_sortManagerDragon:pushSortOrder(sort_type)
        self:apply_dragonSort()
    end
    uic_sort_list:setSortChangeCB(sort_change_cb)

    -- 오름차순/내림차순 버튼
    vars['sortOrderBtn']:registerScriptTapHandler(function()
        local ascending = (not self.m_sortManagerDragon.m_defaultSortAscending)
        self.m_sortManagerDragon:setAllAscending(ascending)
        self:apply_dragonSort()
        --self:save_dragonSortInfo()

        vars['sortOrderSprite']:stopAllActions()
        if ascending then
            vars['sortOrderSprite']:runAction(cc.RotateTo:create(0.15, 180))
        else
            vars['sortOrderSprite']:runAction(cc.RotateTo:create(0.15, 0))
        end
    end)

	-- 최초 정렬
	self:apply_dragonSort()
end

-------------------------------------
-- function apply_dragonSort
-- @brief 테이블 뷰에 정렬 적용
-------------------------------------
function UI_ColosseumReadyScene:apply_dragonSort()
    local list = self.m_tableViewExt.m_itemList
    self.m_sortManagerDragon:sortExecution(list)
    self.m_tableViewExt:setDirtyItemList()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ColosseumReadyScene:initUI()
    self:init_dragonTableView()
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

    -- 도감 무리(스토리) 버프
    vars['teamBuffBtn']:registerScriptTapHandler(function() self:click_teamBuffBtn() end)
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

	local tamer_res = g_tamerData:getCurrTamerTable('res_sd')
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
        ui.root:setScale(DC_SCALE)	-- UI 테이블뷰 사이즈가 변경될 시 조정

        local unique_id = data['id']
        self:refresh_dragonCard(unique_id)

        -- 드래곤 클릭 콜백 함수
        local function click_dragon_item()
            local t_dragon_data = data
            self:click_dragonCard(t_dragon_data)
        end

        ui.vars['clickBtn']:registerScriptTapHandler(function() click_dragon_item() end)

        -- 상성
        local dragon_attr = TableDragon():getValue(data['did'], 'attr')
        local stage_attr = self.m_stageAttr
        ui:setAttrSynastry(getCounterAttribute(dragon_attr, stage_attr))
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size(97, 94)	-- UI 테이블뷰 사이즈가 변경될 시 조정
    table_view_td.m_nItemPerCell = 4			-- UI 테이블뷰 사이즈가 변경될 시 조정
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
    self:click_exitBtn()
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
function UI_ColosseumReadyScene:click_dragonCard(t_dragon_data, skip_sort, idx)
    self.m_readySceneDeck:click_dragonCard(t_dragon_data, skip_sort, idx)
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
					self:apply_dragonSort()
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
        self:click_dragonCard(t_dragon_data, skip_sort, i)
    end

    -- 정렬
    self:apply_dragonSort()
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
	-- m_readySceneDeck에서 현재 formation 받아와 전달
	local curr_formation_type = self.m_readySceneDeck.m_currFormation
    local ui = UI_FormationPopup(curr_formation_type)
	
	-- 종료하면서 선택된 formation을 m_readySceneDeck으로 전달
	local function close_cb(formation_type)
		self.m_readySceneDeck:setFormation(formation_type)
	end
	ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_teamBuffBtn
-- @breif
-------------------------------------
function UI_ColosseumReadyScene:click_teamBuffBtn()
    local function next_func()
        local curr_deck_name = 'pvp'
        UI_CollectionStoryPopup('applyTeam', curr_deck_name)
    end

    self:checkChangeDeck(next_func)
end

-------------------------------------
-- function click_tamerBtn
-- @breif
-------------------------------------
function UI_ColosseumReadyScene:click_tamerBtn()
    local ui = UI_TamerManagePopup()
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

--@CHECK
UI:checkCompileError(UI_ColosseumReadyScene)
