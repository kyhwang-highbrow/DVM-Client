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

    vars['supportRequestBtn']:registerScriptTapHandler(function() self:click_supportRequestBtn() end)
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
        local function click_supportBtn()
            local t_friend_info = data
            self:click_supportBtn(t_friend_info)
        end
        ui.vars['supportBtn']:registerScriptTapHandler(click_supportBtn)
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

-------------------------------------
-- function click_supportRequestBtn
-------------------------------------
function UI_FriendPopupTabSupport:click_supportRequestBtn()
    local ui = UI_FriendDragonSupportRequestPopup()

    local function close_cb()
        if ui.m_bRequestedSupportDragon then
            self:refresh()
        end
    end

    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_supportBtn
-------------------------------------
function UI_FriendPopupTabSupport:click_supportBtn(t_friend_info)
    local l_need_info = t_friend_info['need_did']
    local t_need_info = g_friendData:parseDragonSupportRequestInfo(l_need_info)
    local did = t_need_info['did']

    local number = g_dragonsData:getNumOfDragonsByDid(did)

    if (number <= 0) then
        local name = Str(TableDragon():getValue(did, 't_name'))
        UIManager:toastNotificationRed(Str('{1}을 보유하고 있지 않습니다.', name))
        return
    end

    local ui = UI_FriendDragonSupportPopup(t_friend_info)
    local function close_cb()
        local fuid = t_friend_info['uid']
        self.m_tableView:delItem(fuid)
    end
    ui:setCloseCB(close_cb)
end