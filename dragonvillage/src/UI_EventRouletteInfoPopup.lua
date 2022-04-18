-------------------------------------
-- class UI_EventRouletteInfoPopup
-- @brief
-------------------------------------
UI_EventRouletteInfoPopup = class(UI, {

})

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_EventRouletteInfoPopup:init()
    local vars = self:load('event_roulette_info_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventRouletteInfoPopup')    

    self.m_uiName = 'UI_EventRouletteInfoPopup'  

    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end