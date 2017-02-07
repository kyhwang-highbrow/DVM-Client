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

    if first then
        self:init_tableView()
    end
end

-------------------------------------
-- function init_tableView
-------------------------------------
function UI_FriendPopupTabSupport:init_tableView()
    local node = self.vars['supportNode']
    --node:removeAllChildren()

    local l_item_list = g_friendData:getDragonSupportRequestList()

    -- 생성 콜백
    local function create_func(ui, data)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(1160, 108)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setCellUIClass(UI_FriendListItem, create_func)
    table_view:setItemList(l_item_list)

    -- 리스트가 비었을 때
    table_view:makeDefaultEmptyDescLabel(Str('드래곤 지원 요청이 없습니다.'))

    -- 정렬

    self.m_tableView = table_view
end