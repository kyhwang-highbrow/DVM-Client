local PARENT = UI

-------------------------------------
-- class UI_RuneForgeGachaTabInfoPopup
-------------------------------------
UI_RuneForgeGachaTabInfoPopup = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_RuneForgeGachaTabInfoPopup:init()
    local vars = self:load('rune_forge_gacha_info.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_RuneForgeGachaTabInfoPopup')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RuneForgeGachaTabInfoPopup:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RuneForgeGachaTabInfoPopup:initButton()
    local vars = self.vars

    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['okBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RuneForgeGachaTabInfoPopup:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_RuneForgeGachaTabInfoPopup:click_closeBtn()
    self:close()
end
