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

    for idx, pid in ipairs(target_product) do
        local pid = tonumber(pid)
        local struct_product = l_item_list[pid]
        local item_label = vars['itemLabel'..idx]
        local desc_label = vars['dscLabel'..idx]

        if (item_label) then
            item_label:setString('')
        end

        if (desc_label) then
            desc_label:setString('')
        end

        -- 상품 정보가 없다면 구매제한을 넘겨 서버에서 준 정보가 없는 경우라 판단
        -- 월간 패키지, 주말 패키지는 구매제한 넘겨도 값을 주는데 다른 패키지는 주지 않음?
        if (not struct_product) then
            if (item_label) then
                item_label:setString(Str('구매 완료'))

                if (vars['priceNode'..idx]) then
                    vars['priceNode'..idx]:setVisible(false)
                end

                if (vars['buyLabel'..idx]) then
                    vars['buyLabel'..idx]:setVisible(false)
                end

                if (vars['priceLabel'..idx]) then
                    vars['priceLabel'..idx]:setVisible(false)
                end

                if (vars['buyBtn'..idx]) then
                    vars['buyBtn'..idx]:setVisible(false)
                end
            end
        else
            -- 구성품 t_desc 표시
            if (self.m_data['use_desc'] == 1) then
                local desc_str = struct_product['t_desc']
                if (desc_label) then
                    desc_label:setString(desc_str)
                end

            -- 구성품 mail_content 표시
            else
                local full_str = ServerData_Item:getPackageItemFullStr(struct_product['mail_content'])
                if (item_label) then
                    item_label:setString(full_str)
                end
            end

            -- 구매 제한
            local limit = struct_product:getMaxBuyTermStr()
            if (vars['buyLabel'..idx]) then
                vars['buyLabel'..idx]:setString(limit)
            end
        
	        -- 가격
	        local price = struct_product:getPriceStr()
            if (vars['priceLabel'..idx]) then
                vars['priceLabel'..idx]:setString(price)
            end
        
	        -- 가격 아이콘
            local icon = struct_product:makePriceIcon()
            if (vars['priceNode'..idx]) then
                vars['priceNode'..idx]:addChild(icon)
            end   

            -- 즉시 구매라면
            if (self.m_data['is_detail'] == 0) then
                vars['buyBtn'..idx]:registerScriptTapHandler(function() self:click_buyBtn(struct_product) end)
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

    if (struct_product) then
        local is_popup = true
        UI_Package(struct_product, is_popup)
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
