local PARENT = UI

-------------------------------------
-- class UI_DiceEvent
-------------------------------------
UI_DiceEvent = class(PARENT,{

    })

-------------------------------------
-- function init
-------------------------------------
function UI_DiceEvent:init()
    local vars = self:load('event_dice.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DiceEvent:initUI()
    local vars = self.vars
    
    -- cell list ����

    -- lab list ����
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DiceEvent:initButton()
    local vars = self.vars

end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DiceEvent:refresh()
    local vars = self.vars
    local dice_info = g_eventDiceData:getDiceInfo()

    -- �̺�Ʈ ���� �ð�
    vars['timeLabel']:setString(g_eventDiceData:getStatusText())

    do
        -- ����
        local state_desc = dice_info:getObtainingStateDesc('adv')
        vars['advLabel']:setString(state_desc)

        -- ����
        state_desc = dice_info:getObtainingStateDesc('dungeon')
        vars['dungeonLabel']:setString(state_desc)

        -- �ݷμ���
        state_desc = dice_info:getObtainingStateDesc('pvp')
        vars['pvpLabel']:setString(state_desc)

        -- Ž��
        state_desc = dice_info:getObtainingStateDesc('explore')
        vars['exploreLabel']:setString(state_desc)

        -- ��
        state_desc = dice_info:getObtainingStateDesc('total')
        vars['totalLabel']:setString(state_desc)
    end


end
