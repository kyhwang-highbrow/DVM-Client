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
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventPopupTab_EventVote:initButton()
    local vars = self.vars
    --vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventPopupTab_EventVote:refresh()
    local vars = self.vars

--[[ 
    -- 모드별 입장권 획득 개수
    local stamina_info = event_data:getStaminaInfo()
    if (stamina_info) then
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
    end ]]


end
