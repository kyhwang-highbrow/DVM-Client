local PARENT = UI

-------------------------------------
-- class UI_EventMatchCardPlay
-------------------------------------
UI_EventMatchCardPlay = class(PARENT,{
        m_player = 'MatchCardPlayer',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventMatchCardPlay:init()
    local vars = self:load('event_match_card_game.ui')
    UIManager:open(self, UIManager.SCENE)

    self.m_uiName = 'UI_EventMatchCardPlay'

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventMatchCardPlay')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventMatchCardPlay:initUI()
    local vars = self.vars
    self.m_player = MatchCardPlayer()
    local l_cards_info = self.m_player.m_totalCards
    for i, struct_card in ipairs(l_cards_info) do
        local card_btn = vars['cardBtn'..i]
        if (card_btn) then
            card_btn:addChild(struct_card.m_node)
            card_btn:registerScriptTapHandler(function() self:click_cardBtn(card_btn, struct_card) end)
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventMatchCardPlay:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventMatchCardPlay:refresh()
end

-------------------------------------
-- function update
-- @brief
-------------------------------------
function UI_EventMatchCardPlay:update(dt)    
    local vars = self.vars
    if (self.m_player) then
        local play_cnt = self.m_player.m_playCount
        local str = Str('남은 기회 : {1}회', play_cnt)
        vars['playCountLabel']:setString(str)
    end
end

-------------------------------------
-- function click_cardBtn
-------------------------------------
function UI_EventMatchCardPlay:click_cardBtn(card_btn, struct_card)
    self.m_player:onClick(card_btn, struct_card)
end

--@CHECK
UI:checkCompileError(UI_EventMatchCardPlay)
