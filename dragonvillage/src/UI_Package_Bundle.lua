local PARENT = UI

-------------------------------------
-- class UI_Package_Bundle
-------------------------------------
UI_Package_Bundle = class(PARENT,{
        m_isPopup = 'boolean',
        m_cbBuy = 'function',
        m_data = 'table',
        m_pids = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Package_Bundle:init(package_name, is_popup)
    local vars = self:load(string.format('%s.ui', package_name))
    self.m_data = TablePackageBundle:getDataWithName(package_name) 
    self.m_pids = TablePackageBundle:getPidsWithName(package_name) 
    self.m_isPopup = is_popup or false
	
	self.m_uiName = 'UI_Package_Bundle'

    if (is_popup) then
        UIManager:open(self, UIManager.POPUP)
        -- 백키 지정
        g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_Package_Bundle')
    end

    self:initUI()
	self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Package_Bundle:initUI()
    local vars = self.vars
    if (not self.m_isPopup) then
        vars['closeBtn']:setVisible(false)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Package_Bundle:initButton()
    local vars = self.vars
    local t_pids = self.m_pids

    -- 클릭시 패키지 상세 팝업이 뜨는 경우 (즉시 구매가 아닌 경우)
    if (self.m_data['is_detail'] == 1) then 
        for idx, pid in ipairs(t_pids) do
            local pid = tonumber(pid)
            vars['buyBtn'..idx]:registerScriptTapHandler(function() self:click_openShop(pid) end)
        end
    end

    -- 자세히 보기
    if (vars['contractBtn']) then
        vars['contractBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
    end

    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Package_Bundle:refresh()
    local vars = self.vars
    local l_item_list = g_shopDataNew:getProductList('package')
    local target_product = self.m_pids
    
    if (not target_product) then
        return
    end

    local function setLabelString(target_key, idx, str)
        if (vars[target_key..idx]) then
            vars[target_key..idx]:setString(str)

        -- 단일 패키지도 table_bundle_package에서 관리, UI 네이밍 예외 검사
        elseif (idx == 1) and (vars[target_key]) then
            vars[target_key]:setString(str)
        end
    end

    local function setNodeVisible(target_key, idx, visible)
        if (vars[target_key..idx]) then
            vars[target_key..idx]:setVisible(visible)

        -- 단일 패키지도 table_bundle_package에서 관리, UI 네이밍 예외 검사
        elseif (idx == 1) and (vars[target_key]) then
            vars[target_key]:setVisible(visible)
        end
    end

    for idx, pid in ipairs(target_product) do
        local pid = tonumber(pid)
        local struct_product = l_item_list[pid]

        setLabelString('itemLabel', idx, '')

        -- 상품 정보가 없다면 구매제한을 넘겨 서버에서 준 정보가 없는 경우라 판단
        -- 월간 패키지, 주말 패키지는 구매제한 넘겨도 값을 주는데 다른 패키지는 주지 않음?
        if (not struct_product) then
            setLabelString('itemLabel', idx, Str('구매 완료'))

            setNodeVisible('priceNode', idx, false)
            setNodeVisible('buyLabel', idx, false)
            setNodeVisible('priceLabel', idx, false)
            setNodeVisible('buyBtn', idx, false)
            setNodeVisible('completeNode', idx, true)
        else
            -- 판매종료시간 있는 경우 표시
            local time_label = vars['timeLabel']
            local end_date = struct_product:getEndDateStr()
            if (end_date) and (time_label) then
                time_label:setString(end_date)
            end 

            -- 구성품 t_desc 표시
            if (self.m_data['use_desc'] == 1) then
                local desc_str = struct_product['t_desc']
                setLabelString('itemLabel', idx, desc_str)

            -- 구성품 mail_content 표시
            else
                local full_str = ServerData_Item:getPackageItemFullStr(struct_product['mail_content'])
                setLabelString('itemLabel', idx, full_str)
            end

            -- 구매 제한
            local limit = struct_product:getMaxBuyTermStr()
            setLabelString('buyLabel', idx, limit)

	        -- 가격
	        local price = struct_product:getPriceStr()
            setLabelString('priceLabel', idx, price)
        
	        -- 가격 아이콘
            local icon = struct_product:makePriceIcon()
            if (vars['priceNode'..idx]) then
                vars['priceNode'..idx]:addChild(icon)

            elseif (idx == 1) and (vars['priceNode']) then   
                vars['priceNode']:addChild(icon)
            end

			-- 구매 완료 표시
			if (vars['completeNode' .. idx]) then
				vars['completeNode' .. idx]:setVisible(struct_product:isBuyAll())

			elseif (idx == 1) and (vars['completeNode']) then   
                vars['completeNode']:setVisible(struct_product:isBuyAll())
            end

            -- 즉시 구매라면
            if (self.m_data['is_detail'] == 0) then
                if (vars['buyBtn' .. idx]) then
				vars['buyBtn' .. idx]:registerScriptTapHandler(function() self:click_buyBtn(struct_product) end)

			    elseif (idx == 1) and (vars['buyBtn']) then   
                    vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn(struct_product) end)
                end
            end
        end
    end
end

-------------------------------------
-- function click_openShop
-------------------------------------
function UI_Package_Bundle:click_openShop(product_id)
    local l_item_list = g_shopDataNew:getProductList('package')
    local struct_product = l_item_list[product_id]

	-- 슬라임 패키지, 속성 패키지 등지에서 콜백이 물리지 않아 ui 갱신이 되지 않는다.
	-- 차후에 콜백 구조를 걷어내고 dirty나 옵저버? 형태로 가면 좋을듯 하다
    if (struct_product) then
        local is_popup = true
        local ui = UI_Package(struct_product, is_popup)
		ui:setBuyCB(self.m_cbBuy)
    end
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_Package_Bundle:click_buyBtn(struct_product)
	local function cb_func(ret)
        if (self.m_cbBuy) then
            self.m_cbBuy(ret)
        end

        -- 아이템 획득 결과창
        ItemObtainResult_Shop(ret)

        -- 갱신이 필요한 상태일 경우
        if ret['need_refresh'] then
            self:refresh()
            g_eventData.m_bDirty = true

        elseif (self.m_isPopup == true) then
            self:close()
		end
	end

	struct_product:buy(cb_func)
end

-------------------------------------
-- function click_infoBtn
-------------------------------------
function UI_Package_Bundle:click_infoBtn()
    local url = URL['PERPLELAB_AGREEMENT']
    UI_WebView(url)
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_Package_Bundle:click_closeBtn()
    self:close()
end

-------------------------------------
-- function setBuyCB
-------------------------------------
function UI_Package_Bundle:setBuyCB(func)
    self.m_cbBuy = func
end
