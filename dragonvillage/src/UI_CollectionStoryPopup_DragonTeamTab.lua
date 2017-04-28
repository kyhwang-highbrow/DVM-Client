local PARENT = ITabUI:getCloneClass()

-------------------------------------
-- class UI_CollectionStoryPopup_DragonTeamTab
-------------------------------------
UI_CollectionStoryPopup_DragonTeamTab = class(PARENT, {
        vars = '',
        m_selectDragonID = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_CollectionStoryPopup_DragonTeamTab:init(ui)
    self.vars = ui.vars
    self:initTab()
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_CollectionStoryPopup_DragonTeamTab:onEnterTab(first)
    self:setTab('list')
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_CollectionStoryPopup_DragonTeamTab:initTab()
    local vars = self.vars
    self:addTab('selected', vars['dragonSelectBtn'], vars['dragonListBtn'], vars['dragonUnitListNode'])
    self:addTab('list', vars['dragonListBtn'], vars['dragonSelectBtn'], vars['dragonListNode'])
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_CollectionStoryPopup_DragonTeamTab:onChangeTab(tab, first)
    local vars = self.vars
    if (tab == 'list') then
        vars['dragonSelectBtn']:setEnabled(false)
    end


    if (tab == 'list') then
        if first then
            self:init_tableViewDragonList()
        end
    elseif (tab == 'selected') then
        self:init_tableViewDragonUnitList()
    end
end

-------------------------------------
-- function init_tableViewDragonList
-------------------------------------
function UI_CollectionStoryPopup_DragonTeamTab:init_tableViewDragonList()
    local node = self.vars['dragonListNode']
    node:removeAllChildren()

    local role_option = 'all'
    local attr_option = 'all'
    local l_item_list = g_collectionData:getCollectionList(role_option, attr_option)

    local scale = 0.7
    local width, height = 150 * scale, 150 * scale

    -- 생성 콜백
    local function make_func(data)
        local ui = MakeSimpleDragonCard(data['did'])
        ui.vars['starIcon']:setVisible(false)

        if (not g_collectionData:isExist(data['did'])) then
            ui:setShadowSpriteVisible(true)
            ui.vars['shadowSprite']:setOpacity(127)
        end

        return ui
    end

    -- 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(scale)
        ui.vars['clickBtn']:registerScriptTapHandler(function()
                self.m_selectDragonID = data['did']
                self:setTab('selected')
            end)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cc.size(width + 7, height + 7)
    table_view_td.m_nItemPerCell = 10
    table_view_td:setCellUIClass(make_func, create_func)
    table_view_td:setItemList(l_item_list)

    table.sort(table_view_td.m_itemList, function(a, b)
            return a['data']['did'] < b['data']['did']
        end)
end

-------------------------------------
-- function init_tableViewDragonUnitList
-------------------------------------
function UI_CollectionStoryPopup_DragonTeamTab:init_tableViewDragonUnitList()
    local node = self.vars['dragonUnitListNode']
    node:removeAllChildren()

    local l_item_list = g_dragonUnitData:getDragonUnitIDList()

    -- 생성 콜백
    local function create_func(ui, data)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(1200, 150 + 5)
    table_view:setCellUIClass(UI_CollectionStoryPopupItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)
end