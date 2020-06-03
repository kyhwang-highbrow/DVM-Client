local PARENT = UI_IndivisualTab

-------------------------------------
-- class UI_ClanTabInfo
-- @brief 클랜 가입 탭
-------------------------------------
UI_ClanTabInfo = class(PARENT,{
        vars = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanTabInfo:init(owner_ui)
    self.root = owner_ui.vars['clanMenu']
    self.vars = owner_ui.vars
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_ClanTabInfo:onEnterTab(first)
    if first then
        self:initUI()
    end
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_ClanTabInfo:onExitTab()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanTabInfo:initUI()
    local vars = self.vars
    --self:init_TableView()
end

-------------------------------------
-- function init_TableView
-------------------------------------
function UI_ClanTabInfo:init_TableView()
    local node = self.vars['joinNode']
    --node:removeAllChildren()

    local l_item_list = g_clanData.m_lClanList

    --[[
    if (self.m_topRankOffset > 1) then
        local prev_data = {m_rank = 'prev'}
        l_item_list['prev'] = prev_data
    end

    if (#l_item_list > 0) then
        local next_data = {m_rank = 'next'}
        l_item_list['next'] = next_data
    end
    --]]

    -- 생성 콜백
    local function create_func(ui, data)
        --[[
        local function click_previousButton()
            self:update_topRankTableView(self.m_topRankOffset - 30)
        end
        ui.vars['previousButton']:registerScriptTapHandler(click_previousButton)

        local function click_nextButton()
            self:update_topRankTableView(self.m_topRankOffset + 30)
        end
        ui.vars['nextButton']:registerScriptTapHandler(click_nextButton)
        --]]
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(1170, 120 + 5)
    table_view:setCellUIClass(UI_ClanListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)

    -- 리스트가 비었을 때
    --table_view_td:makeDefaultEmptyDescLabel('')

    -- 정렬
    --g_colosseumRankData:sortColosseumRank(table_view.m_itemList)
    --self.m_topRankTableView = table_view
end

-------------------------------------
-- function update_tableView
-------------------------------------
function UI_ClanTabInfo:update_tableView(target_offset)
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