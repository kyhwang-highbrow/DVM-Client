local PARENT = UI

-------------------------------------
-- class UI_ConfirmPopup
-------------------------------------
UI_ConfirmPopup = class(PARENT,{
		m_tCostTable = 'cost list',
        m_cbOKBtn = 'function',
        m_cbCancelBtn = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ConfirmPopup:init(cost_list, ok_btn_cb, cancel_btn_cb)
	self.m_tCostTable = cost_list
    self.m_cbOKBtn = ok_btn_cb
    self.m_cbCancelBtn = cancel_btn_cb

    local vars = self:load('popup_confirm.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_backKey() end, 'UI_ConfirmPopup')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ConfirmPopup:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ConfirmPopup:initButton()
    local vars = self.vars

    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
    vars['cancelBtn']:registerScriptTapHandler(function() self:click_cancelBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ConfirmPopup:refresh()
    local base_node = self.vars['costNode']
	local total_count = table.count(self.m_tCostTable)
	local count = 0

	for item_id, value in pairs(self.m_tCostTable) do 
		local item = UI_ItemCard(item_id, value)
		base_node:addChild(item.root)
		local pos_x = (75 * (1 - total_count)) + (150 * count)
		item.root:setPosition(pos_x, 0) 
		count = count + 1
	end
end

-------------------------------------
-- function click_backKey
-------------------------------------
function UI_ConfirmPopup:click_backKey()
    self:click_cancelBtn()
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_ConfirmPopup:click_okBtn()
    if self.m_cbOKBtn then
        self.m_cbOKBtn()
    end

    self:close()
end

-------------------------------------
-- function click_cancelBtn
-------------------------------------
function UI_ConfirmPopup:click_cancelBtn()
    if self.m_cbCancelBtn then
        self.m_cbCancelBtn()
    end

    self:close()
end

--@CHECK
UI:checkCompileError(UI_ConfirmPopup)
