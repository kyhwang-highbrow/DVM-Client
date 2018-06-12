local PARENT = UI_IndivisualTab

-------------------------------------
-- class UI_ClanGuestTabRequest
-- @brief 클랜 가입 탭
-------------------------------------
UI_ClanGuestTabRequest = class(PARENT,{
        vars = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanGuestTabRequest:init(owner_ui)
    self.root = owner_ui.vars['requestMenu']
    self.vars = owner_ui.vars
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_ClanGuestTabRequest:onEnterTab(first)
    self:init_TableView()
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_ClanGuestTabRequest:onExitTab()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanGuestTabRequest:initUI()
    local vars = self.vars
    self:init_TableView()
end

-------------------------------------
-- function init_TableView
-------------------------------------
function UI_ClanGuestTabRequest:init_TableView()
    local node = self.vars['requestNode']
    node:removeAllChildren()

    local l_item_list = g_clanData.m_lJoinRequestList

    -- 생성 콜백
    local function create_func(ui, data)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(1170, 110 + 10)
    table_view:setCellUIClass(UI_ClanListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)

    -- 리스트가 비었을 때
    table_view:makeDefaultEmptyDescLabel(Str('보낸 요청이 없습니다.'))

    -- 정렬
end