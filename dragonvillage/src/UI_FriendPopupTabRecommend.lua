local PARENT = UI_FriendPopupTab

-------------------------------------
-- class UI_FriendPopupTabRecommend
-------------------------------------
UI_FriendPopupTabRecommend = class(PARENT, {
        m_tableView = 'UIC_TableView',
        m_tableViewFacebook = 'UIC_TableView',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_FriendPopupTabRecommend:init(friend_popup_ui)
end

-------------------------------------
-- function initFirst
-------------------------------------
function UI_FriendPopupTabRecommend:initFirst()
    local vars = self.vars
    vars['findBtn']:registerScriptTapHandler(function() self:click_findBtn() end)
end

-------------------------------------
-- function onEnterFriendPopupTab
-------------------------------------
function UI_FriendPopupTabRecommend:onEnterFriendPopupTab(first)
    if first then
        self:initFirst()

        local function finish_cb()
            self:init_tableView()
            self:init_tableViewFacebook()
        end

        local force = true
        g_friendData:request_recommend(finish_cb, force)
    end
end

-------------------------------------
-- function click_findBtn
-------------------------------------
function UI_FriendPopupTabRecommend:click_findBtn()
    local vars = self.vars

    local nick = vars['findEditBox']:getText()
    if (nick == '') then
        MakeSimplePopup(POPUP_TYPE.OK, Str('검색할 친구의 닉네임을 입력하세요.'))
        return
    end

    -- 친구 검색 완료
    local function finish_cb(ret)
        local l_user_list = ret['users_list']
        local t_friend_info = l_user_list[1]

        if (not t_friend_info) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('[{1}]님을 찾지 못하였습니다.', nick))
        else
            UI_LobbyUserInfoPopup(t_friend_info)
        end
    end

    -- 친구 검색
    g_friendData:request_find(nick, finish_cb)
end

-------------------------------------
-- function init_tableView
-------------------------------------
function UI_FriendPopupTabRecommend:init_tableView()
    if self.m_tableView then
        return
    end

    local node = self.vars['recommendNode2']
    --node:removeAllChildren()

    local l_item_list = g_friendData:getRecommendUserList()

    -- 생성 콜백
    local function create_func(ui, data)
        local function click_func()
            self:click_requestBtn(data)
        end

        ui.vars['requestBtn']:registerScriptTapHandler(click_func)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(564, 108)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setCellUIClass(UI_FriendRecommendUserListItem, create_func)
    table_view:setItemList(l_item_list)

    -- 리스트가 비었을 때
    table_view:makeDefaultEmptyDescLabel(Str('추천 친구가 없습니다.'))

    --[[
    -- 정렬
    local sort_manager = SortManager_Fruit()
    sort_manager:sortExecution(table_view.m_itemList)
    table_view:setDirtyItemList()
    --]]

    self.m_tableView = table_view
end

-------------------------------------
-- function init_tableViewFacebook
-------------------------------------
function UI_FriendPopupTabRecommend:init_tableViewFacebook()
    if self.m_tableViewFacebook then
        return
    end

    local node = self.vars['recommendNode1']
    --node:removeAllChildren()

    local l_item_list = {}

    -- 생성 콜백
    local function create_func(ui, data)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(564, 108)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setCellUIClass(UI_FriendRecommendUserListItem, create_func)
    table_view:setItemList(l_item_list)

    -- 리스트가 비었을 때
    table_view:makeDefaultEmptyDescLabel(Str('페이스북 연동이 되어있지 않습니다.'))

    self.m_tableViewFacebook = table_view
end

-------------------------------------
-- function click_requestBtn
-------------------------------------
function UI_FriendPopupTabRecommend:click_requestBtn(t_friend_info)
    local function finish_cb(ret)
        local msg = Str('[{1}]에게 친구 요청을 하였습니다.', t_friend_info['nick'])
        UIManager:toastNotificationGreen(msg)

        local friend_ui = t_friend_info['uid']
        self.m_tableView:delItem(friend_ui)
    end

    local friend_ui = t_friend_info['uid']
    g_friendData:request_invite(friend_ui, finish_cb)
end
