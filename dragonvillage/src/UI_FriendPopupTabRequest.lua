local PARENT = UI_FriendPopupTab

-------------------------------------
-- class UI_FriendPopupTabRequest
-------------------------------------
UI_FriendPopupTabRequest = class(PARENT, {
        m_tableView = 'UIC_TableView',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_FriendPopupTabRequest:init(friend_popup_ui)
end

-------------------------------------
-- function initFirst
-------------------------------------
function UI_FriendPopupTabRequest:initFirst()
    local vars = self.vars
end

-------------------------------------
-- function onEnterFriendPopupTab
-------------------------------------
function UI_FriendPopupTabRequest:onEnterFriendPopupTab(first)
    if first then
        self:initFirst()

        local function finish_cb()
            self:init_tableView()

            local count = self.m_tableView:getItemCount()
            self.vars['requestLabel1']:setString(Str('{1} / {2}', count, 100))
        end

        local force = true
        g_friendData:request_inviteList(finish_cb, force)
    end
end

-------------------------------------
-- function init_tableView
-------------------------------------
function UI_FriendPopupTabRequest:init_tableView()
    if self.m_tableView then
        return
    end

    local node = self.vars['requestNode']
    --node:removeAllChildren()

    local l_item_list = g_friendData:getFriendInviteList()

    -- 생성 콜백
    local function create_func(ui, data)
        local function click_func()
            self:click_inviteAcceptBtn(data)
        end

        ui.vars['acceptBtn']:registerScriptTapHandler(click_func)

        local function click_refuseBtn()
            self:click_inviteRefuseBtn(data)
        end
        ui.vars['refuseBtn']:registerScriptTapHandler(click_refuseBtn)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(1160, 108)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setCellUIClass(UI_FriendRequestListItem, create_func)
    table_view:setItemList(l_item_list)

    --[[
    -- 정렬
    local sort_manager = SortManager_Fruit()
    sort_manager:sortExecution(table_view.m_itemList)
    table_view:setDirtyItemList()
    --]]

    self.m_tableView = table_view
end

-------------------------------------
-- function click_inviteAcceptBtn
-- @brief 친구 요청 수락
-------------------------------------
function UI_FriendPopupTabRequest:click_inviteAcceptBtn(data)

    local friend_uid = data['uid']
    local friend_nick = data['nick']

    local function finish_cb(ret)
        if (ret['status'] == 0) then
            table_view = self.m_tableView
            table_view:delItem(friend_uid)

            local msg = Str('[{1}]님과 친구가 되었습니다.', friend_nick)
            UIManager:toastNotificationGreen(msg)
        end
    end
    
    g_friendData:request_inviteAccept(friend_uid, finish_cb)
end

-------------------------------------
-- function click_inviteRefuseBtn
-- @brief 친구 요청 거절
-------------------------------------
function UI_FriendPopupTabRequest:click_inviteRefuseBtn(data)

    local friend_uid = data['uid']
    local friend_nick = data['nick']

    local function finish_cb(ret)
        if (ret['status'] == 0) then
            table_view = self.m_tableView
            table_view:delItem(friend_uid)

            local msg = Str('[{1}]님의 요청을 거절하였습니다.', friend_nick)
            UIManager:toastNotificationGreen(msg)
        end
    end
    
    g_friendData:request_inviteReject(friend_uid, finish_cb)
end