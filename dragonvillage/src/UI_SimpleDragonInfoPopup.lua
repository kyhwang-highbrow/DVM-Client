local PARENT = UI

-------------------------------------
-- class UI_SimpleDragonInfoPopup
-------------------------------------
UI_SimpleDragonInfoPopup = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_SimpleDragonInfoPopup:init()
    local vars = self:load('dragon_management_info_mini.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_SimpleDragonInfoPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    --self:doActionReset()
    --self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_SimpleDragonInfoPopup:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SimpleDragonInfoPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SimpleDragonInfoPopup:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_SimpleDragonInfoPopup:click_closeBtn()
    self:close()
end