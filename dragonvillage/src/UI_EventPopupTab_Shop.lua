local PARENT = UI

-------------------------------------
-- class UI_EventPopupTab_Shop
-------------------------------------
UI_EventPopupTab_Shop = class(PARENT,{
        m_structProduct = 'StructBannerData',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_Shop:init(struct_product)
    local vars = self:load('shop_package_popup_01.ui')
    self.m_structProduct = struct_product

    self:initUI()
	self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventPopupTab_Shop:initUI()
    local vars = self.vars
	local struct_product = self.m_structProduct

	-- 패키지 구성은 어떻게 할지 안정해져 임시로 아이콘 넣음
    local icon = struct_product:makePackageSprite()
    vars['packageNode']:addChild(icon)

	-- 가격
	local price = struct_product:getPriceStr()
    vars['priceLabel']:setString(price)

	-- 가격 아이콘
    local icon = struct_product:makePriceIcon()
    vars['priceNode']:addChild(icon)
	
	-- 가격 아이콘 및 라벨, 배경 조정
    UIHelper:makePriceNodeVariable(vars['priceBg'],  vars['priceNode'], vars['priceLabel'])
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventPopupTab_Shop:initButton()
	local vars = self.vars
    vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
	vars['closeBtn']:setVisible(false)
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_EventPopupTab_Shop:click_buyBtn()
	local struct_product = self.m_structProduct
	local function cb_func()
		local str = Str('구매 완료!')
		UI_ToastPopup(str)
	end
	struct_product:buy(cb_func)
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventPopupTab_Shop:onEnterTab()
    local vars = self.vars
end