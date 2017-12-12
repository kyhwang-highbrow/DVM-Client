local PARENT = UI

-------------------------------------
-- class UI_DailyMisson_Clan
-------------------------------------
UI_DailyMisson_Clan = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DailyMisson_Clan:init()
    local vars = self:load('event_clan_quest.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DailyMisson_Clan:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DailyMisson_Clan:initButton()
    local vars = self.vars
    --vars['closeBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DailyMisson_Clan:refresh()
    local vars = self.vars
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_DailyMisson_Clan:onEnterTab()
    self:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_DailyMisson_Clan:click_exitBtn()

end

--@CHECK
UI:checkCompileError(UI_DailyMisson_Clan)
