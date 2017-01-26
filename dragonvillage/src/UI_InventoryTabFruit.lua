local PARENT = UI_InventoryTab

-------------------------------------
-- class UI_InventoryTabFruit
-------------------------------------
UI_InventoryTabFruit = class(PARENT, {
        m_fruitsTableView = 'UIC_TableViewTD',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_InventoryTabFruit:init(inventory_ui)
    local vars = self.vars
end

-------------------------------------
-- function init_fruitTableView
-------------------------------------
function UI_InventoryTabFruit:init_fruitTableView()
    if self.m_fruitsTableView then
        return
    end

    local node = self.vars['fruitTableViewNode']
    --node:removeAllChildren()

    local l_item_list = g_userData:getFruitList()

    -- 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.72)
    end

    -- 열매 아이콘 생성 함수(내부에서 Item Card)
    local function FruitCard(t_data)
        local item_id = t_data['fid']
        local count = t_data['count']
        return UI_ItemCard(item_id, count)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cc.size(108, 108)
    table_view_td.m_nItemPerCell = 7
    table_view_td:setCellUIClass(FruitCard, create_func)
    local skip_update = true
    table_view_td:setItemList(l_item_list, skip_update)

    -- 정렬
    local sort_type = 'default'
    local table_item = TableItem()
    local function sort_func(a, b)
        local a_data = a['data']
        local b_data = b['data']

        local a_item = table_item:get(a_data['fid'])
        local b_item = table_item:get(b_data['fid'])

        -- 열매 속성
        if (a_item['attr'] ~= b_item['attr']) then
            return a_item['attr'] > b_item['attr']
        end

        -- 열매 등급
        if (a_item['rarity'] ~= b_item['rarity']) then
            return a_item['rarity'] > b_item['rarity']
        end

        return a_data['fid'] < b_data['fid']
    end
    table_view_td:insertSortInfo(sort_type, sort_func)
    local b_force = false
    table_view_td:sortTableView(sort_type, b_force)


    self.m_fruitsTableView = table_view_td
end

-------------------------------------
-- function onEnterInventoryTab
-------------------------------------
function UI_InventoryTabFruit:onEnterInventoryTab(first)
    if first then
        self:init_fruitTableView()
    end
end