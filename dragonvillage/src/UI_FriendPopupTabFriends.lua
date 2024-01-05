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
--    if first then
        local function finish_cb(ret)
            self:init_tableView()
            
            local count = g_friendData:getFriendCount()
            local max = g_friendData:getMaxFriendCount()
            self.vars['listLabel']:setString(Str('{1} / {2}명', count, max))

            -- 모두 보내기 버튼 상태 갱신
	        self:setSendAllBtnActive()
        end
        local force = true
        g_friendData:request_friendList(finish_cb, force)
--    end
end

-------------------------------------
-- function init_tableView
-------------------------------------
function UI_FriendPopupTabFriends:init_tableView()
    local vars = self.vars

    if self.m_tableView then
        local l_item_list = g_friendData:getFriendList()
        self.m_tableView:mergeItemList(l_item_list)
        return
    end

    local node = self.vars['listNode']
    node:removeAllChildren()

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
    table_view.m_defaultCellSize = cc.size(1170, UIHelper:getProfileScrollItemHeight(108))
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setCellUIClass(UI_FriendListItem, create_func)
    table_view:setItemList(l_item_list)

    -- 리스트가 비었을 때
    --table_view:makeDefaultEmptyDescLabel(Str('친구가 없습니다.\n친구와 우정의 징표를 주고받을 수 있습니다.\n친구를 추가해보세요!'))
    table_view:setEmptyDescNode(vars['emptySprite'])

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
        UIManager:toastNotificationRed(Str('삭제는 1일 {1}회만 가능합니다.', bye_limit))
        return
    end

    local friend_uid = data.m_uid
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
        g_friendData:request_byeFriends(friend_uid, is_cash, success_cb)
    end

    -- 작별 후 안내 메세지
    success_cb = function(ret)
        local bye_cnt = g_friendData:getByeDailyCnt()
        local bye_limit = g_friendData:getByeDailyLimit()

        local nickname = data:getNickname()
        local message = Str('[{1}]님과 작별하였습니다.\n오늘 일반 친구 작별 횟수는\n{2}/{3}회 입니다.', nickname, bye_cnt, bye_limit)
        --UIManager:toastNotificationGreen(message)
        MakeSimplePopup(POPUP_TYPE.OK, message)

        self.m_tableView:delItem(friend_uid)
    end

    --ask_popup()
    request_bye_friend()
end

-------------------------------------
-- function click_sendAllBtn
-------------------------------------
function UI_FriendPopupTabFriends:click_sendAllBtn()
    -- 보낼 대상자가 0명일 경우
    if (not g_friendData:checkSendFp()) then
        UIManager:toastNotificationRed(Str('이미 모두에게 우정의 징표를 보냈습니다.'))
        return
    end

    local function finish_cb(ret)
        for i,v in ipairs(self.m_tableView.m_itemList) do
            local ui = v['ui']
            if ui then
                ui:refresh()
            end
        end
        -- 추가로 보낼 친구가 없다면 노티 꺼줌
        self.m_friendPopup:refreshHighlightFriend(g_friendData:checkSendFp())

        -- 모두 보내기 버튼 상태 갱신
        self:setSendAllBtnActive(false)
    end

    g_friendData:request_sendFpAllFriends(finish_cb)
end


-------------------------------------
-- function click_sendBtn
-------------------------------------
function UI_FriendPopupTabFriends:click_sendBtn(ui, data)
    local uid = data.m_uid
    local frined_uid_list = {uid}

    local function finish_cb(ret)
        local nick = data.m_nickname
        for i,v in ipairs(self.m_tableView.m_itemList) do
            local ui = v['ui']
            if ui then
                ui:refresh()
            end
        end
        -- 추가로 보낼 친구가 없다면 노티 꺼줌
        self.m_friendPopup:refreshHighlightFriend(g_friendData:checkSendFp())
        
        -- 모두 보내기 버튼 상태 갱신
        self:setSendAllBtnActive(false)
    end



    g_friendData:request_sendFp(frined_uid_list, finish_cb)
end

-------------------------------------
-- function setSendAllBtnActive
-- @brief 모두 보내기 버튼 활성화
-------------------------------------
function UI_FriendPopupTabFriends:setSendAllBtnActive(is_active)
    local is_active = is_active or false
    -- 보낼 대상자가 0명일 경우
    if (not g_friendData:checkSendFp()) then
        is_active = false
    else
        is_active = true
    end

    self.vars['sendAllNotiSprite']:setVisible(is_active)
end