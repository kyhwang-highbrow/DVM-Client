local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_ColosseumRewardInfoPopup
-------------------------------------
UI_ColosseumRewardInfoPopup = class(PARENT,{
    })

UI_ColosseumRewardInfoPopup.RANK = 'rankReward'
UI_ColosseumRewardInfoPopup.MATCH = 'matchReward'
UI_ColosseumRewardInfoPopup.CLAN = 'clanReward'

-------------------------------------
-- function init
-------------------------------------
function UI_ColosseumRewardInfoPopup:init()
    local vars = self:load('colosseum_reward_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ColosseumRewardInfoPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ColosseumRewardInfoPopup:initUI()
    local vars = self.vars
    self:initTab()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ColosseumRewardInfoPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ColosseumRewardInfoPopup:refresh()
    local vars = self.vars
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_ColosseumRewardInfoPopup:initTab()
    local vars = self.vars
    self:addTabAuto(UI_ColosseumRewardInfoPopup.RANK, vars, vars['rankRewardNode'])
    self:addTabAuto(UI_ColosseumRewardInfoPopup.MATCH, vars, vars['matchRewardNode'])
    self:addTabAuto(UI_ColosseumRewardInfoPopup.CLAN, vars, vars['clanRewardNode'])

    self:setTab(UI_ColosseumRewardInfoPopup.RANK)
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_ColosseumRewardInfoPopup:onChangeTab(tab, first)
    PARENT.onChangeTab(self, tab, first)

    if (not first) then
        return
    end

    -- 주간 랭킹 보상
    if (tab == UI_ColosseumRewardInfoPopup.RANK) then
        self:init_tableViewRankReward()

    -- 매치 보상
    elseif (tab == UI_ColosseumRewardInfoPopup.MATCH) then
        self:init_tableViewMatchReward()

    -- 클랜 주간 랭킹 보상
    elseif (tab == UI_ColosseumRewardInfoPopup.CLAN) then
        self:init_clanRewardTableView()

    end
    
end

-------------------------------------
-- function init_tableViewRankReward
-- @brief 주간 랭킹 보상
-------------------------------------
function UI_ColosseumRewardInfoPopup:init_tableViewRankReward()
    local node = self.vars['rankRewardNode']
    node:removeAllChildren()

    -- 생성 콜백
    local function create_func(ui, data)
        
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cc.size(584 + 5, 134 + 5)
    table_view_td.m_nItemPerCell = 2
    table_view_td:setCellUIClass(UI_ColosseumRankRewardItem, create_func)
    table_view_td:makeDefaultEmptyDescLabel(Str(''))

    local l_item_list = self:getItemList()
    table_view_td:setItemList(l_item_list)

    self:sort(table_view_td.m_itemList)
end

-------------------------------------
-- function init_tableViewMatchReward
-- @brief 매치 보상
-------------------------------------
function UI_ColosseumRewardInfoPopup:init_tableViewMatchReward()
    local node = self.vars['matchRewardNode']
    node:removeAllChildren()

    -- 생성 콜백
    local function create_func(ui, data)
        
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cc.size(584 + 5, 134 + 5)
    table_view_td:setCellUIClass(UI_ColosseumMatchRewardItem, create_func)
    table_view_td:makeDefaultEmptyDescLabel(Str(''))

    local l_item_list = self:getItemList()
    table_view_td:setItemList(l_item_list)

    self:sort(table_view_td.m_itemList)
end

-------------------------------------
-- function init_clanRewardTableView
-------------------------------------
function UI_ColosseumRewardInfoPopup:init_clanRewardTableView()
    local node = self.vars['clanRewardNode']

    -- 고대의 탑 보상 정보만 빼온다.
    local l_item_list = {}
    for rank_id, t_data in pairs(TABLE:get('table_clan_reward')) do
        if (t_data['category'] == CLAN_RANK['CLSM']) then
            table.insert(l_item_list, t_data)
        end
    end

    -- 테이블 정렬
    table.sort(l_item_list, function(a, b) 
        return tonumber(a['rank_id']) < tonumber(b['rank_id'])
    end)

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(740, 90 + 5)
    table_view:setCellUIClass(UI_ColosseumClanRankRewardItem)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list or {})
end

-------------------------------------
-- function getItemList
-- @breif 티어별로 묶음 (세부 티어 리스트)
-------------------------------------
function UI_ColosseumRewardInfoPopup:getItemList()
    local table_colosseum = TABLE:get('table_colosseum')
    
    local l_ret = {}
    for i,v in pairs(table_colosseum) do
        local group = v['group']
        if (not l_ret[group]) then
            l_ret[group] = {}
            l_ret[group]['tier'] = group
            l_ret[group]['list'] = {}
        end

        table.insert(l_ret[group]['list'], v)
    end

    -- 내부 정렬
    local function sort_func(a, b)
        return a['tid'] < b['tid']
    end
    for _,v in pairs(l_ret) do
        table.sort(v['list'], sort_func)
    end

    return l_ret
end

-------------------------------------
-- function sort
-- @brief 티어별 정렬
-------------------------------------
function UI_ColosseumRewardInfoPopup:sort(target_list)
    local t_sort_idx = {}
    t_sort_idx['legend']   = 6
    t_sort_idx['master']   = 5
    t_sort_idx['diamond']  = 4
    t_sort_idx['gold']     = 3
    t_sort_idx['silver']   = 2
    t_sort_idx['bronze']   = 1
    t_sort_idx['beginner'] = 0

    local function sort_func(a, b)
        local a_tier = a['unique_id']
        local b_tier = b['unique_id']

        return t_sort_idx[a_tier] > t_sort_idx[b_tier]
    end

    table.sort(target_list, sort_func)
end

--@CHECK
UI:checkCompileError(UI_ColosseumRewardInfoPopup)
