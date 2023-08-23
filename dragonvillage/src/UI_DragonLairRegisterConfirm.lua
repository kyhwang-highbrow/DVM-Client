local PARENT = UI
-------------------------------------
-- class UI_DragonLairRegisterConfirm
-------------------------------------
UI_DragonLairRegisterConfirm = class(PARENT,{
    m_dragonTableView = 'TableVIew',
    m_dragonList = '',
    m_sortManagerDragon = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonLairRegisterConfirm:init(struct_dragon_list)
    self.m_uiName = 'UI_DragonLairRegisterConfirm'
    self.m_dragonList = struct_dragon_list
    
    local vars = self:load('dragon_lair_register_confirm.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_DragonLairRegisterConfirm')

    self:initUI()
    self:initButton()
    self:initTableView()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonLairRegisterConfirm:initUI()
    local vars = self.vars
    local sort_mgr = SortManager_Dragon()
    sort_mgr:pushSortOrder('grade')
    self.m_sortManagerDragon = sort_mgr
    --self.m_sortManagerDragon:addPreSortType('sort_lair_register_available', false, sort_lair_register_available)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonLairRegisterConfirm:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function getDragonList
-- @breif 하단 리스트뷰에 노출될 드래곤 리스트
-------------------------------------
function UI_DragonLairRegisterConfirm:getDragonList()
    return self.m_dragonList
end

-------------------------------------
-- function getAvailableDragonDoids
-------------------------------------
function UI_DragonLairRegisterConfirm:getAvailableDragonDoids()
    local doid_list = {}
    for i,v in ipairs(self.m_dragonList) do
        table.insert(doid_list, v['id'])
    end
    return table.concat(doid_list, ',')
end

-------------------------------------
-- function initTableView
-- @breif 드래곤 리스트 테이블 뷰
-------------------------------------
function UI_DragonLairRegisterConfirm:initTableView()

    local list_table_node = self.vars['materialList']
    list_table_node:removeAllChildren()

    local function make_func(object)
        return UI_DragonCard(object)
    end

    local function create_func(ui, data)
        ui.root:setScale(0.66)
        -- 이미 한번 등록된 드래곤이냐?
        --local is_register_doid = g_lairData:isRegisterLairByDoid(data['did'], data['id'])
        --ui:setTeamBonusCheckSpriteVisible(is_register_doid)

        local is_meet_condition = TableLairCondition:getInstance():isMeetCondition(data)
        local is_registered = g_lairData:isRegisterLairDid(data['did'])
        local is_register_available = is_meet_condition == true and is_registered == false

        ui.root:setColor(is_registered == true and COLOR['white'] or COLOR['deep_gray'])
        ui:setHighlightSpriteVisible(is_register_available)

        --ui.vars['clickBtn']:registerScriptTapHandler(function() self:registerToLair(data['id']) end)
        return ui
    end

    local table_view_td = UIC_TableViewTD(list_table_node)
    table_view_td.m_cellSize = cc.size(100, 100)
    table_view_td.m_nItemPerCell = 9
    table_view_td:setCellUIClass(make_func, create_func)
    self.m_dragonTableView = table_view_td
    

    local l_item_list = self:getDragonList()
    self.m_dragonTableView:setItemList(l_item_list)


    self:apply_dragonSort()
end

-------------------------------------
-- function apply_dragonSort
-- @brief 테이블 뷰에 정렬 적용
-------------------------------------
function UI_DragonLairRegisterConfirm:apply_dragonSort()
    if self.m_dragonTableView == nil then
        return
    end

    local list = self.m_dragonTableView.m_itemList
    self.m_sortManagerDragon:sortExecution(list)
    self.m_dragonTableView:setDirtyItemList()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonLairRegisterConfirm:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_registerBtn
-------------------------------------
function UI_DragonLairRegisterConfirm:click_registerBtn()
end

-------------------------------------
-- function click_backKey
-------------------------------------
function UI_DragonLairRegisterConfirm:click_closeBtn()
    self:close()
end

-------------------------------------
-- function open
-------------------------------------
function UI_DragonLairRegisterConfirm.open(struct_dragon_list)
    return UI_DragonLairRegisterConfirm(struct_dragon_list)
end