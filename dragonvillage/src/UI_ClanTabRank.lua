local PARENT = class(UI_IndivisualTab, ITabUI:getCloneTable())

-------------------------------------
-- class UI_ClanTabRank
-- @brief 클랜 랭킹 탭
-------------------------------------
UI_ClanTabRank = class(PARENT,{
        vars = '',
    })

UI_ClanTabRank.TAB_ANCT = 'ancient'
UI_ClanTabRank.TAB_CLSM = 'colosseum'

-------------------------------------
-- function init
-------------------------------------
function UI_ClanTabRank:init(owner_ui)
    self.root = owner_ui.vars['rankMenu']
    self.vars = owner_ui.vars
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_ClanTabRank:onEnterTab(first)
    if first then
        self:initUI()
        self:initTab()
    end
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_ClanTabRank:onExitTab()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanTabRank:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_ClanTabRank:initTab()
    local vars = self.vars
    local tab_list = {UI_ClanTabRank.TAB_ANCT, UI_ClanTabRank.TAB_CLSM}

    for i, tab in ipairs(tab_list) do
        self:addTabAuto(tab, vars, vars[tab .. 'Node'])
    end
    self:setTab(UI_ClanTabRank.TAB_ANCT)
	self:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_ClanTabRank:onChangeTab(tab, first)
    if (first) then 
        local rank_type = tab
        local offset = 1
        local cb_func = function()
            self:makeRankTableview(tab)
        end
        g_clanRankData:request_getRank(rank_type, offset, cb_func)
    end

    -- 내랭킹은 계속 교체한다
    self:makeMyRank(tab)
end

-------------------------------------
-- function makeTableViewRanking
-------------------------------------
function UI_ClanTabRank:makeRankTableview(tab)
	local t_tab_data = self.m_mTabData[tab]
	local node = t_tab_data['tab_node_list'][1]
	local l_rank_list = g_clanRankData:getRankData(tab)

	do -- 테이블 뷰 생성
        node:removeAllChildren()

        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(1000, 100 + 5)
        table_view:setCellUIClass(UI_ClanTabRank.makeRankCell, nil)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        table_view:setItemList(l_rank_list)

        --self.m_tableView = table_view
    end
end

-------------------------------------
-- function makeMyRank
-------------------------------------
function UI_ClanTabRank:makeMyRank(tab)
    local node = self.vars['myNode']
    local my_rank = g_clanRankData:getMyRankData(tab)
    local ui = self.makeRankCell(t_data)
    node:addChild(ui.root)
end

-------------------------------------
-- function makeRankCell
-------------------------------------
function UI_ClanTabRank.makeRankCell(t_data)
	local ui = class(UI, ITableViewCell:getCloneTable())()
	local vars = ui:load('clan_rank_item.ui')
    if (not t_data) then
        return ui
    end

    local struct_clan_rank = t_data

    -- 클랜 마크
    local icon = struct_clan_rank:makeClanMarkIcon()
    vars['markNode']:removeAllChildren()
    vars['markNode']:addChild(icon)

    -- 클랜 이름
    local clan_name = struct_clan_rank:getClanName()
    vars['clanLabel']:setString(clan_name)

    -- 클랜 마스터
    local clan_master = struct_clan_rank:getMasterNick()
    vars['masterLabel']:setString(clan_name)

    -- 점수
    local clan_score = struct_clan_rank:getClanScore()
    vars['scoreLabel']:setString(clan_score)
    
    -- 등수 
    local clan_rank = struct_clan_rank:getClanRank()
    vars['rankLabel']:setString(clan_rank)
    
	return ui
end