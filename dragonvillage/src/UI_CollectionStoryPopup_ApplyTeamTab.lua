-------------------------------------
-- class UI_CollectionStoryPopup_ApplyTeamTab
-------------------------------------
UI_CollectionStoryPopup_ApplyTeamTab = class({
        vars = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_CollectionStoryPopup_ApplyTeamTab:init(ui)
    self.vars = ui.vars
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_CollectionStoryPopup_ApplyTeamTab:onEnterTab(first)
    if first then

    end

    local l_ret = g_dragonUnitData:getDragonUnitList_deck('1')

    --ccdump(l_ret)
    self:init_tableViewDragonUnitList(l_ret)
end

-------------------------------------
-- function init_tableViewDragonUnitList
-------------------------------------
function UI_CollectionStoryPopup_ApplyTeamTab:init_tableViewDragonUnitList(l_ret)
    local node = self.vars['applyDragonListNode']
    node:removeAllChildren()

    local l_item_list = l_ret

    -- 생성 콜백
    local function create_func(ui, data)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(790, 150 + 5)
    table_view:setCellUIClass(UI_CollectionStoryPopupApplyItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)
    table_view:makeDefaultEmptyDescLabel(Str('적용 팀 효과가 없습니다.'))
end