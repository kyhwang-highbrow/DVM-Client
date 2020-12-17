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
    self.m_uiName = 'UI_ConfirmPopup'
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
    local vars = self.vars

    do -- 청약 철회 관련 안내문
        -- @sgkim 2020.12.17 UILoader에서 luaname이 contractBtn인 경우 한국어로 설정된 경우만 노출되도록 되어있음을 확인함. 아래는 관련 주석
        --     2018-03-21 klee 청약철회 문구가 국내법이라 국내 유저에게만 노출되어야함 (노출여부는 언어선택으로)
        --     모든 UI 파일 네이밍 검사한 결과 contractBtn은 상품쪽에서만 쓰이고 있고 앞으로도 상품쪽에서만 쓰기로 결정
        local is_money_product = (self.m_itemKey == 'money')
        vars['contractBtn']:setVisible(is_money_product)
        if (is_money_product == true) then
            vars['contractBtn']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
            vars['contractBtn']:registerScriptTapHandler(function() GoToAgreeMentUrl() end)        
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ConfirmPopup:initButton()
    local vars = self.vars

    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
    vars['cancelBtn']:registerScriptTapHandler(function() self:click_cancelBtn() end)
	vars['closeBtn']:registerScriptTapHandler(function() self:click_cancelBtn() end)
    vars['guestBtn']:registerScriptTapHandler(function() self:click_linkBtn() end)
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
function UI_ConfirmPopup:click_backKey()
    self:click_cancelBtn()
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_ConfirmPopup:click_okBtn()
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
function UI_ConfirmPopup:click_cancelBtn()
    if self.m_cbCancelBtn then
        self.m_cbCancelBtn()
    end

    self:close()
end

-------------------------------------
-- function click_linkBtn
-------------------------------------
function UI_ConfirmPopup:click_linkBtn()
    UI_LoginPopup2()
end

--@CHECK
UI:checkCompileError(UI_ConfirmPopup)
