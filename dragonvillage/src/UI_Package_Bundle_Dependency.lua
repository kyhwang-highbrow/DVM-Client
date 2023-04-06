local PARENT = UI_Package_Bundle

-------------------------------------
-- class UI_Package_Bundle_Dependency
-------------------------------------
UI_Package_Bundle_Dependency = class(PARENT,{
    })

-------------------------------------
-- function getProductList
-- @brief bundle형태는 package카테고리의 상품을 사용하다가 etc 카테고리 상품도 추가함
-------------------------------------
function UI_Package_Bundle_Dependency:getProductList()
    local packages = TABLE:get('table_package_bundle')
    local package_list = {}

    -- csv 파일의 하단에 오는 상품이 제일 위에 노출되도록 reverse order
    for index = #packages, 1, -1 do
        if packages[index]['t_name'] == self.m_package_name then
            local struct_product_group = StructPackageBundle(packages[index], false)
            local l_product = struct_product_group:getProductList()
--[[             table.sort(l_product, function(a, b) 
                return a.product_id < b.product_id
            end) ]]
            return l_product
        end
    end

    return {}
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Package_Bundle_Dependency:initUI()
    local vars = self.vars
end


-------------------------------------
-- function refresh
-------------------------------------
function UI_Package_Bundle_Dependency:refresh()
    local vars = self.vars
    local l_item_list = self:getProductList()
    cclog('l_item_list 갯수', #l_item_list)

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
        
    for idx, struct_product in ipairs(l_item_list) do
        setLabelString('itemLabel', idx, '')
        -- 상품 정보가 없다면 구매제한을 넘겨 서버에서 준 정보가 없는 경우라 판단
        -- 월간 패키지, 주말 패키지는 구매제한 넘겨도 값을 주는데 다른 패키지는 주지 않음?
        if (not struct_product) then
            setLabelString('itemLabel', idx, Str('구매 완료'))
            setNodeVisible('infoBtn', idx, false)
            setNodeVisible('priceNode', idx, false)
            setNodeVisible('buyLabel', idx, false)
            setNodeVisible('priceLabel', idx, false)
            setNodeVisible('buyBtn', idx, false)
            setNodeVisible('completeNode', idx, true)
        else
            -- 구성품 t_desc 표시
            if (self.m_data['use_desc'] == 1) then
                local desc_str = Str(struct_product['t_desc'])

                setLabelString('itemLabel', idx, desc_str)
            -- 구성품 mail_content 표시
            else
                local full_str = ServerData_Item:getPackageItemFullStr(struct_product['mail_content'], true)
                setLabelString('itemLabel', idx, full_str)
            end

            -- 가격
            local price = struct_product:getPriceStr()
            local is_tag_attached = ServerData_IAP.getInstance():setGooglePlayPromotionSaleTag(self, struct_product, idx)
            local is_sale_price_written = false
            if (is_tag_attached == true) then
                is_sale_price_written = ServerData_IAP.getInstance():setGooglePlayPromotionPrice(self, struct_product, idx)
            end

            if (is_sale_price_written == false) then
                setLabelString('priceLabel', idx, price)
            end
    
            -- 구매 제한
            if (TablePackageBundle:isSelectOnePackage(self.m_package_name) and not self.m_customStruct) then
                local is_buy = PackageManager:isBuyAll(self.m_package_name)
				if (is_buy) then
					vars['buyLabel']:setString('')
                else
					vars['buyLabel']:setString('{@available}' .. Str('구매 가능'))
                end

                -- 구매 완료 표시
                vars['completeNode']:setVisible(is_buy)    
                vars['buyBtn']:setEnabled(not is_buy)
            else
                -- 구매 가능/불가능 텍스트 컬러 변경
                local str = struct_product:getMaxBuyTermStr()
                local is_buy_all = struct_product:isBuyAll()
                local color_key = is_buy_all and '{@impossible}' or '{@available}'
                local rich_str = color_key .. str
                setLabelString('buyLabel', idx, rich_str)

                -- 구매 완료 표시
                if (vars['completeNode' .. idx]) then
                    vars['completeNode' .. idx]:setVisible(struct_product:isBuyAll())
    
                elseif (idx == 1) and (vars['completeNode']) then   
                    vars['completeNode']:setVisible(struct_product:isBuyAll())    
                end
            end

            -- 즉시 구매라면
            if (self.m_data['is_detail'] == 0) then
                if (vars['buyBtn' .. idx]) then
				vars['buyBtn' .. idx]:registerScriptTapHandler(function() self:click_buyBtn(struct_product) end)

			    elseif (idx == 1) and (vars['buyBtn']) then   
                    vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn(struct_product) end)
                end
            end

            -- 돋보기 정보가 필요하면
            if struct_product:isNeedProductInfo() == true then
                setNodeVisible('infoBtn', idx, true)
            end
            
            do -- 뱃지 노출 처리
                local str_badge = 'badgeNode' .. idx
                if vars[str_badge] ~= nil then
                    local badge = struct_product:makeBadgeIcon()
                    if (badge) then
                        vars[str_badge]:removeAllChildren()
                        vars[str_badge]:addChild(badge)
                    end
                end
            end

        end
    end

    -- 판매 종료 시간
    self:refresh_time()
end