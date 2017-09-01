local PARENT = UI

-------------------------------------
-- class UI_Package_Monthly
-------------------------------------
UI_Package_Monthly = class(PARENT, {
        m_isPopup = 'boolean',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_Package_Monthly:init(is_popup)
    local vars = self:load('package_monthly.ui')
    self.m_isPopup = is_popup or false

	if (is_popup) then
        UIManager:open(self, UIManager.POPUP)
        -- 백키 지정
        g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_Package_Monthly')
    end

	-- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
	self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Package_Monthly:initUI()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Package_Monthly:refresh()
    local vars = self.vars
    local l_item_list = g_shopDataNew:getProductList('package')
    local target_product = {90007, 90008, 90009}

    for idx, pid in ipairs(target_product) do
        local struct_product = l_item_list[pid]

        -- 구성품
        local full_str = ServerData_Item:getPackageItemFullStr(struct_product['mail_content'])
        local label = vars['itemLabel'..idx]
        if (label) then
            label:setString(full_str)
        end

        -- 구매 제한
        local limit = struct_product:getMaxBuyTermStr()
        vars['buyLabel'..idx]:setString(limit)

	    -- 가격
	    local price = struct_product:getPriceStr()
        vars['priceLabel'..idx]:setString(price)

	    -- 가격 아이콘
        local icon = struct_product:makePriceIcon()
        vars['priceNode'..idx]:addChild(icon)

        vars['buyBtn'..idx]:registerScriptTapHandler(function() self:click_buyBtn(struct_product) end)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Package_Monthly:initButton()
	local vars = self.vars
	vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['contractBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)

    if (not self.m_isPopup) then
        vars['closeBtn']:setVisible(false)
    end
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_Package_Monthly:click_buyBtn(struct_product)
    local function refresh_cb()
        g_shopDataNew:request_shopInfo(function() self:refresh() end)
    end

	local function cb_func(ret)
        -- 팝업이면 바로 창닫음
        if (self.m_isPopup) then
            self:closeWithAction()
        
        -- 갱신되었으면 샵 인포 다시 호출
        elseif (g_shopDataNew:isDirty()) then
            refresh_cb()
        end

        -- 아이템 획득 결과창
        ItemObtainResult_Shop(ret)
	end

	struct_product:buy(cb_func)
end

-------------------------------------
-- function click_infoBtn
-------------------------------------
function UI_Package_Monthly:click_infoBtn()
    local url = URL['PERPLELAB_AGREEMENT']
    --SDKManager:goToWeb(url)
    UI_WebView(url)
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_Package_Monthly:click_closeBtn()
    self:closeWithAction()
end