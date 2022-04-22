local PARENT = UI

-------------------------------------
-- class UI_EventPopupTab_HBShop
-------------------------------------
UI_EventPopupTab_HBShop = class(PARENT,{
        m_hbItemList = 'table',
        m_tableView = 'UIC_TableView',
        m_webView = 'ccexp.WebView',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_HBShop:init()
    local vars = self:load('event_capsule.ui')

    self.m_hbItemList = g_highbrowData:getHBItemList()

    self:initUI()
	self:initButton()
    self:refresh()

    g_topUserInfo:setSubCurrency('capsule')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventPopupTab_HBShop:initUI()
    local vars = self.vars
    self:init_tableView()
    self:init_bannerWebView()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventPopupTab_HBShop:initButton()
	local vars = self.vars
    vars['homepageBtn']:registerScriptTapHandler(function() self:click_homepageBtn() end)
    vars['couponBtn']:registerScriptTapHandler(function() self:click_couponBtn() end)
    vars['codeBtn']:registerScriptTapHandler(function() self:click_codeBtn() end)

    -- [쿠폰 입력] - ios 정책 강화로 ios에선 쿠폰 입력 버튼을 숨겨야 하는 경우가 있다.
    if (g_remoteConfig:hideCouponBtn() == true) then
        vars['couponBtn']:setVisible(false)
        vars['codeBtn']:setVisible(false)
    else
        vars['couponBtn']:setVisible(true)
        vars['codeBtn']:setVisible(true)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventPopupTab_HBShop:refresh()
	local vars = self.vars
end

-------------------------------------
-- function init_tableView
-------------------------------------
function UI_EventPopupTab_HBShop:init_tableView()
    local node = self.vars['itemNode']

    local l_item_list = self.m_hbItemList

    -- 생성 콜백
    local function create_func(ui, data)
        ui.vars['buyBtn']:registerScriptTapHandler(function()
            data:buyProduct(function() 
                self:refresh()
                self.refreshCell(ui, data)

                --UI_ToastPopup(Str('우편함으로 쿠폰이 발송되었습니다.'))
                UI_ToastPopup('쿠폰이 지급되었습니다. [보유 쿠폰]을 확인해주세요.')
            end)
        end)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(920, 128 + 3)
    table_view:setCellUIClass(self.makeCellUI, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)

    self.m_tableView = table_view
end

-------------------------------------
-- function init_bannerWebView
-------------------------------------
function UI_EventPopupTab_HBShop:init_bannerWebView()
    local vars = self.vars
       
    local url = g_highbrowData:getBannerUrl()
    
    -- url 없으면 실행안함
    if (not url) then
        return
    end
    -- window에 ccexp가 없음
    if isWin32() then
        return 
    end

    -- 배너 웹뷰 생성
    local node = vars['bannerNode']

    --[[
    -- @sgkim 2020.09.24 당분간 드빌 전용관에서 배너를 띄우지 않기로 함
    -- [DVM] 드빌 전용관 이슈 처리 2020.09.24(목) https://highbrow.atlassian.net/wiki/spaces/dvm/pages/645562422
    -- 웹뷰 생성
    local webview = CreateWebview(url, node)
    if (webview) then
        node:addChild(webview)
    end
    
    -- 배너 닫기 버튼 처리
    vars['bannerCloseBtn']:setVisible(true)
    vars['bannerCloseBtn']:registerScriptTapHandler(function()
        vars['bannerCloseBtn']:setVisible(false)
        self.m_webView:setVisible(false)
    end)

    self.m_webView = webview
    --]]
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventPopupTab_HBShop:onEnterTab()
    g_topUserInfo:setSubCurrency('capsule')

    -- 다른탭 갔다가 들어왔을때 웹뷰가 다시 나와서 처리
    if (not self.vars['bannerCloseBtn']:isVisible()) then
        if (self.m_webView) then
            self.m_webView:setVisible(false)
        end
    end
end

-------------------------------------
-- function click_homepageBtn
-------------------------------------
function UI_EventPopupTab_HBShop:click_homepageBtn()
    local highbrow_un = g_serverData:get('user','highbrow_un')
    local url = URL['HIGHBROW']  .. 'interop/Interop.php?uid=' .. tostring(highbrow_un)
    
    -- 구글 로그인 인증이 웹뷰를 통한 OAuth 인증을 허용하지 않으므로 브라우저로 처리
    --UI_WebView(url)
    SDKManager:goToWeb(url)
end

-------------------------------------
-- function click_couponBtn
-------------------------------------
function UI_EventPopupTab_HBShop:click_couponBtn()
    local function cb_func(coupon_list)
        if (self.m_webView) and (self.m_webView:isVisible()) then
            self.m_webView:setVisible(false)
        end

        local ui = UI_EventPopupTab_HBShop_Coupon(coupon_list)
        ui:setCloseCB(function()
            if (self.m_webView) and (self.vars['bannerCloseBtn']:isVisible()) then
                self.m_webView:setVisible(true)
            end
        end)
    end
    g_shopData:request_couponList(cb_func)
end

-------------------------------------
-- function click_codeBtn
-------------------------------------
function UI_EventPopupTab_HBShop:click_codeBtn()
    UI_CouponPopup('highbrow')
end

-------------------------------------
-- function makeCellUI
-- @static
-- @brief 테이블 셀 생성
-------------------------------------
function UI_EventPopupTab_HBShop.makeCellUI(struct_product)
	local ui = class(UI, ITableViewCell:getCloneTable())()
	local vars = ui:load('event_capsule_item.ui')

    -- 상품에 관한 정보
    vars['itemLabel']:setString(struct_product:getFullName())
    vars['dscLabel']:setString(struct_product:getDesc())

    local product_icon = struct_product:getIcon()
    vars['itemNode']:addChild(product_icon)

    -- refresh
    UI_EventPopupTab_HBShop.refreshCell(ui, struct_product)

	return ui
end

-------------------------------------
-- function refreshCell
-- @static
-- @brief 테이블 셀 갱신
-------------------------------------
function UI_EventPopupTab_HBShop.refreshCell(ui, struct_product)
    local vars = ui.vars
    
    -- 튜토리얼 보상은 1회만 수령 가능하므로 따로 처리
    if (struct_product:isDone()) then
        vars['completeNode']:setVisible(true)
        vars['buyBtn']:setEnabled(false)

    else
        local price = struct_product:getPrice()
        if (price == 0) then
            price = Str('무료')
        end
        vars['priceLabel']:setString(price)
    end
end