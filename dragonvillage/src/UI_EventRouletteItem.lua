local PARENT = UI

-------------------------------------
-- class UI_EventRouletteItem
-- @brief
-------------------------------------
UI_EventRouletteItem = class(PARENT, {
    m_index = 'number',
    m_receiveSprite = 'Animator',
})

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_EventRouletteItem:init(index)
    local vars = self:load('event_roulette_reward_item.ui')
    self.m_index = index
    self.m_receiveSprite = vars['receiveSprite']

    self:refresh()
end

----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_EventRouletteItem:refresh()
    self.vars['itemNode']:removeAllChildren()
    self.m_receiveSprite:setVisible(false)

    local count
    local icon 
    icon, count = g_eventRouletteData:getIcon(self.m_index)
    if (g_eventRouletteData:getCurrStep() == 1 and icon) then
        icon:setColor(cc.c3b(150, 150, 150))
    end

    --icon:setContentSize(self.vars['itemNode']:getContentSize())
    --icon:setContentSize(0.5)
    
    if (icon) then
        self.vars['itemNode']:addChild(icon)
        self.vars['itemLabel']:setString(tostring(count))
    end
end

----------------------------------------------------------------------
-- function setVisibleReceiveSprite
----------------------------------------------------------------------
function UI_EventRouletteItem:setVisibleReceiveSprite(isVisible)
    if (not isVisible) then isVisible = true end
    self.m_receiveSprite:setVisible(isVisible)
end