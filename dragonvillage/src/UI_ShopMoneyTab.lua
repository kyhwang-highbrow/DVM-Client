local PARENT = UI_IndivisualTab

-------------------------------------
-- class UI_ShopMoneyTab
-------------------------------------
UI_ShopMoneyTab = class(PARENT,{
        m_tableViewTD = 'UIC_TableViewTD',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ShopMoneyTab:init(owner_ui)
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_ShopMoneyTab:onEnterTab(first)
    if (first == true) then
        self:initUI()
    end
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_ShopMoneyTab:onExitTab()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ShopMoneyTab:initUI()
    local vars = self.vars

    self:init_TableView()
end

-------------------------------------
-- function init_TableView
-------------------------------------
function UI_ShopMoneyTab:init_TableView()
    --[[
    local list_table_node = self.m_ownerUI.vars['tableViewNode']
    list_table_node:removeAllChildren()

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        --ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonCard(data['did']) end)
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size(128 + 12, 166 + 12)
    table_view_td.m_nItemPerCell = 4
    table_view_td:setCellUIClass(UI_HatcheryCombineItem, create_func)
    self.m_tableViewTD = table_view_td

    -- 리스트가 비었을 때
    table_view_td:makeDefaultEmptyDescLabel('')

    -- 재료로 사용 가능한 리스트를 얻어옴
    local l_dragon_list = self:getDragonList()
    table_view_td:setItemList(l_dragon_list)
    --]]
end