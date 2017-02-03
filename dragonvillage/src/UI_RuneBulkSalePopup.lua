local PARENT = UI

-------------------------------------
-- class UI_RuneBulkSalePopup
-------------------------------------
UI_RuneBulkSalePopup = class(PARENT,{
})

-------------------------------------
-- function init
-------------------------------------
function UI_RuneBulkSalePopup:init()
    local vars = self:load('inventory_sell_popup_02.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_RuneBulkSalePopup')

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
function UI_RuneBulkSalePopup:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RuneBulkSalePopup:initButton()
    local vars = self.vars
    vars['cancelBtn']:registerScriptTapHandler(function() self:click_cancelBtn() end)
    vars['sellBtn']:registerScriptTapHandler(function() self:click_sellBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RuneBulkSalePopup:refresh()
end

-------------------------------------
-- function click_cancelBtn
-- @brief "취소(닫기)" 버튼 클릭
-------------------------------------
function UI_RuneBulkSalePopup:click_cancelBtn()
end

-------------------------------------
-- function click_sellBtn
-- @brief "판매" 버튼 클릭
-------------------------------------
function UI_RuneBulkSalePopup:click_sellBtn()
end


--@CHECK
UI:checkCompileError(UI_RuneBulkSalePopup)
