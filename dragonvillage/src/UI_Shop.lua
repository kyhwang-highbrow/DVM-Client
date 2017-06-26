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

    self:addTabWidthTabUI('money', vars['moneyBtn'], UI_ShopTab(self, 'money'))
    self:addTabWidthTabUI('cash', vars['cashBtn'], UI_ShopTab(self, 'cash'))
    self:addTabWidthTabUI('amethyst', vars['amethystBtn'], UI_ShopTab(self, 'amethyst'))
    self:addTabWidthTabUI('topaz', vars['topazBtn'], UI_ShopTab(self, 'topaz'))
    self:addTabWidthTabUI('mileage', vars['mileageBtn'], UI_ShopTab(self, 'mileage'))
    self:addTabWidthTabUI('capsule', vars['capsuleBtn'], UI_ShopTab(self, 'capsule'))
    self:addTabWidthTabUI('honor', vars['honorBtn'], UI_ShopTab(self, 'honor'))
    self:addTabWidthTabUI('package', vars['packageBtn'], UI_ShopTab(self, 'package'))

    self:setTab('money')
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