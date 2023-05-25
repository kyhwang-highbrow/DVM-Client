local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_EventVoteRankingResult
-------------------------------------
UI_EventVoteRankingResult = class(PARENT,{
    m_rankList = 'table',
})

-------------------------------------
-- function init
-------------------------------------
function UI_EventVoteRankingResult:init(rank_list)
    --self.m_rankList = clone(rank_list)
    local vars = self:load('event_popularity_result_ranking.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventVoteRankingResult')

    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initTab()
    self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventVoteRankingResult:initUI()
    local vars = self.vars

    local server_name = g_localData:getServerName()
    cclog('server_name', server_name)
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_EventVoteRankingResult:initTab()
    local vars = self.vars

    local tab_list = {'total','kr', 'global', 'us', 'asia', 'eu', 'jp'}
    
    for i,v in ipairs(tab_list) do
        local key = v
        --local btn = vars[string.format('%sTabBtn', v)]
        self:addTabAuto(key, vars)
    end
    
    self:setTab('total')
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_EventVoteRankingResult:onChangeTab(tab, first)
    local vars = self.vars

    self.m_rankList = clone(g_eventPopularityGacha:getRankList(tab))

    local server_map = {
        ['DEV'] = 'kr',
        ['QA'] = 'kr',
        ['Korea'] = 'kr',
        ['America'] = 'us',
        ['Asia'] = 'asia',
        ['Europe'] = 'eu',
        ['Japan'] = 'jp',
        ['Global'] = 'global',
    }

    local server_code = server_map[g_localData:getServerName()] or 'global'
    local btn = vars[string.format('%sTabBtn', server_code)]
    local pos = cc.p(btn:getPositionX() + 50, btn:getPositionY() + 20)

    vars['serverLabel']:setPosition(pos)

    self:refresh()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventVoteRankingResult:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventVoteRankingResult:refresh()
    local vars = self.vars
    local vote_sum = 0
    
    -- 투표 갯수 합계
    for _, v in ipairs(self.m_rankList) do
        vote_sum = vote_sum + v['score']
    end

    -- 탑 랭킹 드래곤
    for i = 1, 5 do
        local t_data = table.remove(self.m_rankList, 1)
        local ui = UI_EventVoteRankingItem(t_data, vote_sum)
        local str_key = string.format('dragonNode%d', i)

        if vars[str_key] ~= nil then
            vars[str_key]:removeAllChildren()
            vars[str_key]:addChild(ui.root)
        end
    end


    do -- 아래 드래곤
        local node = self.vars['totalRankListNode']
        node:removeAllChildren()
    
        local l_item_list = self.m_rankList
    
        local function make_func(data)
            local ui = UI_EventVoteRankingItem(data, vote_sum)
            return ui
        end
    
        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(200, 70)
        table_view:setCellUIClass(make_func)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        table_view:setCellCreateDirecting(-1)
        table_view:setItemList(l_item_list)
    end
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_EventVoteRankingResult:click_closeBtn()
    self:close()
end

-------------------------------------
-- function open
-------------------------------------
function UI_EventVoteRankingResult.open()
    local ui = UI_EventVoteRankingResult()
end