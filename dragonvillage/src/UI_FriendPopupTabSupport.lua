local PARENT = UI_FriendPopupTab

-------------------------------------
-- class UI_FriendPopupTabSupport
-------------------------------------
UI_FriendPopupTabSupport = class(PARENT, {
        m_tableView = 'UIC_TableView',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_FriendPopupTabSupport:init(friend_popup_ui)
    self.m_bManageMode = false

    local vars = self.vars
end

-------------------------------------
-- function onEnterFriendPopupTab
-------------------------------------
function UI_FriendPopupTabSupport:onEnterFriendPopupTab(first)
    --[[
    --if first then
        local function finish_cb(ret)
            self:init_tableView()

            -- 친구 명수
            local count = g_friendData:getFriendCount()
            self.vars['listLabel']:setString(Str('{1} / {2}명', count, 20))
        end
        local force = true
        g_friendData:request_friendList(finish_cb, force)
    --end
    --]]
end

-------------------------------------
-- function init_tableView
-------------------------------------
function UI_FriendPopupTabSupport:init_tableView()
    if self.m_tableView then
        local l_item_list = g_friendData:getFriendList()
        self.m_tableView:mergeItemList(l_item_list)
        return
    end

    local node = self.vars['listNode']
    --node:removeAllChildren()

    local l_item_list = g_friendData:getFriendList()

    -- 생성 콜백
    local function create_func(ui, data)

        -- 친구 삭제
        local function click_deleteBtn()
            self:click_deleteBtn(ui, data)
        end
        ui.vars['deleteBtn']:registerScriptTapHandler(click_deleteBtn)

        -- 우정 포인트 보내기
        local function click_sendBtn()
            self:click_sendBtn(ui, data)
        end
        ui.vars['sendBtn']:registerScriptTapHandler(click_sendBtn)

        self:refresh_friendListItem(ui, data)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(1160, 108)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setCellUIClass(UI_FriendListItem, create_func)
    table_view:setItemList(l_item_list)

    -- 리스트가 비었을 때
    table_view:makeDefaultEmptyDescLabel(Str('친구가 한명도 없어요 T.T'))

    --[[
    -- 정렬
    local sort_manager = SortManager_Fruit()
    sort_manager:sortExecution(table_view.m_itemList)
    table_view:setDirtyItemList()
    --]]

    self.m_tableView = table_view
end