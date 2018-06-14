local PARENT = UI

-------------------------------------
-- class UI_NetworkLoading
-------------------------------------
UI_NetworkLoading = class(PARENT,{
})

-------------------------------------
-- function init
-------------------------------------
function UI_NetworkLoading:init()
    local vars = self:load('network_loading.ui')
    UIManager:open(self, UIManager.LOADING)
    
    self.m_uiName = 'UI_NetworkLoading'

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() end, 'UI_NetworkLoading')
end

-------------------------------------
-- function setLoadingMsg
-------------------------------------
function UI_NetworkLoading:setLoadingMsg(msg)
    self.vars['loadingLabel']:setString(msg)
end