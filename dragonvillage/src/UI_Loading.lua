local PARENT = UI

-------------------------------------
-- class UI_Loading
-------------------------------------
UI_Loading = class(PARENT,{
})

-------------------------------------
-- function init
-------------------------------------
function UI_Loading:init()
    self.m_uiName = 'UI_Loading'
    local vars = self:load('network_loading.ui')
    UIManager:open(self, UIManager.LOADING)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() end, 'UI_Loading')

    -- 로딩 배경을 출력하지 않음
    vars['bgLayerColor']:setVisible(false)

    if vars['loadingLabel'] then
        vars['loadingLabel']:setString('')
    end
end

-------------------------------------
-- function setLoadingMsg
-------------------------------------
function UI_Loading:setLoadingMsg(msg)
    self.vars['loadingLabel']:setString(msg)
end

-------------------------------------
-- function showLoading
-------------------------------------
function UI_Loading:showLoading(msg, only_msg)
    self.root:setVisible(true)
    self.vars['visual']:setVisible(not only_msg)
    if msg then
        self:setLoadingMsg(msg)
    end
end

-------------------------------------
-- function hideLoading
-------------------------------------
function UI_Loading:hideLoading()
    self.root:setVisible(false)
end

-------------------------------------
-- function onLoading
-------------------------------------
function UI_Loading:onLoading()
    return self.root:isVisible()
end

-------------------------------------
-- function close
-------------------------------------
function UI_Loading:close()
    if (not self.closed) then
        PARENT.close(self)
    end
end