local PARENT = UI

-------------------------------------
-- class UI_Forest_StuffListPopup
-------------------------------------
UI_Forest_StuffListPopup = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Forest_StuffListPopup:init()
    local vars = self:load('dragon_forest_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_Forest_StuffListPopup')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Forest_StuffListPopup:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Forest_StuffListPopup:initButton()
    local vars = self.vars

    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    --vars['levelupBtn']:registerScriptTapHandler(function() self:click_levelupBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Forest_StuffListPopup:refresh()
    local vars = self.vars

end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_Forest_StuffListPopup:click_closeBtn()
    self:close()
end

-------------------------------------
-- function click_changeBtn
-------------------------------------
function UI_Forest_StuffListPopup:click_changeBtn()
end
