local PARENT = UI

----------------------------------------------------------------------
-- class UI_BannerDmgate
----------------------------------------------------------------------
UI_BannerDmgate = class(PARENT,{
})

----------------------------------------------------------------------
-- class init
----------------------------------------------------------------------
function UI_BannerDmgate:init()
    self.m_uiName = 'UI_BannerDmgate'
    local vars = self:load('lobby_banner_dmgate.ui')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end


----------------------------------------------------------------------
-- class initUI
----------------------------------------------------------------------
function UI_BannerDmgate:initUI()
end


----------------------------------------------------------------------
-- class initButton
----------------------------------------------------------------------
function UI_BannerDmgate:initButton()
    self.vars['bannerBtn']:registerScriptTapHandler(function() self:click_bannerBtn() end)
end


----------------------------------------------------------------------
-- class refresh
----------------------------------------------------------------------
function UI_BannerDmgate:refresh()
end

----------------------------------------------------------------------
-- class click_bannerBtn
----------------------------------------------------------------------
function UI_BannerDmgate:click_bannerBtn()
    if g_dimensionGateData:checkDmgateContentUnlocked() then
        UINavigator:goTo('dmgate')
    else
        UIManager:toastNotification('모험 : 지옥 12-7 스테이지 클리어가 필요합니다.', COLOR['purple'])
    end
end

-- @CHECK
UI:checkCompileError(UI_BannerDmgate)