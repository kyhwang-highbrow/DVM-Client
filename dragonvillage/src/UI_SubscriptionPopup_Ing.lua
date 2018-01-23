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
    local vars = self:load('package_daily_dia_reward.ui')
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

    -- 타이틀 이미지 출력
    local title = info:makePopupTitle()
    vars['titleNode']:addChild(title)

    -- 배경 이미지 출력
    local bg = info:makePopupBg()
    vars['packageNode']:addChild(bg)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SubscriptionPopup_Ing:initButton()
	local vars = self.vars
    vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
    --vars['buyBtn2']:registerScriptTapHandler(function() self:click_buyBtn(self.m_premiumProduct) end)
	vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)

    if vars['infoBtn'] then
        vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
    end
end

-------------------------------------
-- function click_infoBtn
-------------------------------------
function UI_SubscriptionPopup_Ing:click_infoBtn()
    local url = URL['PERPLELAB_AGREEMENT']
    --SDKManager:goToWeb(url)
    UI_WebView(url)
end

-------------------------------------
-- function init_tableView
-------------------------------------
function UI_SubscriptionPopup_Ing:init_tableView()
    local vars = self.vars
    vars['productNode']:removeAllChildren()
    vars['productNodeLong']:removeAllChildren()

    local node = nil
    -- 추가 할인 구매가 가능한 경우 버튼 영역을 확보
    if g_subscriptionData:getAvailableProduct() then
        node = vars['productNode']
    else
        node = vars['productNodeLong']
    end    

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
    table_view:relocateContainerFromIndex(idx, false)
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
    local struct_product, base_product = g_subscriptionData:getAvailableProduct() -- StructProductSubscription
    local info = self:getSubscribedInfo() -- StructSubscribedInfo

    -- 남은 기간 출력
    local text = info:getRemainDaysText()
    vars['dayLabel']:setString(text)

    if (not struct_product) then
        vars['buyMenu']:setVisible(false)
        return
    end
    vars['buyMenu']:setVisible(true)

    -- 가격
	local price = struct_product:getPriceStr()
    vars['priceLabel']:setString(price)

    do -- 할인율 표시
        local price = struct_product:getPrice()
        local base_price = base_product:getPrice()

        local percentage = math_floor((base_price - price) / base_price * 100)
        vars['saleLabel']:setString(Str('{1}%\n할인!', percentage))
    end
end