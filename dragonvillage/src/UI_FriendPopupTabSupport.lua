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
    if first then
        self:init_tableView()
    end

    self:refresh()
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
    table_view.m_defaultCellSize = cc.size(770, 150)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setCellUIClass(UI_FriendSupportListItem, create_func)
    table_view:setItemList(l_item_list)

    -- 리스트가 비었을 때
    table_view:makeDefaultEmptyDescLabel(Str('드래곤 지원 요청이 없습니다.'))

    -- 정렬

    self.m_tableView = table_view
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_FriendPopupTabSupport:refresh()
    local vars = self.vars

    -- 드래곤 희귀도별 지원 가능 여부 텍스트 출력
    vars['timeLabel1']:setString(g_friendData:getDragonSupportRequestCooltimeText('common'))
    vars['timeLabel2']:setString(g_friendData:getDragonSupportRequestCooltimeText('rare'))
    vars['timeLabel3']:setString(g_friendData:getDragonSupportRequestCooltimeText('hero'))
    vars['timeLabel4']:setString(g_friendData:getDragonSupportRequestCooltimeText('legend'))

    -- 지원 요청 중인 드래곤 아이콘
    vars['dragonNode']:removeAllChildren()
    local dragon_request_info = g_friendData:getMyDragonSupporRequesttInfo()
    if (dragon_request_info['did'] and (dragon_request_info['support_finish'] == false)) then
        local card = MakeSimpleDragonCard(dragon_request_info['did'])
        vars['dragonNode']:addChild(card.root)
    end
end

