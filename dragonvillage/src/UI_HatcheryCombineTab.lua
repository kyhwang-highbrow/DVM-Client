local PARENT = UI_IndivisualTab

-------------------------------------
-- class UI_HatcheryCombineTab
-- @brief 드래곤 조합
-------------------------------------
UI_HatcheryCombineTab = class(PARENT,{
        m_tableViewTD = 'UIC_TableViewTD',
        m_selectedDid = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_HatcheryCombineTab:init(owner_ui)
    local vars = self:load('hatchery_combine.ui')
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_HatcheryCombineTab:onEnterTab(first)
    if first then
        self:initUI()
    end
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_HatcheryCombineTab:onExitTab()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_HatcheryCombineTab:initUI()
    self:init_TableView()
end

-------------------------------------
-- function init_TableView
-------------------------------------
function UI_HatcheryCombineTab:init_TableView()
    local list_table_node = self.vars['materialTableViewNode']
    list_table_node:removeAllChildren()

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        --[[
        ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonCard(data['did']) end)
        
        -- 선택되어있는 아이템일 경우
        if (self.m_selectedDid == data['did']) then
            ui:setSelected(true)
        end
        --]]
    end

    -- 테이블뷰 생성
    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size(128 + 12, 166 + 12)
    table_view_td.m_nItemPerCell = 4
    table_view_td:setCellUIClass(UI_HatcheryRelationItem, create_func)
    self.m_tableViewTD = table_view_td

    -- 리스트가 비었을 때
    table_view_td:makeDefaultEmptyDescLabel('')

    -- 재료로 사용 가능한 리스트를 얻어옴
    local l_dragon_list = self:getDragonList()
    table_view_td:setItemList(l_dragon_list)
end

-------------------------------------
-- function getDragonList
-------------------------------------
function UI_HatcheryCombineTab:getDragonList()
    local table_dragon_combine = TableDragonCombine()
    local table_dragon = TableDragon()

    local t_ret = {}
    for i,v in pairs(table_dragon_combine.m_orgTable) do
        local t_data = {}
        t_data['did'] = v['did']
        t_data['grade'] = table_dragon:getValue(v['did'], 'birthgrade')
        t_ret[i] = StructDragonObject(t_data)
    end

    return t_ret
end

-------------------------------------
-- function click_dragonCard
-- @brief
-------------------------------------
function UI_HatcheryCombineTab:click_dragonCard(did)
    self.m_selectedDid = did

    local t_data = {}
    t_data['did'] = v['did']
    t_data['grade'] = table_dragon:getValue(v['did'], 'birthgrade')


    UI_CharacterCard()
end


-------------------------------------
-- function getCombineMaterialList
-- @brief 내가 보유한 드래곤들 중 재료로 사용 가능한 항목 리턴
-------------------------------------
function UI_HatcheryCombineTab:getCombineMaterialList(did)
    local table_dragon_combine = TableDragonCombine()
    local t_dragon_combine = table_dragon_combine:get(did)

    local l_dragon = g_dragonsData:getDragonsListRef()
end