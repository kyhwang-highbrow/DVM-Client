local PARENT = UI

-------------------------------------
-- class UI_DragonRunesBulkEquipPopup
-------------------------------------
UI_DragonRunesBulkEquipPopup = class(PARENT, {
        m_lRuneList = 'list',
        m_price = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonRunesBulkEquipPopup:init(l_rune_list, price)
    local vars = self:load('dragon_rune_popup_confirm.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_cancelBtn() end, 'UI_DragonRunesBulkEquipPopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self.m_lRuneList = l_rune_list
    self.m_price = price

    self:initUI()

    self:initButton()

    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonRunesBulkEquipPopup:initUI()
    local vars = self.vars
    
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonRunesBulkEquipPopup:initButton()
    local vars = self.vars

    vars['cancelBtn']:registerScriptTapHandler(function() self:click_cancelBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonRunesBulkEquipPopup:refresh()
    local vars = self.vars
    
end

-------------------------------------
-- function click_cancelBtn
-------------------------------------
function UI_DragonRunesBulkEquipPopup:click_cancelBtn()
    self.m_closeCB = nil
    self:close()
end

