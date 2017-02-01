local PARENT = UI_FriendPopupTab

-------------------------------------
-- class UI_FriendPopupTabFriends
-------------------------------------
UI_FriendPopupTabFriends = class(PARENT, {
        m_tableView = 'UIC_TableView',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_FriendPopupTabFriends:init(friend_popup_ui)
end

-------------------------------------
-- function onEnterFriendPopupTab
-------------------------------------
function UI_FriendPopupTabFriends:onEnterFriendPopupTab(first)
    if first then
        self:init_tableView()
    end
end

-------------------------------------
-- function init_tableView
-------------------------------------
function UI_FriendPopupTabFriends:init_tableView()
    if self.m_tableView then
        return
    end

    local node = self.vars['listNode']
    --node:removeAllChildren()

    local l_item_list = {1,2,3,4,5,6,7,8,9,10}

    -- 생성 콜백
    local function create_func(ui, data)
        local function click_func()
        end

        --ui.vars['clickBtn']:registerScriptTapHandler(click_func)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(1160, 108)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setCellUIClass(UI_FriendListItem, create_func)
    local skip_update = false --정렬 시 update되기 때문에 skip
    table_view:setItemList(l_item_list, skip_update)

    --[[
    -- 정렬
    local sort_manager = SortManager_Fruit()
    sort_manager:sortExecution(table_view.m_itemList)
    table_view:expandTemp(0.5)
    --]]

    self.m_tableView = table_view
end