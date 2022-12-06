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

    if vars['loadingLabel'] then
        vars['loadingLabel']:setString('')
    end
end

-------------------------------------
-- function setLoadingMsg
-------------------------------------
function UI_NetworkLoading:setLoadingMsg(msg)
    if (msg == nil) then
        msg = ''
    end
    self.vars['loadingLabel']:setString(msg)
end

-------------------------------------
-- function ShowLoading
-------------------------------------
function ShowLoading(msg)
    if (not g_networkLoading) then
        g_networkLoading = UI_NetworkLoading()
    end

    g_networkLoading:setLoadingMsg(msg)
end

-------------------------------------
-- function HideLoading
-------------------------------------
function HideLoading()
    if g_networkLoading then
        g_networkLoading:close()
        g_networkLoading = nil
    end
end