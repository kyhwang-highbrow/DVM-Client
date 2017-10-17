local PARENT = UI

-------------------------------------
-- class UI_ColosseumBuffInfoPopup
-------------------------------------
UI_ColosseumBuffInfoPopup = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ColosseumBuffInfoPopup:init()
    local vars = self:load('colosseum_scene_buff_info_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ColosseumBuffInfoPopup')

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
function UI_ColosseumBuffInfoPopup:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ColosseumBuffInfoPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ColosseumBuffInfoPopup:refresh()
end

--@CHECK
UI:checkCompileError(UI_ColosseumBuffInfoPopup)
