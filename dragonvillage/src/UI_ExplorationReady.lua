local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_ExplorationReady
-------------------------------------
UI_ExplorationReady = class(PARENT,{
        m_eprID = '',
        m_tableViewTD = '',
        m_selectedHours = 'number',-- 선택된 탐험 시간
        m_selectedDragonList = 'list',
        m_selectedDragonMap = 'map',
        m_currSlotIdx = 'number',
        m_currDragonCnt = 'number',
        m_focusDeckSlotEffect = 'cc.Sprite',
        m_dragonSortManager = 'SortManager_Dragon',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_ExplorationReady:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ExplorationReady'
    self.m_bVisible = true or false
    self.m_titleStr = Str('탐험 준비') or nil
    self.m_bUseExitBtn = true or false -- click_exitBtn()함구 구현이 반드시 필요함
end

-------------------------------------
-- function init
-------------------------------------
function UI_ExplorationReady:init(epr_id)
    self.m_eprID = epr_id
    self.m_selectedDragonList = {}
    self.m_selectedDragonMap = {}
    self.m_currSlotIdx = 1
    self.m_currDragonCnt = 0

    local vars = self:load('exploration_ready.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ExplorationReady')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    -- 정렬 매니저
    self.m_dragonSortManager = SortManager_Dragon()

    self:initUI()
    self:initTab()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_ExplorationReady:initTab()
    local vars = self.vars
    self:addTab(1, vars['timeBtn1'])
    self:addTab(4, vars['timeBtn2'])
    self:addTab(6, vars['timeBtn3'])
    self:addTab(12, vars['timeBtn4'])

    self:setTab(1)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_ExplorationReady:onChangeTab(tab, first)
    local vars = self.vars

    local hours = tab
    local location_info, my_location_info, status = g_explorationData:getExplorationLocationInfo(self.m_eprID)

    -- 탐험 소요 시간 표시
    vars['timeLabel']:setString(Str('{1} 시간', hours))
    cca.uiReactionSlow(vars['timeLabel'])

    -- 획득하는 경험치 표시
    local add_exp = location_info[tostring(hours) .. '_hours_exp']
    vars['expLabel']:setString(comma_value(add_exp))
    cca.uiReactionSlow(vars['expLabel'])

    -- 획득하는 아이템 리스트
    local reward_items_str = location_info[tostring(hours) .. '_hours_items']
    local reward_items_list = g_itemData:parsePackageItemStr(reward_items_str)
    vars['rewardNode']:removeAllChildren()

    local scale = 0.53
    local l_pos = getSortPosList(150 * scale + 3, #reward_items_list)

    for i,v in ipairs(reward_items_list) do
        local ui = UI_ItemCard(v['item_id'], v['count'])
        vars['rewardNode']:addChild(ui.root)
        ui.root:setScale(0)
        ui.root:setPosition(l_pos[i], 0)
        ui.root:runAction(cc.Sequence:create(cc.DelayTime:create((i-1) * 0.025), cc.ScaleTo:create(0.25, scale)))
    end
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ExplorationReady:initUI()
    local vars = self.vars
    self:init_tableView()

    do
        self.m_focusDeckSlotEffect = cc.Sprite:create('res/ui/frame/dragon_select_frame.png')
        self.m_focusDeckSlotEffect:setDockPoint(cc.p(0.5, 0.5))
        self.m_focusDeckSlotEffect:setAnchorPoint(cc.p(0.5, 0.5))
        self.vars['subRoot']:addChild(self.m_focusDeckSlotEffect, 2)

        self.m_focusDeckSlotEffect:setScale(0.6)
        self.m_focusDeckSlotEffect:setVisible(true)
        self.m_focusDeckSlotEffect:setPosition(self.vars['slotNode1']:getPosition())

        self.m_focusDeckSlotEffect:stopAllActions()
        self.m_focusDeckSlotEffect:setOpacity(255)
        self.m_focusDeckSlotEffect:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 0), cc.FadeTo:create(0.5, 255))))
    end
end

-------------------------------------
-- function init_tableView
-------------------------------------
function UI_ExplorationReady:init_tableView()
    local node = self.vars['selectListNode']
    --node:removeAllChildren()

    local l_item_list = g_explorationData:getDragonList()

    -- 생성 콜백
    local item_scale = 0.7
    local function create_func(ui, data)
        ui.root:setScale(item_scale)

        ui:setReadySpriteVisible(false)
        
        -- 다른 지역을 탐험 중인 드래곤인지 여부 체크
        local doid = data['id']
        if g_explorationData:isExplorationUsedDragon(doid) then
            ui:setShadowSpriteVisible(true)
        end

        local doid = data['id']
        ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonBtn(doid) end)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cc.size(150 * item_scale, 150 * item_scale)
    table_view_td.m_nItemPerCell = 5
    table_view_td:setCellUIClass(UI_DragonCard, create_func)
    table_view_td:setItemList(l_item_list)

    -- 리스트가 비었을 때
    table_view_td:makeDefaultEmptyDescLabel(Str('보유한 드래곤이 없습니다.'))

    -- 정렬
    --g_friendData:sortForFriendList(table_view.m_itemList)
    self.m_tableViewTD = table_view_td
    
    self:refresh_sortUI()
end

-------------------------------------
-- function refresh_sortUI
-------------------------------------
function UI_ExplorationReady:refresh_sortUI()
    local vars = self.vars

    local sort_manager = self.m_dragonSortManager

    -- 테이블 뷰 정렬
    local table_view = self.m_tableViewTD
    sort_manager:sortExecution(table_view.m_itemList)
    table_view:setDirtyItemList()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ExplorationReady:initButton()
    local vars = self.vars
    vars['explorationBtn']:registerScriptTapHandler(function() self:click_explorationBtn() end)

    do -- 정렬 관련 버튼들
        vars['sortSelectOrderBtn']:registerScriptTapHandler(function() self:clcik_sortSelectOrderBtn() end)

        vars['sortSelectBtn']:registerScriptTapHandler(function() self:click_sortSelectBtn() end)
        vars['sortSelectHpBtn']:registerScriptTapHandler(function() self:click_sortBtn('hp') end)
        vars['sortSelectDefBtn']:registerScriptTapHandler(function() self:click_sortBtn('def') end)
        vars['sortSelectAtkBtn']:registerScriptTapHandler(function() self:click_sortBtn('atk') end)
        vars['sortSelectAttrBtn']:registerScriptTapHandler(function() self:click_sortBtn('attr') end)
        vars['sortSelectLvBtn']:registerScriptTapHandler(function() self:click_sortBtn('lv') end)
        vars['sortSelectGradeBtn']:registerScriptTapHandler(function() self:click_sortBtn('grade') end)
        vars['sortSelectRarityBtn']:registerScriptTapHandler(function() self:click_sortBtn('rarity') end)
        vars['sortSelectFriendshipBtn']:registerScriptTapHandler(function() self:click_sortBtn('friendship') end)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ExplorationReady:refresh()
    local vars = self.vars
    local location_info, my_location_info, status = g_explorationData:getExplorationLocationInfo(self.m_eprID)

    -- 지역 이름
    vars['locationLabel']:setString(Str(location_info['t_name']))
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ExplorationReady:click_exitBtn()
    self:close()
end

-------------------------------------
-- function click_dragonBtn
-------------------------------------
function UI_ExplorationReady:click_dragonBtn(doid)

    -- 다른 지역을 탐험 중인 드래곤은 사용할 수 없음
    if g_explorationData:isExplorationUsedDragon(doid) then
        UIManager:toastNotificationRed('다른 지역을 탐험 중인 드래곤입니다.')
        return
    end

    local slot_idx = self.m_selectedDragonMap[doid]
    local table_view_td = self.m_tableViewTD

    -- 장착
    if (not slot_idx) then
        
        -- 인원 제한
        if (self.m_currDragonCnt >= 5) then
            UIManager:toastNotificationRed('더 이상 선택할 수 없습니다.')
            return
        end

        local item = table_view_td:getItem(doid)
        local ui = item['ui']
        ui:setReadySpriteVisible(true)

        self.m_selectedDragonList[self.m_currSlotIdx] = doid
        self.m_selectedDragonMap[doid] = self.m_currSlotIdx
        self.m_currDragonCnt = (self.m_currDragonCnt + 1)

        local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
        local ui = UI_DragonCard(t_dragon_data)
        ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonBtn(doid) end)
        ui:setReadySpriteVisible(false)
        self.vars['slotNode' .. self.m_currSlotIdx]:addChild(ui.root)

        -- UI 연출
        cca.uiReactionSlow(ui.root)

    -- 해제
    else
        local item = table_view_td:getItem(doid)
        local ui = item['ui']
        ui:setReadySpriteVisible(false)

        -- UI 연출
        local scale = 0.66
        cca.uiReactionSlow(ui.root, scale, scale, scale*0.9, scale*0.9)

        self.m_selectedDragonMap[doid] = nil
        self.m_selectedDragonList[slot_idx] = nil
        self.m_currDragonCnt = (self.m_currDragonCnt - 1)

        self.vars['slotNode' .. slot_idx]:removeAllChildren()
    end

    -- 다음 slot_idx 지정
    if (5 <= self.m_currDragonCnt) then
        self.m_currSlotIdx = -1

        self.m_focusDeckSlotEffect:setVisible(false)
    else
        for i=1, 5 do
            if (not self.m_selectedDragonList[i]) then
                self.m_currSlotIdx = i
                break
            end
        end

        self.m_focusDeckSlotEffect:setVisible(true)
        self.m_focusDeckSlotEffect:setPosition(self.vars['slotNode' .. self.m_currSlotIdx]:getPosition())

        self.m_focusDeckSlotEffect:stopAllActions()
        self.m_focusDeckSlotEffect:setOpacity(255)
        self.m_focusDeckSlotEffect:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 0), cc.FadeTo:create(0.5, 255))))
    end
    
end

-------------------------------------
-- function click_explorationBtn
-------------------------------------
function UI_ExplorationReady:click_explorationBtn()
    -- 인원 체크
    if (self.m_currDragonCnt < 5) then
        UIManager:toastNotificationRed('탐험에는 5마리의 드래곤이 필요합니다.')
        return
    end
end

-------------------------------------
-- function clcik_sortSelectOrderBtn
-------------------------------------
function UI_ExplorationReady:clcik_sortSelectOrderBtn()
    local sort_manager = self.m_dragonSortManager
    sort_manager:setAllAscending(not sort_manager.m_defaultSortAscending)
    self:refresh_sortUI()
end

-------------------------------------
-- function click_sortSelectBtn
-------------------------------------
function UI_ExplorationReady:click_sortSelectBtn()
    local vars = self.vars
    vars['sortSelectNode']:runAction(cc.ToggleVisibility:create())
end

-------------------------------------
-- function click_sortBtn
-------------------------------------
function UI_ExplorationReady:click_sortBtn(sort_type)
    local sort_manager = self.m_dragonSortManager
    sort_manager:pushSortOrder(sort_type)
    self:refresh_sortUI()
end

--@CHECK
UI:checkCompileError(UI_ExplorationReady)
