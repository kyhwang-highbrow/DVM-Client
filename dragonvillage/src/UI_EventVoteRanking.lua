local PARENT = UI

-------------------------------------
-- class UI_EventVoteRanking
-------------------------------------
UI_EventVoteRanking = class(PARENT,{
    m_rankList = 'table',
    m_tableViewTD  = 'UIC_TableViewTD',
})

-------------------------------------
-- function init
-------------------------------------
function UI_EventVoteRanking:init(rank_list)
    self.m_rankList = rank_list
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
    local node = self.vars['listNode']
    self.vars['listNode']:removeAllChildren()

    local l_item_list = g_eventVote:getDragonList()

	-- cell_size 지정
    local item_scale = 0.52
    local cell_size = cc.size(80, 80)

    -- 리스트 아이템 생성 콜백
    local function create_func(data)
        local did = data
		local t_data = {['evolution'] = 3, ['grade'] = 7}
        
        local card_ui = MakeSimpleDragonCard(did, t_data)
		card_ui.root:setScale(item_scale)

		-- 선택 클릭
		card_ui.vars['clickBtn']:registerScriptTapHandler(function() 
            local is_selelct_visible = self:click_selectBtn(did)
            card_ui:setCheckSpriteVisible(is_selelct_visible)
            self:refresh()
          end)

        return card_ui
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(node)
    table_view_td.m_cellSize = cell_size
    table_view_td.m_nItemPerCell = 11
	table_view_td:setCellUIClass(create_func)
	table_view_td:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view_td:setItemList(l_item_list)

    -- 정렬
    self.m_tableViewTD = table_view_td
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventVoteRanking:initButton()
    local vars = self.vars
    --vars['cancelBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    --vars['voteBtn']:registerScriptTapHandler(function() self:click_voteBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventVoteRanking:refresh()
    local vars = self.vars
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
            local ui = UI_EventVoteRanking(ret['rank_list'] or {})
        end

        g_eventVote:requestEventVoteGetRanking(success_cb)
    else
        local rank_list = g_eventVote:getDragonRankList()
        local ui = UI_EventVoteRanking(rank_list)
    end
end