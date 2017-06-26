local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_Shop
-------------------------------------
UI_Shop = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_Shop:init()
    local vars = self:load('shop_new.ui')
    UIManager:open(self, UIManager.SCENE)
    
	-- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_Shop')
	
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
function UI_Shop:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_Shop'
    self.m_titleStr = Str('상점')
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Shop:initUI()
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_Shop:initTab()
    local vars = self.vars

    local money_tab = UI_ShopMoneyTab(self)
    local cash_tab = UI_ShopCashTab(self)

    self:addTabWidthTabUI('money', vars['moneyBtn'], money_tab)       -- 다이아 상점
    self:addTabWidthTabUI('cash', vars['cashBtn'], cash_tab)       -- 다이아 상점

    self:setTab('money')
        --[[
    self:addTab(TableShop.CASH, vars['cashBtn'], vars['cashNode'])
	self:addTab(TableShop.GOLD, vars['goldBtn'], vars['goldNode'])
	self:addTab(TableShop.STAMINA, vars['staminaBtn'], vars['staminaNode'])
    self:addTab(TableShop.RECOMMEND, vars['recommendBtn'], vars['recommendNode'])
	self:addTab(TableShop.LIMIT, vars['limitBtn'], vars['limitNode'])
	self:addTab(TableShop.HONOR, vars['honorBtn'], vars['honorNode'])

    self:setTab(TableShop.CASH)
    --]]
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Shop:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Shop:refresh()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_Shop:click_exitBtn()
    self:close()
end