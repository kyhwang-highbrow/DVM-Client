local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_DragonSelectPopup
-------------------------------------
UI_DragonSelectPopup = class(PARENT,{
        m_tableView = '',
        m_sortManagerDragon = '',
        m_bOptionChanged = 'boolean',
        m_selectDragonData = 'table',          

        -- sort list
        m_uicSortList = 'UIC_SortList',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_DragonSelectPopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_DragonSelectPopup'
    self.m_bVisible = true 
    self.m_titleStr = nil
    self.m_bUseExitBtn = true
    self.m_bShowInvenBtn = true 
end

-------------------------------------
-- function init
-------------------------------------
function UI_DragonSelectPopup:init()
    -- spine 캐시 정리 확인
    SpineCacheManager:getInstance():purgeSpineCacheData()

    self.m_bOptionChanged = false

    local vars = self:load('dragon_manage_list.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_DragonSelectPopup')

    self:initUI()
    self:initButton()
    self:init_tableView()
    self:init_dragonSortMgr()        
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonSelectPopup:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonSelectPopup:initButton()
    local vars = self.vars
    local active
    -- 종류
    local object_type_list = {'slime'}
    for _, object_type in pairs(object_type_list) do
        active = (not g_settingData:get('open_dragon_select', 'object_type_' .. object_type)) or true
        vars[object_type .. 'Btn'] = UIC_CheckBox(vars[object_type .. 'Btn'].m_node, vars[object_type .. 'Sprite'], active)
        vars[object_type .. 'Btn']:registerScriptTapHandler(function() self:click_checkBox() end)
    end

    -- 등급 
    for idx = 1, 6 do
        active = g_settingData:get('option_dragon_select', 'grade_'..idx) or true
        vars['starBtn'..idx] = UIC_CheckBox(vars['starBtn'..idx].m_node, vars['starSprite'..idx], active)
        vars['starBtn'..idx]:registerScriptTapHandler(function() self:click_checkBox() end)
    end

    -- 속성
    for idx = 1, 5 do
        active = g_settingData:get('option_dragon_select', 'attr_'..idx) or true
        vars['attrBtn'..idx] = UIC_CheckBox(vars['attrBtn'..idx].m_node, vars['attrSprite'..idx], active)
        vars['attrBtn'..idx]:registerScriptTapHandler(function() self:click_checkBox() end)
    end
    -- 희귀도
    for idx = 1, 5 do
        active = g_settingData:get('option_dragon_select', 'rarity_'..idx) or true
        cclog('rarity_'..idx)
        cclog(active)

        vars['rarityBtn'..idx] = UIC_CheckBox(vars['rarityBtn'..idx].m_node, vars['raritySprite'..idx], active)
        vars['rarityBtn'..idx]:registerScriptTapHandler(function() self:click_checkBox() end)
    end

    -- 역할
    for idx = 1, 4 do
        active = g_settingData:get('option_dragon_select', 'type_'..idx) or true
        vars['typeBtn'..idx] = UIC_CheckBox(vars['typeBtn'..idx].m_node, vars['typeSprite'..idx], active)
        vars['typeBtn'..idx]:registerScriptTapHandler(function() self:click_checkBox() end)
    end

end

-------------------------------------
-- function init_tableView
-------------------------------------
function UI_DragonSelectPopup:init_tableView()
    local node = self.vars['listNode']

    -- 리스트 아이템 생성 콜백
    local function make_func(object)
        return UI_DragonCard(object)
    end

    local function create_func(ui, data)
        -- 새로 획득한 드래곤 뱃지
        local is_new_dragon = data:isNewDragon()
        ui:setNewSpriteVisible(is_new_dragon)

        ui.root:setScale(0.66)
        -- 클릭 버튼 설정
        ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragon(data) end)
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cc.size(102, 102)
    table_view_td.m_nItemPerCell = 10
    table_view_td:setCellUIClass(make_func, create_func)
    table_view_td:setCellCreateInterval(0)
	table_view_td:setCellCreateDirecting(CELL_CREATE_DIRECTING['fadein'])
    table_view_td:setCellCreatePerTick(3)
    self.m_tableView = table_view_td

    -- 재료로 사용 가능한 리스트를 얻어옴
    local l_dragon_list = self:getDragonList()
    self.m_tableView:setItemList(l_dragon_list)
end

-------------------------------------
-- function init_dragonSortMgr
-- @brief 정렬 도우미
-------------------------------------
function UI_DragonSelectPopup:init_dragonSortMgr()
    -- 정렬 매니저 생성
    self.m_sortManagerDragon = SortManager_Dragon()

	local sort_mgr = self.m_sortManagerDragon
	local table_view = self.m_tableView

    -- 정렬 UI 생성
    local vars = self.vars
    local uic_sort_list = MakeUICSortList_dragonManage(vars['sortBtn'], vars['sortLabel'], UIC_SORT_LIST_TOP_TO_BOT)
    self.m_uicSortList = uic_sort_list
    
    -- 버튼을 통해 정렬이 변경되었을 경우
    local function sort_change_cb(sort_type)
        sort_mgr:pushSortOrder(sort_type)
        self:apply_dragonSort()
        self:save_dragonSortInfo()
    end
    uic_sort_list:setSortChangeCB(sort_change_cb)

    -- 오름차순/내림차순 버튼
    vars['sortOrderBtn']:registerScriptTapHandler(function()
            local ascending = (not sort_mgr.m_defaultSortAscending)
            sort_mgr:setAllAscending(ascending)
            self:apply_dragonSort()
            self:save_dragonSortInfo()

			local order_spr = vars['sortOrderSprite']
            order_spr:stopAllActions()
            if ascending then
                order_spr:runAction(cc.RotateTo:create(0.15, 180))
            else
                order_spr:runAction(cc.RotateTo:create(0.15, 0))
            end
        end)

    -- 세이브데이터에 있는 정렬 값을 적용
    self:apply_dragonSort_saveData()
end

-------------------------------------
-- function apply_dragonSort
-- @brief 테이블 뷰에 정렬 적용
-------------------------------------
function UI_DragonSelectPopup:apply_dragonSort()
    local list = self.m_tableView.m_itemList
    self.m_sortManagerDragon:sortExecution(list)
    self.m_tableView:setDirtyItemList()
end

-------------------------------------
-- function save_dragonSortInfo
-- @brief 새로운 정렬 설정을 세이브 데이터에 적용
-------------------------------------
function UI_DragonSelectPopup:save_dragonSortInfo()
    g_settingData:lockSaveData()

    -- 정렬 순서 저장
    local sort_order = self.m_sortManagerDragon.m_lSortOrder
    g_settingData:applySettingData(sort_order, 'dragon_sort_select', 'order')

    -- 오름차순, 내림차순 저장
    local ascending = self.m_sortManagerDragon.m_defaultSortAscending
    g_settingData:applySettingData(ascending, 'dragon_sort_select', 'ascending')

    g_settingData:unlockSaveData()
end

-------------------------------------
-- function apply_dragonSort_saveData
-- @brief 세이브데이터에 있는 정렬 순서 적용
-------------------------------------
function UI_DragonSelectPopup:apply_dragonSort_saveData()
    local l_order = g_settingData:get('dragon_sort_select', 'order')
    local ascending = g_settingData:get('dragon_sort_select', 'ascending')

    local sort_type
    for i=#l_order, 1, -1 do
        sort_type = l_order[i]
        self.m_sortManagerDragon:pushSortOrder(sort_type)
    end
    self.m_sortManagerDragon:setAllAscending(ascending)

    self.m_uicSortList:setSelectSortType(sort_type)


    do -- 오름차순, 내림차순 아이콘
        local vars = self.vars
        vars['sortOrderSprite']:stopAllActions()
        if ascending then
            vars['sortOrderSprite']:runAction(cc.RotateTo:create(0.15, 180))
        else
            vars['sortOrderSprite']:runAction(cc.RotateTo:create(0.15, 0))
        end
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonSelectPopup:refresh()
    local l_item_list = self:getDragonList()
    self.m_tableView:mergeItemList(l_item_list)
    self:tableViewSortAndRefresh()
end

-------------------------------------
-- function tableViewSortAndRefresh
-------------------------------------
function UI_DragonSelectPopup:tableViewSortAndRefresh()
    local sort_manager = self.m_sortManagerDragon
    sort_manager:sortExecution(self.m_tableView.m_itemList)
    self.m_tableView:setDirtyItemList()
end

-------------------------------------
-- function getDragonList
-------------------------------------
function UI_DragonSelectPopup:getDragonList()
    local vars = self.vars

    local l_dragon = g_dragonsData:getDragonListWithSlime() 
    local l_ret_list = {}
    -- 종류
    local l_object_type = {}
    --l_object_type['dragon'] = (not vars['dragonBtn']:isChecked())
    l_object_type['dragon'] = true
    l_object_type['slime'] = (not vars['slimeBtn']:isChecked())

    -- 등급
    local l_stars = {}
    l_stars[1] = vars['starBtn1']:isChecked()
    l_stars[2] = vars['starBtn2']:isChecked()
    l_stars[3] = vars['starBtn3']:isChecked()
    l_stars[4] = vars['starBtn4']:isChecked()
    l_stars[5] = vars['starBtn5']:isChecked()
    l_stars[6] = vars['starBtn6']:isChecked()
    -- 속성
    local l_attr = {}
    l_attr['fire'] = vars['attrBtn1']:isChecked()
    l_attr['water'] = vars['attrBtn2']:isChecked()
    l_attr['earth'] = vars['attrBtn3']:isChecked()
    l_attr['light'] = vars['attrBtn4']:isChecked()
    l_attr['dark'] = vars['attrBtn5']:isChecked()
    -- 희귀도
    local l_rarity = {}
    l_rarity['myth'] = vars['rarityBtn5']:isChecked()
    l_rarity['legend'] = vars['rarityBtn4']:isChecked()
    l_rarity['hero'] = vars['rarityBtn3']:isChecked()
    l_rarity['rare'] = vars['rarityBtn2']:isChecked()
    l_rarity['common'] = vars['rarityBtn1']:isChecked()
    -- 역할
    local l_role = {}
    l_role['tanker'] = vars['typeBtn1']:isChecked()
    l_role['dealer'] = vars['typeBtn2']:isChecked()
    l_role['supporter'] = vars['typeBtn3']:isChecked()
    l_role['healer'] = vars['typeBtn4']:isChecked()

    local table_dragon = TableDragon()
    local table_slime = TableSlime()
    for i,v in pairs(l_dragon) do
        local did = v['did']
        local grade = math.min(v['grade'], 6)
        local attr
        local rarity 
        local role 
        local type

        -- 슬라임 추가
        if table_slime:isSlimeID(did) then
            attr = table_slime:getValue(did, 'attr')
            role = table_slime:getValue(did, 'role')
            rarity = table_slime:getValue(did, 'rarity')
            type = table_slime:getValue(did, 'type')
        else
            attr = table_dragon:getValue(did, 'attr')
            role = table_dragon:getValue(did, 'role')
            rarity = table_dragon:getValue(did, 'rarity')
            type = 'dragon'
        end

        if (l_object_type[type] and l_stars[grade] and l_attr[attr] and l_role[role] and l_rarity[rarity]) then
            l_ret_list[i] = v
        end
    end

    return l_ret_list
end

-------------------------------------
-- function click_checkBox
-------------------------------------
function UI_DragonSelectPopup:click_checkBox()
    self.m_bOptionChanged = true
    self:refresh()
end

-------------------------------------
-- function click_dragon
-------------------------------------
function UI_DragonSelectPopup:click_dragon(data)
    self.m_selectDragonData = data
    self:click_exitBtn()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DragonSelectPopup:click_exitBtn()
    if (self.m_closeCB) then
        self.m_closeCB(self.m_selectDragonData)
        self.m_closeCB = nil
    end

    self:close()
end

-------------------------------------
-- function onClose
-------------------------------------
function UI_DragonSelectPopup:onClose()
    if (self.m_bOptionChanged == true) then
        local vars = self.vars

        g_settingData:lockSaveData()
        -- 종류
        local object_type_list = {'slime'}
        for _, object_type in pairs(object_type_list) do
            g_settingData:applySettingData(vars[object_type .. 'Btn']:isChecked(), 'option_dragon_select', 'object_type_'.. object_type)
        end

        -- 등급 
        for idx = 1, 6 do
            g_settingData:applySettingData(vars['starBtn'..idx]:isChecked(), 'option_dragon_select', 'grade_'..idx)
        end
        -- 속성
        for idx = 1, 5 do
            g_settingData:applySettingData(vars['attrBtn'..idx]:isChecked(), 'option_dragon_select', 'attr_'..idx)
        end
        -- 희귀도
        for idx = 1, 5 do
            g_settingData:applySettingData(vars['rarityBtn'..idx]:isChecked(), 'option_dragon_select', 'rarity_'..idx)
        end

        -- 역할
        for idx = 1, 4 do
            g_settingData:applySettingData(vars['typeBtn'..idx]:isChecked(), 'option_dragon_select', 'type_'..idx)
        end


        g_settingData:unlockSaveData()
        self.m_bOptionChanged = false
    end

    PARENT.onClose(self)
end

--@CHECK
UI:checkCompileError(UI_DragonSelectPopup)