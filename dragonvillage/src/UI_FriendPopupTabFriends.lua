local PARENT = UI_FriendPopupTab

-------------------------------------
-- class UI_FriendPopupTabFriends
-------------------------------------
UI_FriendPopupTabFriends = class(PARENT, {
        m_friendSortManager = 'SortManager_Friend',
        m_tableView = 'UIC_TableView',
        m_bManageMode = 'boolean',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_FriendPopupTabFriends:init(friend_popup_ui)
    self.m_bManageMode = false

    local vars = self.vars
    vars['listLabel']:setString('')
    vars['manageBtn']:registerScriptTapHandler(function() self:click_manageBtn() end)
    vars['sendAllBtn']:registerScriptTapHandler(function() self:click_sendAllBtn() end)
end

-------------------------------------
-- function onEnterFriendPopupTab
-------------------------------------
function UI_FriendPopupTabFriends:onEnterFriendPopupTab(first)
    --if first then
        local function finish_cb(ret)
            self:init_tableView()

            -- 친구 명수
            local count = g_friendData:getFriendCount()
            local max = g_friendData:getMaxFriendCount()
            self.vars['listLabel']:setString(Str('{1} / {2}명', count, max))
        end
        local force = true
        g_friendData:request_friendList(finish_cb, force)
    --end
end

-------------------------------------
-- function init_tableView
-------------------------------------
function UI_FriendPopupTabFriends:init_tableView()
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
    table_view:makeDefaultEmptyDescLabel(Str('친구가 없습니다.\n친구와 우정 징표를 주고받을 수 있습니다.\n친구를 추가해보세요!'))

    -- 정렬
    local sort_manager = SortManager_Friend()
    sort_manager:sortExecution(table_view.m_itemList)
    self.m_friendSortManager = sort_manager

    self.m_tableView = table_view
end

-------------------------------------
-- function click_manageBtn
-------------------------------------
function UI_FriendPopupTabFriends:click_manageBtn()
    self.m_bManageMode = (not self.m_bManageMode)

    for i,v in ipairs(self.m_tableView.m_itemList) do
        local ui = v['ui']
        self:refresh_friendListItem(ui, data)
    end
end

-------------------------------------
-- function refresh_friendListItem
-------------------------------------
function UI_FriendPopupTabFriends:refresh_friendListItem(ui, data)
    if (not ui) then
        return
    end

    ui.m_bManageMode = self.m_bManageMode
    ui:refresh()
end

-------------------------------------
-- function click_deleteBtn
-------------------------------------
function UI_FriendPopupTabFriends:click_deleteBtn(ui, data)


    local bye_cnt = g_friendData:getByeDailyCnt()
    local bye_limit = g_friendData:getByeDailyLimit()

    if (bye_cnt >= bye_limit) then
        UIManager:toastNotificationRed(Str('일반 친구 작별은 하루에 최대 {1}번까지 할 수 있습니다.', bye_limit))
        return
    end


    local friend_uid = data['uid']
    local friend_type = data['friendtype']
    local is_cash = false

    local ask_popup
    local request_bye_friend
    local success_cb

    -- 작별 시행 여부를 확인함
    ask_popup = function()
        local massage = Str('일반 친구 작별은 하루에\n최대 {1}회까지 할 수 있습니다.\n현재 작별 횟수는 {2}회입니다.\n[{3}]님과 작별하시겠습니까?', bye_limit, bye_cnt, data['nick'])
        MakeSimplePopup(POPUP_TYPE.YES_NO, massage, request_bye_friend)
    end

    -- 서버에 작별 요청
    request_bye_friend = function()
        g_friendData:request_byeFriends(friend_uid, friend_type, is_cash, success_cb)
    end

    -- 작별 후 안내 메세지
    success_cb = function(ret)
        local bye_cnt = g_friendData:getByeDailyCnt()
        local bye_limit = g_friendData:getByeDailyLimit()

        local message = Str('[{1}]님과 작별하였습니다.\n오늘 일반 친구 작별 횟수는\n{2}/{3}회 입니다.', data['nick'], bye_cnt, bye_limit)
        --UIManager:toastNotificationGreen(message)
        MakeSimplePopup(POPUP_TYPE.OK, message)

        self.m_tableView:delItem(friend_uid)
    end

    ask_popup()
end

-------------------------------------
-- function click_sendAllBtn
-------------------------------------
function UI_FriendPopupTabFriends:click_sendAllBtn()
    local function finish_cb(ret)
        local msg = Str('모든 친구에게 우정포인트를 보냈습니다.')
        UIManager:toastNotificationGreen(msg)

        for i,v in ipairs(self.m_tableView.m_itemList) do
            local ui = v['ui']
            if ui then
                ui:refresh()
            end
        end
    end

    g_friendData:request_sendFpAllFriends(finish_cb)
end


-------------------------------------
-- function click_sendBtn
-------------------------------------
function UI_FriendPopupTabFriends:click_sendBtn(ui, data)
    local uid = data['uid']
    local frined_uid_list = {uid}

    local function finish_cb(ret)
        local nick = data['nick']
        local msg = Str('[{1}]님에게 우정포인트를 보냈습니다.', nick)
        UIManager:toastNotificationGreen(msg)

        for i,v in ipairs(self.m_tableView.m_itemList) do
            local ui = v['ui']
            if ui then
                ui:refresh()
            end
        end
    end

    g_friendData:request_sendFp(frined_uid_list, finish_cb)
end