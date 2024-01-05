local PARENT = UI_FriendPopupTab

-------------------------------------
-- class UI_FriendPopupTabRequest
-------------------------------------
-- 보낸 요청
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
            self:setCountLabel()
        end

        local force = true
        g_friendData:request_inviteRequestList(finish_cb, force)
    else
        self:checkTableViewData()
    end
end

-------------------------------------
-- function setCountLabel
-------------------------------------
function UI_FriendPopupTabRequest:setCountLabel()
    local count = self.m_tableView:getItemCount()
    local max = g_friendData:getInviteRequestDailyLimit()

    self.vars['requestLabel']:setString(Str('{1} / {2}', count, max))
end

-------------------------------------
-- function checkTableViewData
-- @brief 친구 초대로 요청 리스트 추가시 테이블뷰 아이템 추가
-------------------------------------
function UI_FriendPopupTabRequest:checkTableViewData()
    local table_view = self.m_tableView
    local item_count = table_view:getItemCount()
    local list_count = g_friendData:getFirnedInviteRequestCount()
    if (item_count == list_count)
        then return
    end

    local request_list = g_friendData:getFriendInviteRequestList()

    for _, v in pairs(request_list) do
        local friend_uid = v.m_uid
        if (not table_view:getItem(friend_uid)) then
            table_view:addItem(friend_uid, v)
            self:setCountLabel()
        end
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

    local l_item_list = g_friendData:getFriendInviteRequestList()

    -- 생성 콜백
    local function create_func(ui, data)
        -- 요청 취소
        local function click_cancelBtn()
            self:click_inviteRequestCancelBtn(data)
        end
        ui.vars['cancelBtn']:registerScriptTapHandler(click_cancelBtn)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(1170, UIHelper:getProfileScrollItemHeight(108))
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setCellUIClass(UI_FriendRequestListItem, create_func)
    table_view:setItemList(l_item_list)

    
    -- 리스트가 비었을 때
    table_view:makeDefaultEmptyDescLabel(Str('보낸 요청이 없습니다.'))

    --[[
    -- 정렬
    local sort_manager = SortManager_Fruit()
    sort_manager:sortExecution(table_view.m_itemList)
    table_view:setDirtyItemList()
    --]]

    self.m_tableView = table_view
end

-------------------------------------
-- function click_inviteRequestCancelBtn
-- @brief 친구 요청 취소
-------------------------------------
function UI_FriendPopupTabRequest:click_inviteRequestCancelBtn(data)
    
    local friend_uid = data.m_uid
    local friend_nick = data.m_nickname

    local function finish_cb(ret)
        if (ret['status'] == 0) then
            table_view = self.m_tableView
            table_view:delItem(friend_uid)
            self:setCountLabel()
        end
    end
    
    g_friendData:request_inviteRequestCancel(friend_uid, finish_cb)
end
