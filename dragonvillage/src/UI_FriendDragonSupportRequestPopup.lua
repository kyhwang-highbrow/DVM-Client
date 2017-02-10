local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_FriendDragonSupportRequestPopup
-------------------------------------
UI_FriendDragonSupportRequestPopup = class(PARENT, {
        m_dragonSortManager = 'SortManager_Dragon',
        m_mTableView = 'map', -- 희귀도별 테이블 뷰
        m_selectedDragonItem = '',
        m_bRequestedSupportDragon = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_FriendDragonSupportRequestPopup:init()
	local vars = self:load('friend_support_request_popup.ui')
	UIManager:open(self, UIManager.POPUP)

    -- 정렬 매니저
    self.m_dragonSortManager = SortManager_Dragon()
    self.m_dragonSortManager:setAllAscending(false) -- 내림차순

    -- 희귀도별 테이블 뷰
    self.m_mTableView = {}

    self.m_bRequestedSupportDragon = false

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_FriendDragonSupportRequestPopup')

	-- @UI_ACTION
	--self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
	self:doActionReset()
	self:doAction(nil, false)

	self:initUI()
	self:initButton()
	self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_FriendDragonSupportRequestPopup:initUI()
    self:initTab()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_FriendDragonSupportRequestPopup:initButton()
    local vars = self.vars
    vars['cancelBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
    vars['supportRequestBtn']:registerScriptTapHandler(function() self:clcik_supportRequestBtn() end)
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

-------------------------------------
-- function refresh
-------------------------------------
function UI_FriendDragonSupportRequestPopup:refresh()
    local vars = self.vars

    -- 드래곤 희귀도별 지원 가능 여부 텍스트 출력
    vars['commonTimeLabel']:setString(g_friendData:getDragonSupportRequestCooltimeText('common'))
    vars['rareTimeLabel']:setString(g_friendData:getDragonSupportRequestCooltimeText('rare'))
    vars['heroTimeLabel']:setString(g_friendData:getDragonSupportRequestCooltimeText('hero'))
    vars['legendTimeLabel']:setString(g_friendData:getDragonSupportRequestCooltimeText('legend'))

    self:refresh_sortUI()
end

-------------------------------------
-- function refresh_sortUI
-------------------------------------
function UI_FriendDragonSupportRequestPopup:refresh_sortUI()
    local vars = self.vars

    local sort_manager = self.m_dragonSortManager

    -- 오름차순일경우
    if sort_manager.m_defaultSortAscending then
        vars['sortSelectOrderSprite']:setScaleY(-1)
    -- 내림차순일경우
    else
        vars['sortSelectOrderSprite']:setScaleY(1)
    end

    -- 정렬 카테고리
    vars['sortSelectLabel']:setString(sort_manager:getTopSortingName())

    for i,v in pairs(self.m_mTableView) do
        sort_manager:sortExecution(v.m_itemList)
        v:setDirtyItemList()
    end
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_FriendDragonSupportRequestPopup:click_exitBtn()
    self:close()
end

-------------------------------------
-- function clcik_supportRequestBtn
-------------------------------------
function UI_FriendDragonSupportRequestPopup:clcik_supportRequestBtn()
    -- 선택했는지 여부
    if (not self.m_selectedDragonItem) then
        UIManager:toastNotificationRed(Str('지원 요청할 드래곤을 선택해주세요.'))
        return
    end

    -- 쿨타임 체크
    local did = self.m_selectedDragonItem['data']['did']
    local dragon_rarity = TableDragon():getValue(did, 'rarity')
    local available, remain_time = g_friendData:availabilityOfDragonSupportRequests(dragon_rarity)
    if (not available) then
        local msg = Str('{1} 드래곤은 {2} 후에 지원요청이 가능합니다.', dragonRarityName(dragon_rarity), datetime.makeTimeDesc(remain_time, true))
        UIManager:toastNotificationRed(msg)
        return
    end

    -- 지원 요청 서버 통신
    local function finish_cb(ret)
        local name = TableDragon():getValue(did, 't_name')
        self.m_bRequestedSupportDragon = true
        UIManager:toastNotificationGreen(Str('{1}드래곤을 지원 요청하였습니다.', Str(name)))
        self:close()
    end
    g_friendData:request_setNeedDragon(did, finish_cb)
end

-------------------------------------
-- function clcik_sortSelectOrderBtn
-------------------------------------
function UI_FriendDragonSupportRequestPopup:clcik_sortSelectOrderBtn()
    local sort_manager = self.m_dragonSortManager
    sort_manager:setAllAscending(not sort_manager.m_defaultSortAscending)
    self:refresh_sortUI()
end

-------------------------------------
-- function click_sortSelectBtn
-------------------------------------
function UI_FriendDragonSupportRequestPopup:click_sortSelectBtn()
    local vars = self.vars
    vars['sortSelectNode']:runAction(cc.ToggleVisibility:create())
end

-------------------------------------
-- function click_sortBtn
-------------------------------------
function UI_FriendDragonSupportRequestPopup:click_sortBtn(sort_type)
    local sort_manager = self.m_dragonSortManager
    sort_manager:pushSortOrder(sort_type)
    self:refresh_sortUI()
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_FriendDragonSupportRequestPopup:initTab()
    local vars = self.vars
    self:addTab('legend', vars['legendBtn'], vars['legendListNode'])
    self:addTab('rare', vars['rareBtn'], vars['rareListNode'])
    self:addTab('hero', vars['heroBtn'], vars['heroListNode'])
    self:addTab('common', vars['commonBtn'], vars['commonListNode'])    

    self:setTab('legend')
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_FriendDragonSupportRequestPopup:onChangeTab(tab, first)
    if first then
        local dragon_rarity = tab
        self:init_dragonTableView(dragon_rarity)
    end
end

-------------------------------------
-- function init_dragonTableView
-------------------------------------
function UI_FriendDragonSupportRequestPopup:init_dragonTableView(dragon_rarity)

    local node = self.vars[dragon_rarity ..'ListNode']
    --node:removeAllChildren()

    local l_item_list = g_dragonsData:getDragonSupportRequstTargetList(dragon_rarity)

    -- 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.72)
        
        local function click_func()
            self:setSelectedDragon(ui, data)
        end

        ui.vars['clickBtn']:registerScriptTapHandler(click_func)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cc.size(108, 108)
    table_view_td.m_nItemPerCell = 7
    table_view_td:setCellUIClass(UI_DragonCard, create_func)
    table_view_td:setItemList(l_item_list)
    table_view_td:makeDefaultEmptyDescLabel(self:getEmptyMessage(dragon_rarity))

    -- 정렬
    local sort_manager = self.m_dragonSortManager
    sort_manager:sortExecution(table_view_td.m_itemList)

    self.m_mTableView[dragon_rarity] = table_view_td
end

-------------------------------------
-- function getTableViewEmptyMessage
-------------------------------------
function UI_FriendDragonSupportRequestPopup:getEmptyMessage(dragon_rarity)
    if (dragon_rarity == 'legend') then
        return Str('레전드 드래곤이 하나도 없네요 ToT')

    elseif (dragon_rarity == 'hero') then
        return Str('영웅 드래곤이 왜 하나도 없을까요??')

    elseif (dragon_rarity == 'rare') then
        return Str('희귀한 드래곤을 수집해보세요.')

    elseif (dragon_rarity == 'common') then
        return Str('일반 드래곤은 키우지 않으십니까?')

    else
        eeror('dragon_rarity : ' .. dragon_rarity)

    end
end

-------------------------------------
-- function setSelectedDragon
-------------------------------------
function UI_FriendDragonSupportRequestPopup:setSelectedDragon(ui, data)
    if self.m_selectedDragonItem then
        self.m_selectedDragonItem['ui']:setShadowSpriteVisible(false)
    end

    if ui and data then
        local item = {}
        item['ui'] = ui
        item['data'] = data
        self.m_selectedDragonItem = item
        self.m_selectedDragonItem['ui']:setShadowSpriteVisible(true)
    end
end

--@CHECK
UI:checkCompileError(UI_FriendDragonSupportRequestPopup)