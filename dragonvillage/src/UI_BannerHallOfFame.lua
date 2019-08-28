local PARENT = UI

-------------------------------------
-- class UI_BannerHallOfFame
-------------------------------------
UI_BannerHallOfFame = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_BannerHallOfFame:init()
    self.m_uiName = 'UI_BannerHallOfFame'
    local vars = self:load('lobby_banner_hall_of_fame.ui')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_BannerHallOfFame:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_BannerHallOfFame:initButton()
    local vars = self.vars
    vars['bannerBtn']:registerScriptTapHandler(function() self:click_bannerBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_BannerHallOfFame:refresh()
end


-------------------------------------
-- function click_bannerBtn
-------------------------------------
function UI_BannerHallOfFame:click_bannerBtn()
    -- @brief 명예의 전당으로 이동
    UINavigator:goTo('hell_of_fame')
end

--@CHECK
UI:checkCompileError(UI_BannerHallOfFame)
