-------------------------------------
-- class UI_CollectionStoryPopup_AllTeamTab
-------------------------------------
UI_CollectionStoryPopup_AllTeamTab = class({
        vars = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_CollectionStoryPopup_AllTeamTab:init(ui)
    self.vars = ui.vars
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_CollectionStoryPopup_AllTeamTab:onEnterTab(first)
    self:init_TableView()
end

-------------------------------------
-- function init_TableView
-- @brief
-------------------------------------
function UI_CollectionStoryPopup_AllTeamTab:init_TableView()
    local node = self.vars['allTeamMenu']
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
    --table_view_td:makeDefaultEmptyDescLabel(Str(''))
end