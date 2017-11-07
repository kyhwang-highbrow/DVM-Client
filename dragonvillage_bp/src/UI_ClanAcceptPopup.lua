local PARENT = UI

-------------------------------------
-- class UI_ClanAcceptPopup
-------------------------------------
UI_ClanAcceptPopup = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanAcceptPopup:init()
    local vars = self:load('clan_request.ui')
    UIManager:open(self, UIManager.POPUP)

    self.m_uiName = 'UI_ClanAcceptPopup'
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ClanAcceptPopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ClanAcceptPopup:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanAcceptPopup:initUI()
    local vars = self.vars
    self:init_TableView()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanAcceptPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanAcceptPopup:refresh()
    local vars = self.vars
end

-------------------------------------
-- function init_TableView
-------------------------------------
function UI_ClanAcceptPopup:init_TableView()
    local node = self.vars['listNode']
    node:removeAllChildren()

    local l_item_list = g_clanData.m_lJoinRequestUserList or {}

    -- 생성 콜백
    local function create_func(ui, data)

    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(1170, 120 + 5)
    table_view:setCellUIClass(UI_ClanAcceptListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)

    -- 리스트가 비었을 때
    table_view:makeDefaultEmptyDescLabel(Str('가입 요청이 없습니다.'))

    -- 정렬
end