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

--local text_color = TableFriendship:getTextColorWithFlv(flv)

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
        local text = self.vars['conditionLabel']:getString()
        local text_color = self.vars['conditionLabel'].m_node:getTextColor()
        UIManager:toastNotification(text, text_color)
    end
end

-- @CHECK
UI:checkCompileError(UI_BannerDmgate)