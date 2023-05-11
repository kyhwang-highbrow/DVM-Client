local PARENT = UI

-------------------------------------
-- class UI_EventPopupTab_EventVote
-------------------------------------
UI_EventPopupTab_EventVote = class(PARENT,{
    m_ownerUI = 'UI_EventPopup',
    m_structEventPopupTab = 'StructEventPopupTab',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_EventVote:init(ower_ui, struct_event_popup_tab)
    local vars = self:load('event_vote_ticket.ui')
    self.m_ownerUI = ower_ui
    self.m_structEventPopupTab = struct_event_popup_tab

    self:initUI()
	self:initButton()
    self:refresh()
    
    self.root:scheduleUpdateWithPriorityLua(function () self:update() end, 1)
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_EventPopupTab_EventVote:onEnterTab()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventPopupTab_EventVote:initUI()
    local vars = self.vars

    -- 남은 시간
    vars['timeLabel']:setString(g_eventVote:getStatusText())    
    
    -- 보상 정보
    local l_reward = g_eventVote:getRewardList()

    -- 정렬
    table.sort(l_reward, function(a, b) 
        return a['rate'] < b['rate']
    end)

    -- 뿌리기
    for i, v in ipairs(l_reward) do
        local id = v['item_id']
        local cnt = v['count']

        local item_card = UI_ItemCard(id, cnt)
        vars['itemNode' .. i]:addChild(item_card.root)
        item_card.root:setSwallowTouch(false)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventPopupTab_EventVote:initButton()
    local vars = self.vars
    vars['voteBtn']:registerScriptTapHandler(function() self:click_voteBtn() end)
    vars['rankingBtn']:registerScriptTapHandler(function() self:click_voteBtn() end)
end

-------------------------------------
-- function update
-------------------------------------
function UI_EventPopupTab_EventVote:update()
    local vars =  self.vars
    vars['timeLabel']:setString(g_eventVote:getStatusText())    
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventPopupTab_EventVote:refresh()
    local vars = self.vars

    -- 투표권 갯수
    do
        local vote_count = g_userData:get('event_vote_ticket')
        vars['ticketLabel']:setString(Str('{1}개', comma_value(vote_count)))
    end

    -- 모드별 입장권 획득 개수
    do
        local stamina_info = g_eventVote:getStaminaInfo()
        local total_ticket = 1 -- 하루에 한개는 충전되므로 1 default
        local max_total_ticket = 1
        for mode, data in pairs(stamina_info) do
            local curr_play = data['play'] or 0
            local max_play = data['max_play'] or 0

                vars[mode..'CntLabel']:setString(Str('({1}/{2})', curr_play, max_play))

            local curr_ticket = data['ticket'] or 0
            total_ticket = total_ticket + curr_ticket

            local max_ticket = data['max_ticket'] or 0
            max_total_ticket = max_total_ticket + max_ticket

            vars[mode..'TicketLabel']:setString(Str('(일일 최대 {1}/{2})', curr_ticket, max_ticket))
        end

        vars['totalTicketLabel']:setString(Str('(일일 최대 {1}/{2}개 획득 가능)', total_ticket, max_total_ticket))
    end

end

-------------------------------------
-- function click_voteBtn
-------------------------------------
function UI_EventPopupTab_EventVote:click_voteBtn()
    local ui = UI_EventVoteChoice.open()
    ui:setCloseCB(function () 
        self:refresh()
    end)
end

-------------------------------------
-- function click_rankBtn
-------------------------------------
function UI_EventPopupTab_EventVote:click_rankBtn()
    UI_EventVoteChoice.open()
end