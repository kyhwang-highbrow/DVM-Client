local PARENT = UI

-------------------------------------
-- class UI_DragonRunesGrindFirstPopup
-------------------------------------
UI_DragonRunesGrindFirstPopup = class(PARENT,{
        m_runeDesc = 'string',
        m_okCb = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonRunesGrindFirstPopup:init(rune_desc, ok_cb)
    local vars = self:load('rune_grind_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    self.m_okCb = ok_cb
    self.m_runeDesc = rune_desc
    
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DragonRunesGrindFirstPopup')

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
function UI_DragonRunesGrindFirstPopup:initUI()
    local vars = self.vars
    vars['sopt_label']:setString(self.m_runeDesc)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonRunesGrindFirstPopup:initButton()
    local vars = self.vars
    
    vars['okBtn']:registerScriptTapHandler(function() self:click_okay() end)
    vars['cancelBtn']:registerScriptTapHandler(function() self:close() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonRunesGrindFirstPopup:refresh()
end

-------------------------------------
-- function click_okay
-------------------------------------
function UI_DragonRunesGrindFirstPopup:click_okay()
    self:close()
    if (self.m_okCb) then
        self.m_okCb()
    end
end


--@CHECK
UI:checkCompileError(UI_DragonRunesGrindFirstPopup)
