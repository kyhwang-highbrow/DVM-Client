local PARENT = UI

-------------------------------------
---@class UI_SummonConfirmPopup
-------------------------------------
UI_SummonConfirmPopup = class(PARENT,{
		m_itemKey = '',
		m_itemValue = '',
        m_msg = 'string',
        m_cbOKBtn = 'function',
        m_cbCancelBtn = 'function',
        m_cbAdBtn = 'function'
    })

-------------------------------------
-- function init
-------------------------------------
function UI_SummonConfirmPopup:init(item_key, item_value, msg, ok_btn_cb, cancel_btn_cb, ad_btn_cb)
    self.m_uiName = 'UI_SummonConfirmPopup'
    self.m_resName = 'summon_confirm_popup.ui'

    self.m_itemKey = item_key
    self.m_itemValue = item_value
    self.m_msg = msg
    self.m_cbOKBtn = ok_btn_cb
    self.m_cbCancelBtn = cancel_btn_cb
    self.m_cbAdBtn = ad_btn_cb
end

-------------------------------------
-- function init_after
-------------------------------------
function UI_SummonConfirmPopup:init_after()
    local vars = self:load(self.m_resName)
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_backKey() end, self.m_uiName)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_SummonConfirmPopup:initUI()
    local vars = self.vars

end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SummonConfirmPopup:initButton()
    local vars = self.vars

    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
    vars['cancelBtn']:registerScriptTapHandler(function() self:click_cancelBtn() end)
	vars['closeBtn']:registerScriptTapHandler(function() self:click_cancelBtn() end)

    vars['adBtn']:registerScriptTapHandler(function() self:click_adBtn() end)
    local is_ad_btn_visible = isFunction(self.m_cbAdBtn)
    vars['adBtn']:setVisible(is_ad_btn_visible)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SummonConfirmPopup:refresh()
--[[
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
]]
	local vars = self.vars

	vars['titleLabel']:setString(self.m_msg or Str('다음 재화를 사용합니다.\n진행하시겠습니까?'))
	
    if (self.m_itemKey == 'money') then
        vars['moneyLabel']:setString(self.m_itemValue)
    else
        vars['priceLabel']:setString(comma_value(self.m_itemValue))
    end

	local price_icon = IconHelper:getPriceIcon(self.m_itemKey)
	if (price_icon) then
		vars['iconNode']:addChild(price_icon)
	end
end

-------------------------------------
-- function click_backKey
-------------------------------------
function UI_SummonConfirmPopup:click_backKey()
    self:click_cancelBtn()
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_SummonConfirmPopup:click_okBtn()
    if self.m_cbOKBtn then
        if self.m_cbOKBtn() then
            return
        end
    end

    self:close()
end

-------------------------------------
-- function click_cancelBtn
-------------------------------------
function UI_SummonConfirmPopup:click_cancelBtn()
    if self.m_cbCancelBtn then
        self.m_cbCancelBtn()
    end

    self:close()
end


-------------------------------------
-- function click_adBtn
-------------------------------------
function UI_SummonConfirmPopup:click_adBtn()
    if self.m_cbAdBtn then
        if self.m_cbAdBtn() then
            return
        end
    end

    self:close()
end


--@CHECK
UI:checkCompileError(UI_SummonConfirmPopup)
