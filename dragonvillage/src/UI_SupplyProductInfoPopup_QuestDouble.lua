local PARENT = UI

-------------------------------------
-- class UI_SupplyProductInfoPopup_QuestDouble
-------------------------------------
UI_SupplyProductInfoPopup_QuestDouble = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_SupplyProductInfoPopup_QuestDouble:init()
    local vars = self:load('supply_product_info_popup_quest_double.ui')
    UIManager:open(self, UIManager.POPUP)


    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_SupplyProductInfoPopup_QuestDouble')

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
function UI_SupplyProductInfoPopup_QuestDouble:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SupplyProductInfoPopup_QuestDouble:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SupplyProductInfoPopup_QuestDouble:refresh()
end

-------------------------------------
-- function click_cancelBtn
-------------------------------------
function UI_SupplyProductInfoPopup_QuestDouble:click_closeBtn()
    self:close()
end

--@CHECK
UI:checkCompileError(UI_SupplyProductInfoPopup_QuestDouble)
