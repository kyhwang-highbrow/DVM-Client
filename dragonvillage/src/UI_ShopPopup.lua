local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_ShopPopup
-------------------------------------
UI_ShopPopup = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ShopPopup:init()
    local vars = self:load('shop.ui')
    UIManager:open(self, UIManager.POPUP)
    
	-- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ShopPopup')
	
	-- @UI_ACTION
	self:doActionReset()
	self:doAction(nil, false)

	self:initUI()
	self:initTab()
	self:initButton()
	self:refresh()
end

-------------------------------------
-- function initParentVariable
-- @brief
-------------------------------------
function UI_ShopPopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ShopPopup'
    self.m_titleStr = Str('상점')
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ShopPopup:initUI()
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_ShopPopup:initTab()
    local vars = self.vars
    self:addTab(TableShop.GACHA, vars['drawBtn'], vars['drawNode'])
    self:addTab(TableShop.CASH, vars['cashBtn'], vars['cashNode'])
	self:addTab(TableShop.GOLD, vars['goldBtn'], vars['goldNode'])
	self:addTab(TableShop.STAMINA, vars['wingBtn'], vars['wingNode'])

    self:setTab(TableShop.GACHA)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ShopPopup:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ShopPopup:refresh()

end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_ShopPopup:onChangeTab(tab)
end

-------------------------------------
-- function initProductList
-- @brief
-------------------------------------
function UI_ShopPopup:initProductList()
    local table_shop = TABLE:get('shop')

    local l_pos = getSortPosList(260, #table_shop)

    for i,v in ipairs(table_shop) do
        local product_button = UI_ProductButton(self, i)
        self.root:addChild(product_button.root)

        local pos_x = l_pos[i]
        product_button.root:setPositionX(pos_x)
    end
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ShopPopup:click_exitBtn()
    self:close()
end

-------------------------------------
-- function openShopPopup
-- @brief 외부에서 함수통해 접근 할 때 사용
-------------------------------------
function openShopPopup()
    UI_ShopPopup()
end