local PARENT = UI

-------------------------------------
-- class UI_ConfirmPopup
-------------------------------------
UI_ConfirmPopup = class(PARENT,{
		m_itemKey = '',
		m_itemValue = '',
        m_msg = 'string',
        m_cbOKBtn = 'function',
        m_cbCancelBtn = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ConfirmPopup:init(item_key, item_value, msg, ok_btn_cb, cancel_btn_cb)
	self.m_itemKey = item_key
	self.m_itemValue = item_value
    self.m_msg = msg
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
	vars['closeBtn']:registerScriptTapHandler(function() self:click_cancelBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ConfirmPopup:refresh()
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

	vars['titleLabel']:setString(self.m_msg or Str('다음 재화를 사용합니다.\n진행하시겠습니다?'))
	
	vars['priceLabel']:setString(comma_value(self.m_itemValue))

	local price_icon = self:getPriceIcon(self.m_itemKey)
	if (price_icon) then
		vars['iconNode']:addChild(price_icon)
	end
end

-------------------------------------
-- function click_backKey
-------------------------------------
function UI_ConfirmPopup:getPriceIcon(price_type)
    local res = nil

    if (price_type == 'x') then

    elseif (price_type == 'cash') then
        res = 'res/ui/icon/inbox/inbox_cash.png'

    elseif (price_type == 'gold') then
        res = 'res/ui/icon/inbox/inbox_gold.png'

    elseif (price_type == 'stamina_st') then
        res = 'res/ui/icon/inbox/inbox_staminas_st.png'

    elseif (price_type == 'money') then

    elseif (price_type == 'lactea') then
        res = 'res/ui/icon/inbox/inbox_lactea.png'

    elseif (price_type == 'amethyst') then
        res = 'res/ui/icon/inbox/inbox_amethyst.png'

    else
        error('price_type : ' .. price_type)
    end

	if (res) then
		local sprite = cc.Sprite:create(res)
		sprite:setDockPoint(cc.p(0.5, 0.5))
		sprite:setAnchorPoint(cc.p(0.5, 0.5))
		return sprite
	end

	return nil
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
