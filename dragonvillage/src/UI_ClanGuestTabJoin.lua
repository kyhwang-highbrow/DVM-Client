local PARENT = UI_IndivisualTab

-------------------------------------
-- class UI_ClanGuestTabJoin
-- @brief 클랜 가입 탭
-------------------------------------
UI_ClanGuestTabJoin = class(PARENT,{
        vars = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanGuestTabJoin:init(owner_ui)
    self.root = owner_ui.vars['joinMenu']
    self.vars = owner_ui.vars
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_ClanGuestTabJoin:onEnterTab(first)
    if first then
        self:initUI()
    end

    self:init_TableView()
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_ClanGuestTabJoin:onExitTab()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanGuestTabJoin:initUI()
    local vars = self.vars

    vars['searchBtn']:registerScriptTapHandler(function() self:click_searchBtn() end)

    -- IOS maxlength 설정 안하면 입력 안됨
    vars['searchEditBox']:setMaxLength(10)
end

-------------------------------------
-- function init_TableView
-------------------------------------
function UI_ClanGuestTabJoin:init_TableView()
    local node = self.vars['joinNode']
    node:removeAllChildren()

    local l_item_list = {}
    -- 가입 신청이 가능한 클랜만 추출
    for i, struct_clan in pairs(g_clanData.m_lClanList) do
        if g_clanData:isCanJoinRequest(struct_clan) then
            l_item_list[i] = struct_clan
        end
    end

    -- 생성 콜백
    local function create_func(ui, data)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(1170, 110 + 6)
    table_view:setCellUIClass(UI_ClanListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)

    -- 리스트가 비었을 때
    table_view:makeDefaultEmptyDescLabel(Str('추천 클랜이 없습니다.'))

    -- 정렬
end

-------------------------------------
-- function update_tableView
-------------------------------------
function UI_ClanGuestTabJoin:update_tableView(target_offset)
    local function finish_cb(ret, rank_list)
        self.m_topRankOffset = ret['offset']

        if (1 < self.m_topRankOffset) then
            local prev_data = {m_rank = 'prev'}
            rank_list['prev'] = prev_data
        end

        local next_data = {m_rank = 'next'}
        rank_list['next'] = next_data

        self.m_topRankTableView:mergeItemList(rank_list)
        g_colosseumRankData:sortColosseumRank(self.m_topRankTableView.m_itemList)
    end

    g_colosseumRankData:request_rankManual(target_offset, finish_cb)
end

-------------------------------------
-- function click_searchBtn
-------------------------------------
function UI_ClanGuestTabJoin:click_searchBtn()
    local vars = self.vars
    local clan_name = vars['searchEditBox']:getText()

    if (clan_name == '') then
        MakeSimplePopup(POPUP_TYPE.OK, Str('검색할 클랜명을 입력하세요.'))
        return
    end

    g_clanData:requestClanInfoDetailPopup_byClanName(clan_name)
end
