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
    local vars = self:load('shop.ui')
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

    -- 하루 한번 일일상점 풀팝업 노출
    g_fullPopupManager:show(FULL_POPUP_TYPE.SHOP_DAILY)
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
    self.m_subCurrency = 'st'
    self.m_addSubCurrency = 'fp'
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
    local l_shop = {'st', 'gold',  'amethyst', 'topaz', 'mileage', 'honor', 'valor', 'clancoin'}
    for _, tab in pairs(l_shop) do
        self:addTabWithTabUIAuto(tab, vars, UI_ShopTab(self, tab))
    end
 
    self:setTab('st')
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Shop:initButton()
    self.vars['packageTabBtn']:registerScriptTapHandler(function() self:click_packageTabBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Shop:refresh()
	--self.vars['cashEventSprite']:setVisible(g_shopData:isExistCashSale())
end

-------------------------------------
-- function click_packageTabBtn
-------------------------------------
function UI_Shop:click_packageTabBtn()
    UINavigator:goTo('package_shop')
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_Shop:click_exitBtn()
    self:close()
end

-------------------------------------
-- function addTabWithTabUIAuto
-------------------------------------
function UI_Shop:addTabWithTabUIAuto(tab, vars, ui, ...)
    ui:setBuyCB(function(ret) self:buyResult(ret) end)
    return PARENT.addTabWithTabUIAuto(self, tab, vars, ui, ...)
end

-------------------------------------
-- function buyResult
-------------------------------------
function UI_Shop:buyResult(ret)
    if (not ret['need_refresh']) then
        return
    end

    -- 상점의 모든 테이블 뷰 삭제
    self.vars['tableViewNode']:removeAllChildren()

    -- 테이블 뷰 초기화
    for i,v in pairs(self.m_mTabData) do
        local ui = v['ui']
        if ui then
            ui:clearProductList()
        end
    end
	
	self:refresh()

    self:setTab(self.m_currTab, true)
end