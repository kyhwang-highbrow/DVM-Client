local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_InvenDevApiPopup
-------------------------------------
UI_InvenDevApiPopup = class(PARENT, {
        m_lTabNameList = 'list',
        m_lInitData = 'list',
        m_currTabName = 'string',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_InvenDevApiPopup:init()
    local vars = self:load('inven_dev_api_popup.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_InvenDevApiPopup')

    self.m_lTabNameList = {'dragon', 'evolutionStone', 'fruit', 'rune', 'egg'}
    self.m_lInitData = {}

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_InvenDevApiPopup:initUI()
    local vars = self.vars
    self:initTab()
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_InvenDevApiPopup:initTab()
    local vars = self.vars
    for _,tab_name in ipairs(self.m_lTabNameList) do
        self:addTabAuto(tab_name, vars, vars[tab_name .. 'ListNode'])
    end
    self:setTab(self.m_lTabNameList[1])
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_InvenDevApiPopup:initButton()
    local vars = self.vars

    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_InvenDevApiPopup:onChangeTab(tab, first)
    PARENT.onChangeTab(self, tab, first)
    if (first) then
        if (tab == 'dragon') then
            self:init_dragonTableView()
        elseif (tab == 'fruit') then
            self:init_fruitTableView()
        elseif (tab == 'evolutionStone') then
            self:init_evolutionStoneTableView()
        elseif (tab == 'rune') then
            self:init_runeTableView()
        elseif (tab == 'egg') then
            self:init_eggTableView()
        end
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_InvenDevApiPopup:refresh()
    local vars = self.vars
end

-------------------------------------
-- function init_dragonTableView
-- @brief 드래곤 테이블 리스트
-------------------------------------
function UI_InvenDevApiPopup:init_dragonTableView()
    if self.m_lInitData['dragon'] then
        return
    end
    self.m_lInitData['dragon'] = true

    local list_table_node = self.vars['dragonListNode']
    list_table_node:removeAllChildren()

    local item_size = 150
    local item_scale = 0.8
    local item_adjust_size = (item_size * item_scale)

    -- 생성
    local function create_func(ui, data)
        ui.root:setScale(item_scale)

        local did = data['did']
        local name = TableDragon:getDragonName(did)
        local label = cc.Label:createWithTTF(name, 'res/font/common_font_01.ttf', 22, 1, cc.size(600, 50), 1, 1)
        label:setDockPoint(cc.p(0.5, 0.5))
        label:setAnchorPoint(cc.p(0.5, 0.5))
        label:setPositionY(-50)
        ui.root:addChild(label)

        ui.vars['clickBtn']:registerScriptTapHandler(function() self:network_addDragon(did) end)
    end

    local table_dragon = TABLE:get('dragon')
    local t_invalid_dragon = {}
    for i,v in pairs(table_dragon) do
        t_invalid_dragon[v['did']] = v
    end


    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view_td.m_cellSize = cc.size(item_adjust_size, item_adjust_size)
    table_view_td.m_nItemPerCell = 10
    table_view_td:setCellUIClass(function(data)
        local did = data['did']
        return MakeSimpleDragonCard(did)
    end, create_func)
    table_view_td:setItemList(t_invalid_dragon)

    do-- 정렬
        local sort_manager = SortManager_Dragon()
        sort_manager.m_mAttrSortLevel['earth'] = 1
        sort_manager.m_mAttrSortLevel['water'] = 2
        sort_manager.m_mAttrSortLevel['fire'] = 3
        sort_manager.m_mAttrSortLevel['dark'] = 4
        sort_manager.m_mAttrSortLevel['light'] = 5

        sort_manager:addSortType('name', false, function(a, b, ascending)
            local a_data = a['data']
            local b_data = b['data']

            local a_value = a_data['t_name']
            local b_value = b_data['t_name']

            -- 같을 경우 리턴
            if (a_value == b_value) then return nil end

            -- 오름차순 or 내림차순
            if ascending then return a_value < b_value
            else              return a_value > b_value
            end
        end)
	
	    -- 등급 순, 이름순, 속성 순으로 정렬
        sort_manager:pushSortOrder('attr', true)
        sort_manager:pushSortOrder('name', true)
        sort_manager:pushSortOrder('rarity')

        sort_manager:sortExecution(table_view_td.m_itemList)

        table_view_td:setDirtyItemList()
    end
end

-------------------------------------
-- function network_addDragon
-- @brief 드래곤 추가
-------------------------------------
function UI_InvenDevApiPopup:network_addDragon(did)
    local uid = g_userData:get('uid')
    local table_dragon = TABLE:get('dragon')

    local function success_cb(ret)
        if (ret and ret['dragons']) then
            for _,t_dragon in pairs(ret['dragons']) do
                g_dragonsData:applyDragonData(t_dragon)
                UIManager:toastNotificationRed('"' .. table_dragon[did]['t_name'] .. '"드래곤이 추가되었습니다.')
            end
        end
    end

    local ui_network = UI_Network()
    ui_network:setRevocable(true)
    ui_network:setUrl('/dragons/add')
    ui_network:setParam('uid', uid)
    ui_network:setParam('did', did)
    ui_network:setParam('evolution', 1)
    local msg = '"' .. table_dragon[did]['t_name'] .. '"드래곤 추가 중...'
    ui_network:setLoadingMsg(msg)
    ui_network:setSuccessCB(success_cb)
    ui_network:request()
end

-------------------------------------
-- function init_fruitTableView
-- @brief 열매 테이블 리스트
-------------------------------------
function UI_InvenDevApiPopup:init_fruitTableView()
    if self.m_lInitData['fruit'] then
        return
    end
    self.m_lInitData['fruit'] = true

    local list_table_node = self.vars['fruitListNode']
    list_table_node:removeAllChildren()

    local table_fruit = TABLE:get('fruit')

    local item_size = 150
    local item_scale = 1
    local item_adjust_size = (item_size * item_scale)

    -- 생성
    local function create_func(ui, data)
        local fruit_id = data
        ui.root:setScale(item_scale)

        ui.vars['numberLabel']:setVisible(true)
        local count = g_userData:getFruitCount(fruit_id)
        ui.vars['numberLabel']:setString(comma_value(count))

        local label = cc.Label:createWithTTF(table_fruit[fruit_id]['t_name'], 'res/font/common_font_01.ttf', 20, 1, cc.size(600, 50), 1, 1)
        label:setDockPoint(cc.p(0.5, 0.5))
        label:setAnchorPoint(cc.p(0.5, 0.5))
        label:setPositionY(50)
        ui.root:addChild(label)

        ui.vars['clickBtn']:registerScriptTapHandler(function() self:network_addFruit(ui, fruit_id) end)
    end

    local t_fruit = {}
    for i,v in pairs(table_fruit) do
        table.insert(t_fruit, i)
    end

    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view_td.m_cellSize = cc.size(item_adjust_size, item_adjust_size)
    table_view_td.m_nItemPerCell = 4
    table_view_td:setCellUIClass(UI_ItemCard, create_func)
    table_view_td:setItemList(t_fruit)

    do-- 정렬
        local function default_sort_func(a, b)
            local a = a['data']
            local b = b['data']

            if (table_fruit[a]['attr'] < table_fruit[b]['attr']) then
                return true
            end

            if (table_fruit[a]['attr'] > table_fruit[b]['attr']) then
                return false
            end

            return a < b
        end
        table.sort(table_view_td.m_itemList, default_sort_func)
    end
end

-------------------------------------
-- function network_addFruit
-- @brief 열매 추가
-------------------------------------
function UI_InvenDevApiPopup:network_addFruit(ui, fid)
    local uid = g_userData:get('uid')
    local table_fruit = TABLE:get('fruit')

    local function success_cb(ret)
        if ret['user'] then
            g_serverData:applyServerData(ret['user'], 'user')
        end

        do -- UI 갱신
            local count = g_userData:getFruitCount(fid)
            ui.vars['numberLabel']:setString(comma_value(count))
        end

        UIManager:toastNotificationRed('"' .. table_fruit[fid]['t_name'] .. '" 10개가 추가되었습니다.')
    end

    local ui_network = UI_Network()
    ui_network:setRevocable(true)
    ui_network:setUrl('/users/manage')
    ui_network:setParam('uid', uid)
    ui_network:setParam('act', 'increase')
    ui_network:setParam('key', 'fruits')
    ui_network:setParam('value', tostring(fid) .. ',' .. tostring(10))

    local msg = '"' .. table_fruit[fid]['t_name'] .. '" 10개 추가 중...'
    ui_network:setLoadingMsg(msg)
    ui_network:setSuccessCB(success_cb)
    ui_network:request()
end

-------------------------------------
-- function init_evolutionStoneTableView
-- @brief 진화 재료 리스트
-------------------------------------
function UI_InvenDevApiPopup:init_evolutionStoneTableView()
    if self.m_lInitData['evolutionStone'] then
        return
    end
    self.m_lInitData['evolutionStone'] = true

    local list_table_node = self.vars['evolutionStoneListNode']
    list_table_node:removeAllChildren()

    local table_item = TableItem()
    local l_evolution_stone = table_item:filterTable('type', 'evolution_stone')

    local item_size = 150
    local item_scale = 1
    local item_adjust_size = (item_size * item_scale)

    -- 생성
    local function create_func(ui, data)
        local esid = data
        ui.root:setScale(item_scale)

        ui.vars['numberLabel']:setVisible(true)
        local count = g_userData:getEvolutionStoneCount(esid)
        ui.vars['numberLabel']:setString(comma_value(count))

        local name = table_item:getValue(esid, 't_name')
        local label = cc.Label:createWithTTF(name, 'res/font/common_font_01.ttf', 20, 1, cc.size(600, 50), 1, 1)
        label:setDockPoint(cc.p(0.5, 0.5))
        label:setAnchorPoint(cc.p(0.5, 0.5))
        label:setPositionY(50)
        ui.root:addChild(label)

        ui.vars['clickBtn']:registerScriptTapHandler(function() self:network_addEvolutionStone(ui, esid) end)
    end

    local l_item_list = {}
    for item_id,_ in pairs(l_evolution_stone) do
        table.insert(l_item_list, item_id)
    end

    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view_td.m_cellSize = cc.size(item_adjust_size, item_adjust_size)
    table_view_td.m_nItemPerCell = 6
    table_view_td:setCellUIClass(UI_ItemCard, create_func)
    table_view_td:setItemList(l_item_list)

    do-- 정렬
        local function default_sort_func(a, b)
            local a = a['data']
            local b = b['data']

            return a < b
        end
        table.sort(table_view_td.m_itemList, default_sort_func)
    end
end

-------------------------------------
-- function network_addEvolutionStone
-- @brief 진화재료 추가
-------------------------------------
function UI_InvenDevApiPopup:network_addEvolutionStone(ui, esid)
    local uid = g_userData:get('uid')
    local table_item = TableItem()

    local function success_cb(ret)
        if ret['user'] then
            g_serverData:applyServerData(ret['user'], 'user')
        end

        do -- UI 갱신
            local count = g_userData:getEvolutionStoneCount(esid)
            ui.vars['numberLabel']:setString(comma_value(count))
        end

        local name = table_item:getValue(esid, 't_name')
        UIManager:toastNotificationRed('"' .. name .. '" 10개가 추가되었습니다.')
    end

    local ui_network = UI_Network()
    ui_network:setRevocable(true)
    ui_network:setUrl('/users/manage')
    ui_network:setParam('uid', uid)
    ui_network:setParam('act', 'increase')
    ui_network:setParam('key', 'evolution_stones')
    ui_network:setParam('value', tostring(esid) .. ',' .. tostring(10))

    local name = table_item:getValue(esid, 't_name')
    local msg = '"' .. name .. '" 10개 추가 중...'
    ui_network:setLoadingMsg(msg)
    ui_network:setSuccessCB(success_cb)
    ui_network:request()
end

-------------------------------------
-- function init_runeTableView
-- @brief 룬 리스트
-------------------------------------
function UI_InvenDevApiPopup:init_runeTableView()
    if self.m_lInitData['rune'] then
        return
    end
    self.m_lInitData['rune'] = true

    local list_table_node = self.vars['runeListNode']
    list_table_node:removeAllChildren()

    local l_rune_list = TableItem:getRuneItemIDListForDev()

    -- 생성 콜백
    local function create_func(ui, data)
        ui.vars['clickBtn']:registerScriptTapHandler(function()
            local rune_id = data['rid']
            self:network_addRune(rune_id)
        end)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size(150, 150)
    table_view_td.m_nItemPerCell = 6
    table_view_td:setCellUIClass(function(data)
        local rid = data['rid']
        return UI_ItemCard(rid)
    end, create_func)
    table_view_td:setItemList(l_rune_list)

    do-- 정렬
        local sort_manager = SortManager_Rune()
        
	    -- 등급 순, 세트 순, 번호 순으로 정렬
        sort_manager:pushSortOrder('slot', true)
        sort_manager:pushSortOrder('set_id')
        sort_manager:pushSortOrder('grade') 

        sort_manager:sortExecution(table_view_td.m_itemList)

        table_view_td:setDirtyItemList()
    end
end

-------------------------------------
-- function network_addRune
-- @brief 룬 추가
-------------------------------------
function UI_InvenDevApiPopup:network_addRune(rune_id)
    local uid = g_userData:get('uid')

    local function success_cb(ret)
        if ret['runes'] then
            g_runesData:applyRuneData_list(ret['runes'])
        end

        UIManager:toastNotificationRed('룬 1개가 추가되었습니다.')
    end

    local ui_network = UI_Network()
    ui_network:setRevocable(true)
    ui_network:setUrl('/runes/add')
    ui_network:setParam('uid', uid)
    ui_network:setParam('rid', rune_id)

    local msg = '룬 추가 중'
    ui_network:setLoadingMsg(msg)
    ui_network:setSuccessCB(success_cb)
    ui_network:request()
end

-------------------------------------
-- function init_eggTableView
-- @brief 알 테이블 리스트
-------------------------------------
function UI_InvenDevApiPopup:init_eggTableView()
    if self.m_lInitData['egg'] then
        return
    end
    self.m_lInitData['egg'] = true

    local list_table_node = self.vars['eggListNode']
    list_table_node:removeAllChildren()

    local table_item = TableItem()
    local l_egg_list = table_item:filterList('type', 'egg')
    local l_item_list = {}
    for i,v in ipairs(l_egg_list) do
        local egg_id = v['item']
        table.insert(l_item_list, egg_id)
    end
    table.sort(l_item_list, function(a, b)
            return a < b
        end)

    -- 생성 콜백
    local function create_func(ui, data)
        local egg_id = data

        ui.vars['clickBtn']:registerScriptTapHandler(function()
            self:request_addEgg(egg_id, ui)
        end)

        ui.vars['numberLabel']:setVisible(true)
        local count = g_eggsData:getEggCount(egg_id)
        ui.vars['numberLabel']:setString(comma_value(count))

        local name = table_item:getValue(egg_id, 't_name')
        local label = cc.Label:createWithTTF(name, 'res/font/common_font_01.ttf', 20, 1, cc.size(600, 50), 1, 1)
        label:setDockPoint(cc.p(0.5, 0.5))
        label:setAnchorPoint(cc.p(0.5, 0.5))
        label:setPositionY(50)
        ui.root:addChild(label)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size(150, 150)
    table_view_td.m_nItemPerCell = 5
    table_view_td:setCellUIClass(UI_ItemCard, create_func)
    table_view_td:setItemList(l_item_list)
end

-------------------------------------
-- function request_addEgg
-- @brief 알 추가
-------------------------------------
function UI_InvenDevApiPopup:request_addEgg(egg_id, ui)
    local uid = g_userData:get('uid')

    local table_item = TableItem()
    local name = table_item:getValue(egg_id, 't_name')

    local function success_cb(ret)
        if ret['user'] then
            g_serverData:applyServerData(ret['user'], 'user')
        end

        if ui then-- UI 갱신
            local count = g_eggsData:getEggCount(egg_id)
            ui.vars['numberLabel']:setString(comma_value(count))
        end

        UIManager:toastNotificationRed('"' .. name .. '" 1개가 추가되었습니다.')
    end

    local ui_network = UI_Network()
    ui_network:setRevocable(true)
    ui_network:setUrl('/users/manage')
    ui_network:setParam('uid', uid)
    ui_network:setParam('act', 'increase')
    ui_network:setParam('key', 'eggs')
    ui_network:setParam('value', tostring(egg_id) .. ',' .. tostring(1))

    local msg = '"' .. name .. '" 1개 추가 중...'
    ui_network:setLoadingMsg(msg)
    ui_network:setSuccessCB(success_cb)
    ui_network:request()
end