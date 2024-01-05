local PARENT = UI_FriendPopupTab

-------------------------------------
-- class UI_FriendPopupTabResponse
-------------------------------------
-- 보낸 요청
UI_FriendPopupTabResponse = class(PARENT, {
        m_tableView = 'UIC_TableView',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_FriendPopupTabResponse:init(friend_popup_ui)
end

-------------------------------------
-- function initFirst
-------------------------------------
function UI_FriendPopupTabResponse:initFirst()
    local vars = self.vars
end

-------------------------------------
-- function onEnterFriendPopupTab
-------------------------------------
function UI_FriendPopupTabResponse:onEnterFriendPopupTab(first)
    if first then
        self:initFirst()

        local function finish_cb()
            self:init_tableView()
            self:setCountLabel()
        end

        local force = true
        g_friendData:request_inviteResponseList(finish_cb, force)
    end
end

-------------------------------------
-- function setCountLabel
-------------------------------------
function UI_FriendPopupTabResponse:setCountLabel()
    local count = self.m_tableView:getItemCount()
    local max = g_friendData:getInviteResponseDailyLimit()

    self.vars['responseLabel']:setString(Str('{1} / {2}', count, max))
end

-------------------------------------
-- function init_tableView
-------------------------------------
function UI_FriendPopupTabResponse:init_tableView()
    if self.m_tableView then
        return
    end

    local node = self.vars['responseNode']
    --node:removeAllChildren()

    local l_item_list = g_friendData:getFriendInviteResponseList()

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
    table_view.m_defaultCellSize = cc.size(1170, UIHelper:getProfileScrollItemHeight(108))
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setCellUIClass(UI_FriendResponseListItem, create_func)
    table_view:setItemList(l_item_list)

    
    -- 리스트가 비었을 때
    table_view:makeDefaultEmptyDescLabel(Str('받은 요청이 없습니다.'))

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
function UI_FriendPopupTabResponse:click_inviteAcceptBtn(data)
    local friend_uid = data.m_uid
    local friend_nick = data.m_nickname

    local function finish_cb(ret)
        if (ret['status'] == 0) then
            table_view = self.m_tableView
            table_view:delItem(friend_uid)
            self:setCountLabel()

            local msg = Str('[{1}]님과 친구가 되었습니다.', friend_nick)
            UIManager:toastNotificationGreen(msg)

            -- 친구 추가되었다면 노티 켜줌
            self.m_friendPopup:refreshHighlightFriend(true)
            
            -- 남은 친구 수락이 없다면 노티 꺼줌
            self.m_friendPopup:refreshHighlightResponse(not (#self.m_tableView == 0))
        end
    end
    
    g_friendData:request_inviteResponseAccept(friend_uid, finish_cb)
end

-------------------------------------
-- function click_inviteRefuseBtn
-- @brief 친구 요청 거절
-- @param struct_user_info StructUserInfo
-------------------------------------
function UI_FriendPopupTabResponse:click_inviteRefuseBtn(struct_user_info)
    local friend_uid = struct_user_info:getUid()
    local friend_nick = struct_user_info:getNickname()

    local function finish_cb(ret)
        if (ret['status'] == 0) then
            table_view = self.m_tableView
            table_view:delItem(friend_uid)
            self:setCountLabel()

            local msg = Str('[{1}]님의 요청을 거절하였습니다.', friend_nick)
            UIManager:toastNotificationGreen(msg)
        end
    end
    
    g_friendData:request_inviteResponseReject(friend_uid, finish_cb)
end