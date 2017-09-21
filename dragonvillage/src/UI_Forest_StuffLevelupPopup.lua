local PARENT = UI

-------------------------------------
-- class UI_Forest_StuffLevelupPopup
-------------------------------------
UI_Forest_StuffLevelupPopup = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Forest_StuffLevelupPopup:init(t_stuff_info)
    local vars = self:load('dragon_forest_levelup_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_Forest_StuffLevelupPopup')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Forest_StuffLevelupPopup:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Forest_StuffLevelupPopup:initButton()
    local vars = self.vars

    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    --vars['levelupBtn']:registerScriptTapHandler(function() self:click_levelupBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Forest_StuffLevelupPopup:refresh()
    local vars = self.vars

end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_Forest_StuffLevelupPopup:click_closeBtn()
    self:close()
end

-------------------------------------
-- function click_changeBtn
-------------------------------------
function UI_Forest_StuffLevelupPopup:click_changeBtn()
end
