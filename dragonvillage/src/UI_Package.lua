local PARENT = UI

-------------------------------------
-- class UI_Package
-------------------------------------
UI_Package = class(PARENT, {
        m_structProduct = 'StructProduct',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_Package:init(struct_product)
    local vars = self:load('shop_package_popup_01.ui')
	UIManager:open(self, UIManager.POPUP)

	-- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_Package')

	-- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self.m_structProduct = struct_product

    self:initUI()
	self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Package:initUI()
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
function UI_Package:initButton()
	local vars = self.vars
    vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
	vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_Package:click_buyBtn()
	local struct_product = self.m_structProduct
	local function cb_func(ret)
		self:closeWithAction()

        -- 아이템 획득 결과창
        ItemObtainResult_Shop(ret)
	end
	struct_product:buy(cb_func)
end

-------------------------------------
-- function click_infoBtn
-------------------------------------
function UI_Package:click_infoBtn()
    cclog('## UI_Package:click_infoBtn()')
    local url = 'http://www.perplelab.com/agreement'
    --SDKManager:goToWeb(url)
    UI_WebView(url)
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_Package:click_closeBtn()
    self:closeWithAction()
end