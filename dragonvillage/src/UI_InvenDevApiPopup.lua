local PARENT = UI

-------------------------------------
-- class UI_InvenDevApiPopup
-------------------------------------
UI_InvenDevApiPopup = class(PARENT, {
        m_lTabNameList = 'list',
        m_currTabName = 'string',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_InvenDevApiPopup:init()
    local vars = self:load('inven_dev_api_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_InvenDevApiPopup')

    self.m_lTabNameList = {'dragon', 'evolutionStone', 'fruit'}

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_InvenDevApiPopup:initUI()
    local vars = self.vars

    self:init_dragonTableView()
    self:init_fruitTableView()
    self:init_evolutionStoneTableView()

    self:click_tabBtn('dragon')
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_InvenDevApiPopup:initButton()
    local vars = self.vars

    for _,tab_name in ipairs(self.m_lTabNameList) do
        vars[tab_name .. 'Tab']:registerScriptTapHandler(function() self:click_tabBtn(tab_name) end)
    end

    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function click_tabBtn
-------------------------------------
function UI_InvenDevApiPopup:click_tabBtn(tab_name)
    local vars = self.vars
    self.m_currTabName = tab_name

    for i,v in ipairs(self.m_lTabNameList) do
        local lua_name = v .. 'ListNode'
        vars[lua_name]:setVisible(tab_name == v)
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
    local list_table_node = self.vars['dragonListNode']
    list_table_node:removeAllChildren()

    local item_size = 150
    local item_scale = 1
    local item_adjust_size = (item_size * item_scale)

    -- 생성
    local function create_func(item)
        local ui = item['ui']
        ui.root:setScale(item_scale)


        local label = cc.Label:createWithTTF(item['data']['t_name'], 'res/font/common_font_01.ttf', 22, 1, cc.size(600, 50), 1, 1)
        label:setDockPoint(cc.p(0.5, 0.5))
        label:setAnchorPoint(cc.p(0.5, 0.5))
        label:setPositionY(-50)
        ui.root:addChild(label)
    end

    -- 드래곤 클릭 콜백 함수
    local function click_dragon_item(item)
        local data = item['data']
        local did = data['did']

        self:network_addDragon(did)
    end

    local table_dragon = TABLE:get('dragon')
    local t_invalid_dragon = {}
    for i,v in pairs(table_dragon) do
        if (v['test'] == 1) then
            local copy_table = clone(v)
            copy_table['lv'] = 1
            copy_table['grade'] = 1
            copy_table['evolution'] = 1
            table.insert(t_invalid_dragon, copy_table)
        end
    end

    -- 테이블뷰 초기화
    local table_view_ext = TableViewExtension(list_table_node, TableViewExtension.VERTICAL)
    do -- 아이콘 크기 지정
        local item_adjust_size = (item_size * item_scale)
        local nItemPerCell = 5
        local cell_width = (item_adjust_size * nItemPerCell)
        local cell_height = item_adjust_size
        local item_width = item_adjust_size
        local item_height = item_adjust_size
        table_view_ext:setCellInfo2(nItemPerCell, cell_width, cell_height, item_width, item_height)
    end 
    table_view_ext:setItemUIClass(UI_DragonCard, click_dragon_item, create_func) -- init함수에서 해당 아이템의 정보 테이블을 전달, vars['clickBtn']에 클릭 콜백함수 등록
    table_view_ext:setItemInfo(t_invalid_dragon)
    --table_view_ext:update()

    do-- 정렬
        local function default_sort_func(a, b)
            local a = a['data']
            local b = b['data']

            return a['did'] < b['did']
        end
        table_view_ext:insertSortInfo('default', default_sort_func)
        table_view_ext:sortTableView('default')
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
    local list_table_node = self.vars['fruitListNode']
    list_table_node:removeAllChildren()

    local table_fruit = TABLE:get('fruit')

    local item_size = 150
    local item_scale = 1
    local item_adjust_size = (item_size * item_scale)

    -- 생성
    local function create_func(item)
        local fruit_id = item['data']
        local ui = item['ui']
        ui.root:setScale(item_scale)

        ui.vars['numberLabel']:setVisible(true)
        local count = g_userData:getFruitCount(fruit_id)
        ui.vars['numberLabel']:setString(comma_value(count))

        local label = cc.Label:createWithTTF(table_fruit[fruit_id]['t_name'], 'res/font/common_font_01.ttf', 20, 1, cc.size(600, 50), 1, 1)
        label:setDockPoint(cc.p(0.5, 0.5))
        label:setAnchorPoint(cc.p(0.5, 0.5))
        label:setPositionY(50)
        ui.root:addChild(label)
    end

    -- 드래곤 클릭 콜백 함수
    local function click_item(item)
        local data = item['data']
        local fid = data

        self:network_addFruit(fid, item)
    end

    local t_fruit = {}
    for i,v in pairs(table_fruit) do
        table.insert(t_fruit, i)
    end

    -- 테이블뷰 초기화
    local table_view_ext = TableViewExtension(list_table_node, TableViewExtension.VERTICAL)
    do -- 아이콘 크기 지정
        local item_adjust_size = (item_size * item_scale)
        local nItemPerCell = 4
        local cell_width = (item_adjust_size * nItemPerCell)
        local cell_height = item_adjust_size
        local item_width = item_adjust_size
        local item_height = item_adjust_size
        table_view_ext:setCellInfo2(nItemPerCell, cell_width, cell_height, item_width, item_height)
    end 
    table_view_ext:setItemUIClass(UI_ItemCard, click_item, create_func) -- init함수에서 해당 아이템의 정보 테이블을 전달, vars['clickBtn']에 클릭 콜백함수 등록
    table_view_ext:setItemInfo(t_fruit)
    --table_view_ext:update()

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
        table_view_ext:insertSortInfo('default', default_sort_func)
        table_view_ext:sortTableView('default')
    end
end

-------------------------------------
-- function network_addFruit
-- @brief 열매 추가
-------------------------------------
function UI_InvenDevApiPopup:network_addFruit(fid, item)
    local uid = g_userData:get('uid')
    local table_fruit = TABLE:get('fruit')

    local function success_cb(ret)
        if ret['user'] then
            g_serverData:applyServerData(ret['user'], 'user')
        end

        do -- UI 갱신
            local fruit_id = item['data']
            local ui = item['ui']

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
    local list_table_node = self.vars['evolutionStoneListNode']
    list_table_node:removeAllChildren()

    local table_evolution_item = TABLE:get('evolution_item')

    local item_size = 150
    local item_scale = 1
    local item_adjust_size = (item_size * item_scale)

    -- 생성
    local function create_func(item)
        local esid = item['data']
        local ui = item['ui']
        ui.root:setScale(item_scale)

        ui.vars['numberLabel']:setVisible(true)
        local count = g_userData:getEvolutionStoneCount(esid)
        ui.vars['numberLabel']:setString(comma_value(count))

        local label = cc.Label:createWithTTF(table_evolution_item[esid]['t_name'], 'res/font/common_font_01.ttf', 20, 1, cc.size(600, 50), 1, 1)
        label:setDockPoint(cc.p(0.5, 0.5))
        label:setAnchorPoint(cc.p(0.5, 0.5))
        label:setPositionY(50)
        ui.root:addChild(label)
    end

    -- 드래곤 클릭 콜백 함수
    local function click_item(item)
        local data = item['data']
        local esid = data

        self:network_addEvolutionStone(esid, item)
    end

    local l_evolution_stone = {}
    for i,v in pairs(table_evolution_item) do
        table.insert(l_evolution_stone, i)
    end

    -- 테이블뷰 초기화
    local table_view_ext = TableViewExtension(list_table_node, TableViewExtension.VERTICAL)
    do -- 아이콘 크기 지정
        local item_adjust_size = (item_size * item_scale)
        local nItemPerCell = 6
        local cell_width = (item_adjust_size * nItemPerCell)
        local cell_height = item_adjust_size
        local item_width = item_adjust_size
        local item_height = item_adjust_size
        table_view_ext:setCellInfo2(nItemPerCell, cell_width, cell_height, item_width, item_height)
    end 
    table_view_ext:setItemUIClass(UI_ItemCard, click_item, create_func) -- init함수에서 해당 아이템의 정보 테이블을 전달, vars['clickBtn']에 클릭 콜백함수 등록
    table_view_ext:setItemInfo(l_evolution_stone)
    --table_view_ext:update()

    do-- 정렬
        local function default_sort_func(a, b)
            local a = a['data']
            local b = b['data']

            return a < b
        end
        table_view_ext:insertSortInfo('default', default_sort_func)
        table_view_ext:sortTableView('default')
    end
end

-------------------------------------
-- function network_addEvolutionStone
-- @brief 진화재료 추가
-------------------------------------
function UI_InvenDevApiPopup:network_addEvolutionStone(esid, item)
    local uid = g_userData:get('uid')
    local table_evolution_stone = TABLE:get('evolution_item')

    local function success_cb(ret)
        if ret['user'] then
            g_serverData:applyServerData(ret['user'], 'user')
        end

        do -- UI 갱신
            local esid = item['data']
            local ui = item['ui']

            local count = g_userData:getEvolutionStoneCount(esid)
            ui.vars['numberLabel']:setString(comma_value(count))
        end

        UIManager:toastNotificationRed('"' .. table_evolution_stone[esid]['t_name'] .. '" 10개가 추가되었습니다.')
    end

    local ui_network = UI_Network()
    ui_network:setRevocable(true)
    ui_network:setUrl('/users/manage')
    ui_network:setParam('uid', uid)
    ui_network:setParam('act', 'increase')
    ui_network:setParam('key', 'evolution_stones')
    ui_network:setParam('value', tostring(esid) .. ',' .. tostring(10))

    local msg = '"' .. table_evolution_stone[esid]['t_name'] .. '" 10개 추가 중...'
    ui_network:setLoadingMsg(msg)
    ui_network:setSuccessCB(success_cb)
    ui_network:request()
end