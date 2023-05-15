local PARENT = UI

-------------------------------------
-- class UI_EventVoteRanking
-------------------------------------
UI_EventVoteRanking = class(PARENT,{
    m_rankList = 'table',
    m_voteSum = 'number',
    m_tableViewTD  = 'UIC_TableViewTD',
})

-------------------------------------
-- function init
-------------------------------------
function UI_EventVoteRanking:init(rank_list)
    self.m_rankList = clone(rank_list)
    local vars = self:load('event_vote_ticket_ranking.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventVoteRanking')

    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:initTableView()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventVoteRanking:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventVoteRanking:initTableView()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventVoteRanking:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['refreshBtn']:registerScriptTapHandler(function() self:click_refreshBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventVoteRanking:refresh()
    local vars = self.vars
    self.m_voteSum = 0
    
    -- 투표 갯수 합계
    for _, v in ipairs(self.m_rankList) do
        self.m_voteSum = self.m_voteSum + v['score']
    end

    -- 탑 랭킹 드래곤
    for i = 1, 5 do
        local t_data = table.remove(self.m_rankList, 1)
        local ui = UI_EventVoteRankingItem(t_data, self.m_voteSum)
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
    
        -- cell_size 지정
--[[         local item_scale = 0.52
        local cell_size = cc.size(80, 80) ]]
    
        local function make_func(data)
            local ui = UI_EventVoteRankingItem(data, self.m_voteSum)
            return ui
        end
    
        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(200, 70)
        table_view:setCellUIClass(make_func)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        table_view:setItemList(l_item_list)
    end

    do -- 몇번 투표했는지?
        vars['voteCountLabel']:setStringArg(g_eventVote:getMyVoteCount())
    end
end

-------------------------------------
-- function click_refreshBtn
-------------------------------------
function UI_EventVoteRanking:click_refreshBtn()
    if g_eventVote:isExpiredRankingUpdate() == true then
        local success_cb = function (ret)
            self.m_rankList = ret['rank_list'] or {}
            self:refresh()
        end

        g_eventVote:requestEventVoteGetRanking(success_cb)
    else
        UIManager:toastNotificationRed(Str('잠시 후에 다시 시도해주세요.'))
    end
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_EventVoteRanking:click_closeBtn()
    self:close()
end

-------------------------------------
-- function open
-------------------------------------
function UI_EventVoteRanking.open()
    if g_eventVote:isExpiredRankingUpdate() == true then
        local success_cb = function (ret)
            local ui = UI_EventVoteRanking(ret['rank_list'] or g_eventVote:getDragonRankList())
        end

        g_eventVote:requestEventVoteGetRanking(success_cb)
    else
        local rank_list = g_eventVote:getDragonRankList()
        local ui = UI_EventVoteRanking(rank_list)
    end
end