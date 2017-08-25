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

                UI_ToastPopup(Str('우편으로 쿠폰이 발송되었습니다.'))
            end)
        end)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(920, 128 + 3)
    table_view:setCellUIClass(self.makeCellUI, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list, make_item)

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

    local node = vars['bannerNode']
    local content_size = node:getContentSize()
    local webview = ccexp.WebView:create()
    webview:setContentSize(content_size.width, content_size.height)
    webview:loadURL(url)
    webview:setBounces(false)
    webview:setAnchorPoint(cc.p(0,0))
    webview:setDockPoint(cc.p(0,0))
    node:addChild(webview)

    self.m_webView = webview
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventPopupTab_HBShop:onEnterTab()
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
        UI_EventPopupTab_HBShop_Coupon(coupon_list)
    end
    g_shopDataNew:request_couponList(cb_func)
end

-------------------------------------
-- function click_couponBtn
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