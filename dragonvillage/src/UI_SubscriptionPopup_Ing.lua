local PARENT = UI

-------------------------------------
-- class UI_SubscriptionPopup_Ing
-------------------------------------
UI_SubscriptionPopup_Ing = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_SubscriptionPopup_Ing:init()
    local vars = self:load('shop_package_daily_dia_02.ui')
	UIManager:open(self, UIManager.POPUP)

	-- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_SubscriptionPopup_Ing')

	-- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:refresh()
	self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_SubscriptionPopup_Ing:initUI()
    local vars = self.vars

    self:init_tableView()

    local info = self:getSubscribedInfo() -- StructSubscribedInfo

    -- 배경 이미지 출력
    local bg = info:makePopupBg()
    vars['packageNode']:addChild(bg)

    -- 남은 기간 출력
    local text = info:getRemainDaysText()
    vars['dayLabel']:setString(text)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SubscriptionPopup_Ing:initButton()
	local vars = self.vars
    vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
    --vars['buyBtn2']:registerScriptTapHandler(function() self:click_buyBtn(self.m_premiumProduct) end)
	vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function init_tableView
-------------------------------------
function UI_SubscriptionPopup_Ing:init_tableView()
    local node = self.vars['productNode']
    node:removeAllChildren()

    -- 리스트 아이템 생성 콜백
    local function create_func(ui, data)
        --ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_dragonCard(data['did']) end)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(526, 80+5)
    table_view:setCellUIClass(UI_SubscriptionDayListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    -- 리스트가 비었을 때
    table_view:makeDefaultEmptyDescLabel('')

    -- 재료로 사용 가능한 리스트를 얻어옴
    local struct_subscribed_info = self:getSubscribedInfo()
    local l_item_list = struct_subscribed_info:getDayRewardInfoList()
    table_view:setItemList(l_item_list)


    -- 오늘 날짜로 이동
    table_view:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
    local idx = struct_subscribed_info['cur_day']
    table_view:relocateContainerFromIndex(idx, true)
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_SubscriptionPopup_Ing:click_buyBtn()
    local struct_product = g_subscriptionData:getAvailableProduct()

    if (not struct_product) then
        return
    end

	local function cb_func(ret)
        -- 아이템 획득 결과창
        ItemObtainResult_Shop(ret)

        self:request_RefreshSubscriptionInfo()
	end
	struct_product:buy(cb_func)
end

-------------------------------------
-- function request_RefreshSubscriptionInfo
-------------------------------------
function UI_SubscriptionPopup_Ing:request_RefreshSubscriptionInfo()
    local function cb_func()
        self:init_tableView()
		self:refresh()
    end

    local function fail_cb()
        self:closeWithAction()
    end

    g_subscriptionData:request_subscriptionInfo(cb_func, fail_cb)
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_SubscriptionPopup_Ing:click_closeBtn()
    self:closeWithAction()
end


-------------------------------------
-- function getSubscribedInfo
-- @brief 구독 중인 상품 정보
-------------------------------------
function UI_SubscriptionPopup_Ing:getSubscribedInfo()
    return g_subscriptionData:getSubscribedInfo()
end

-------------------------------------
-- function refresh
-- @brief
-------------------------------------
function UI_SubscriptionPopup_Ing:refresh()
    local vars = self.vars
    local struct_product = g_subscriptionData:getAvailableProduct()

    if (not struct_product) then
        vars['buyBtn']:setVisible(false)
        return
    end
    vars['buyBtn']:setVisible(true)

    -- 가격
	local price = struct_product:getPriceStr()
    vars['priceLabel']:setString(price)

        -- 가격 아이콘
    local icon = struct_product:makePriceIcon()
    vars['priceNode']:removeAllChildren()
    vars['priceNode']:addChild(icon)

    -- 가격 아이콘 및 라벨, 배경 조정
    UIHelper:makePriceNodeVariable(vars['priceBg'],  vars['priceNode'], vars['priceLabel'])
end