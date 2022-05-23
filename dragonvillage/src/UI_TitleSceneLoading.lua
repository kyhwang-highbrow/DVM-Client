local PARENT = UI

-------------------------------------
-- class UI_TitleSceneLoading
-------------------------------------
UI_TitleSceneLoading = class(PARENT,{
})

-------------------------------------
-- function init
-------------------------------------
function UI_TitleSceneLoading:init()
    local vars = self:load('network_loading.ui')
    UIManager:open(self, UIManager.LOADING)

    self.m_uiName = 'UI_TitleSceneLoading'

    -- 타이틀에서는 로딩 배경을 출력하지 않음
    vars['bgLayerColor']:setVisible(false)
end

-------------------------------------
-- function setLoadingMsg
-------------------------------------
function UI_TitleSceneLoading:setLoadingMsg(msg)
    self.vars['loadingLabel']:setString(msg)
end

-------------------------------------
-- function showLoading
-------------------------------------
function UI_TitleSceneLoading:showLoading(msg, only_msg)
    self.root:setVisible(true)
    self.vars['visual']:setVisible(not only_msg)
    if msg then
        self:setLoadingMsg(msg)
    end
end

-------------------------------------
-- function hideLoading
-------------------------------------
function UI_TitleSceneLoading:hideLoading()
    self.root:setVisible(false)
end

-------------------------------------
-- function onLoading
-------------------------------------
function UI_TitleSceneLoading:onLoading()
    return self.root:isVisible()
end