-------------------------------------
-- class UI_CollectionTabDragon
-------------------------------------
UI_CollectionTabDragon = class({
        vars = 'table',
        m_ownerUI = 'UI',

        m_roleRadioButton = 'UIC_RadioButton',
        m_attrRadioButton = 'UIC_RadioButton',

        m_tableViewTD = 'UIC_TableViewTD',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_CollectionTabDragon:init(owner_ui)
    self.m_ownerUI = owner_ui
    self.vars = owner_ui.vars
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_CollectionTabDragon:onEnterTab(first)
    if first then
        self:initUI()
    end
end

-------------------------------------
-- function initUI
-- @brief
-------------------------------------
function UI_CollectionTabDragon:initUI()
    local vars = self.vars

    -- 테이블 뷰 생성
    self:init_TableViewTD()

    do -- 역할(role)
        local radio_button = UIC_RadioButton()
        radio_button:addButton('all', vars['roleAllBtn'])
        radio_button:addButton('tanker', vars['tankerBtn'])
        radio_button:addButton('dealer', vars['dealerBtn'])
        radio_button:addButton('supporter', vars['supporterBtn'])
        radio_button:addButton('healer', vars['healerBtn'])
        radio_button:setSelectedButton('all')
        radio_button:setChangeCB(function() self:onChangeOption() end)
        self.m_roleRadioButton = radio_button
    end

    do -- 속성(attribute)
        local radio_button = UIC_RadioButton()
        radio_button:addButton('all', vars['attrAllBtn'])
        radio_button:addButton('fire', vars['fireBtn'])
        radio_button:addButton('water', vars['waterBtn'])
        radio_button:addButton('earth', vars['earthBtn'])
        radio_button:addButton('dark', vars['darkBtn'])
        radio_button:addButton('light', vars['lightBtn'])
        radio_button:setSelectedButton('all')
        radio_button:setChangeCB(function() self:onChangeOption() end)
        self.m_attrRadioButton = radio_button
    end

    -- 최초에 한번 실행
    self:onChangeOption()
end

-------------------------------------
-- function onChangeOption
-- @brief
-------------------------------------
function UI_CollectionTabDragon:onChangeOption()
    local role_option = self.m_roleRadioButton.m_selectedButton
    local attr_option = self.m_attrRadioButton.m_selectedButton


    local l_item_list = g_collectionData:getCollectionList(role_option, attr_option)

    self.m_tableViewTD:mergeItemList(l_item_list)
end

-------------------------------------
-- function init_TableView
-- @brief
-------------------------------------
function UI_CollectionTabDragon:init_TableViewTD()
    local node = self.vars['dragonListNode']
    --node:removeAllChildren()

    local l_item_list = {}

    -- 생성 콜백
    local scale = 0.8
    local function create_func(ui, data)
        ui.root:setScale(scale)

        
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cc.size((150 * scale) + 2, (188 * scale) + 5)
    table_view_td.m_nItemPerCell = 8
    table_view_td:setCellUIClass(UI_CollectionDragonCard, create_func)
    table_view_td:setItemList(l_item_list)
    --table_view_td:makeDefaultEmptyDescLabel(Str(''))

    -- 정렬
    self.m_tableViewTD = table_view_td
end