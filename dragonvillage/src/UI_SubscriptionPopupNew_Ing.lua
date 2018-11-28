local PARENT = UI

-------------------------------------
-- class UI_SubscriptionPopupNew_Ing
-------------------------------------
UI_SubscriptionPopupNew_Ing = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_SubscriptionPopupNew_Ing:init()
    local vars = self:load('package_daily_dia_reward_1.ui')
	UIManager:open(self, UIManager.POPUP)

	-- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_SubscriptionPopupNew_Ing')

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
function UI_SubscriptionPopupNew_Ing:initUI()
    local vars = self.vars

    local ingame_drop_info = g_subscriptionData:getIngameDropInfo()
    local play_cnt = ingame_drop_info['play_cnt']
    local cash_cnt = ingame_drop_info['cash']
    local gold_cnt = ingame_drop_info['gold']
    local amethyst_cnt = ingame_drop_info['amethyst']
    
    -- 플레이 횟수
    if (play_cnt) then
        vars['playLabel']:setString(Str('{1}회', comma_value(play_cnt)))
    end

    -- 캐시
    if (cash_cnt) then
        vars['itemLabel1']:setString(Str('{1}개', comma_value(cash_cnt)))
    end

    -- 골드
    if (gold_cnt) then
        vars['itemLabel2']:setString(Str('{1}개', comma_value(gold_cnt)))
    end

    -- 자수정
    if (amethyst_cnt) then
        vars['itemLabel3']:setString(Str('{1}개', comma_value(amethyst_cnt)))
    end

    -- 자동줍기 24시간 이용권 있는 경우 보유량 보여줌
    local auto_pick_item = g_userData:get('auto_root')
    if (auto_pick_item) and (auto_pick_item > 0) then
        local cnt = math_floor(auto_pick_item/24)
        vars['marbleLabel']:setString(Str('x{1}', cnt))
        vars['marbleBtn']:setVisible(true)
    end

    self:init_tableView()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SubscriptionPopupNew_Ing:initButton()
	local vars = self.vars
    vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
	vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['marbleBtn']:registerScriptTapHandler(function() self:click_marbleBtn() end)

    if vars['infoBtn'] then
        vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
    end

    -- 일일 획득량 설명 팝업
    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
end

-------------------------------------
-- function click_marbleBtn
-------------------------------------
function UI_SubscriptionPopupNew_Ing:click_marbleBtn()
    local auto_pick_item = g_userData:get('auto_root')
    if (auto_pick_item) and (auto_pick_item > 0) then
        local cnt = math_floor(auto_pick_item/24)

        local msg = Str('24시간 자동줍기 사용권 {1}개 보유중입니다.\n현재 적용중인 자동줍기 종료 후 사용할 수 있습니다.', cnt)
        local tool_tip = UI_Tooltip_Skill(70, -145, msg)

        -- 자동 위치 지정
        tool_tip:autoPositioning(self.vars['marbleBtn'])
    end
end

-------------------------------------
-- function click_infoBtn
-------------------------------------
function UI_SubscriptionPopupNew_Ing:click_infoBtn()
    GoToAgreeMentUrl()
end

-------------------------------------
-- function init_tableView
-------------------------------------
function UI_SubscriptionPopupNew_Ing:init_tableView()
    local vars = self.vars
    local node = vars['productNode']
    node:removeAllChildren()

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(474, 80+5)
    table_view:setCellUIClass(UI_SubscriptionDayListItemNew)
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
function UI_SubscriptionPopupNew_Ing:click_buyBtn()
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
function UI_SubscriptionPopupNew_Ing:request_RefreshSubscriptionInfo()
    local function cb_func()
        self:init_tableView()
		self:refresh()
    end

    local function fail_cb()
        self:close()
    end

    g_subscriptionData:request_subscriptionInfo(cb_func, fail_cb)
end

-------------------------------------
-- function click_infoBtn
-- @brief 일일 획득량 설명 팝업
-------------------------------------
function UI_SubscriptionPopupNew_Ing:click_infoBtn()
    local ui = UI()
    ui:load('package_daily_dia_info.ui')
    ui.vars['closeBtn']:registerScriptTapHandler(function() ui:close() end)
    UIManager:open(ui, UIManager.POPUP)

    -- backkey 지정
	g_currScene:pushBackKeyListener(ui, function() ui:close() end, 'temp')
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_SubscriptionPopupNew_Ing:click_closeBtn()
    self:close()
end

-------------------------------------
-- function getSubscribedInfo
-- @brief 구독 중인 상품 정보
-------------------------------------
function UI_SubscriptionPopupNew_Ing:getSubscribedInfo()
    return g_subscriptionData:getSubscribedInfo()
end

-------------------------------------
-- function refresh
-- @brief
-------------------------------------
function UI_SubscriptionPopupNew_Ing:refresh()
    local vars = self.vars
    local struct_product, base_product = g_subscriptionData:getAvailableProduct() -- StructProductSubscription
    local info = self:getSubscribedInfo() -- StructSubscribedInfo
    
    -- 남은 기간 출력
    local text = info:getRemainDaysText()
    vars['dayLabel']:setString(text)
    
    -- 구독 상품 남은기간 3일 이내면 노티 출력
    local is_auto_3day = g_autoItemPickData:checkSubsAlarm('subscription', 3) -- param : auto_type, day
    vars['notiSprite']:setVisible(is_auto_3day)
    
    -- 구매 가능
    if (struct_product) then
        -- 구매 회차 (구분할 수 있는 값이 pid 밖에 없음)
        local buy_cnt = tonumber(struct_product['product_id'])%10
        vars['purchaseLabel']:setString(Str('{1}회차 구매', buy_cnt))

        -- 가격
	    local price = struct_product:getPriceStr()
	    vars['priceLabel1']:setString(price)

    -- 구매 불가
    else
        vars['buyBtn']:setVisible(false)
    end
end