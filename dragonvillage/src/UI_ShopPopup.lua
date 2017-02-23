local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_ShopPopup
-------------------------------------
UI_ShopPopup = class(PARENT, {
		m_tIsOpenOnce = 'bool',
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

	-- 멤버 변수 초기화 
	self.m_tIsOpenOnce = {}

	-- 초기화 함수 실행
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
    self:addTab(TableShop.CASH, vars['cashBtn'], vars['cashNode'])
	self:addTab(TableShop.GOLD, vars['goldBtn'], vars['goldNode'])
	self:addTab(TableShop.STAMINA, vars['staminaBtn'], vars['staminaNode'])
    self:addTab(TableShop.RECOMMEND, vars['recommendBtn'], vars['recommendNode'])
	self:addTab(TableShop.LIMIT, vars['limitBtn'], vars['limitNode'])
	self:addTab(TableShop.HONOR, vars['honorBtn'], vars['honorNode'])

    self:setTab(TableShop.CASH)
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
	local vars = self.vars
	local node = vars[tab .. 'Node']
	
	-- 최초 생성만 실행
	if (not self.m_tIsOpenOnce[tab]) then 
		self:makeQuestTableView(tab, node)
		self.m_tIsOpenOnce[tab] = true
	end
end

-------------------------------------
-- function makeQuestTableView
-------------------------------------
function UI_ShopPopup:makeQuestTableView(tab, node)
    local vars = self.vars

	-- product 타입에 따른 상품 뭉치
	local l_ProductList = g_shopData:getProductList(tab)

	-- cell size 분기 
	local cell_size = cc.size(270, 464)
	if (tab == TableShop.RECOMMEND) then
		cell_size = cc.size(370, 464)
	end

    do -- 테이블 뷰 생성
        node:removeAllChildren()

		-- 퀘스트 팝업 자체를 각 아이템이 가지기 위한 생성 콜백
		local create_cb_func = function(ui)
		end

        -- 테이블 뷰 인스턴스 생성
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cell_size
        table_view:setCellUIClass(UI_ShopListItem, create_cb_func)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
        table_view:setItemList(l_ProductList)
		table_view.m_bAlignCenterInInsufficient = true -- 리스트 내 개수 부족 시 가운데 정렬
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

-------------------------------------
-- function openShopPopup_cash
-- @brief 외부에서 함수통해 접근 할 때 사용
-------------------------------------
function openShopPopup_cash()
    UI_ShopPopup():setTab(TableShop.CASH)
end

-------------------------------------
-- function openShopPopup_gold
-- @brief 외부에서 함수통해 접근 할 때 사용
-------------------------------------
function openShopPopup_gold()
    UI_ShopPopup():setTab(TableShop.GOLD)
end

-------------------------------------
-- function openShopPopup_stamina
-- @brief 외부에서 함수통해 접근 할 때 사용
-------------------------------------
function openShopPopup_stamina()
    UI_ShopPopup():setTab(TableShop.STAMINA)
end