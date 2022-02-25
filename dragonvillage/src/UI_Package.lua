local PARENT = UI

-------------------------------------
-- class UI_Package
-------------------------------------
UI_Package = class(PARENT, {
        m_package_name = 'string',
        m_structProduct = 'StructProduct',
        m_productList = 'List[StructProduct]',

        m_isPopup = 'boolean',
        m_isRefreshedDependency = 'boolean',

        m_cbBuy = 'function',
        m_obtainResultCloseCb = 'function',

        m_mailSelectType = 'MAIL_SELECT_TYPE',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_Package:init(struct_product_list, is_popup, package_name)
    if (not struct_product_list) 
        or (type(struct_product_list) ~= 'table') 
        or (#struct_product_list == 0) then
            return
    end
    self.m_package_name = package_name

    local struct_product = struct_product_list[1]

    if (not struct_product) then return end

    self.m_structProduct = struct_product

    local ui_name
    if is_popup and (struct_product['package_res_2']) and (struct_product['package_res_2'] ~= '') then
        ui_name = struct_product['package_res_2']
    else
        ui_name = struct_product['package_res']
    end

    if (not ui_name) then 
        return 
    end

    self.m_isPopup = is_popup or false
    self.m_isRefreshedDependency = false
	self.m_uiName = 'UI_Package'
    self.m_mailSelectType = MAIL_SELECT_TYPE.NONE

    local vars = self:load(ui_name)

    if (is_popup) then
        UIManager:open(self, UIManager.POPUP)
        -- 백키 지정
        g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_Package')
    end
    
    -- local struct_product = struct_product_list[2]

    -- if struct_product then
    --     local ui_name
    --     if is_popup and (struct_product['package_res_2']) and (struct_product['package_res_2'] ~= '') then
    --         ui_name = struct_product['package_res_2']
    --     else
    --         ui_name = struct_product['package_res']
    --     end
        
    --     self:load(ui_name)
    -- end
	
	-- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self.m_productList = struct_product_list
    

    self:initUI()
	self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Package:initUI()
    local vars = self.vars
    local struct_product = self.m_productList[1]

    -- 상품 이름
    if vars['titleLabel'] then
        local product_name = struct_product:getProductName()

        if product_name then
            vars['titleLabel']:setString(product_name)
        end
    end


end

-------------------------------------
-- function initEachProduct
-------------------------------------
function UI_Package:initEachProduct(index, struct_product)
    local vars = self.vars
    local node

    index = tostring(index)

    local item_list = ServerData_Item:parsePackageItemStr(struct_product['mail_content'])

    local is_multiple_item_labels = false
    for i = 1, #item_list do 
        local label = vars['itemLabel' .. i]
            
        if label and label:isVisible() then
            is_multiple_item_labels = true
        else
            is_multiple_item_labels = false
            break
        end
    end

    -- 번들인 경우
    if (#self.m_productList > 1) or (is_multiple_item_labels == false) then
        -- 상품 설명
        node = vars['itemLabel' .. index] or vars['itemLabel']
        if node then
            if (struct_product['use_desc'] == nil) or (struct_product['use_desc'] == '') then
                node:setString(struct_product:getItemNameWithCount())
            else
                node:setString(struct_product:getDesc())
            end
        end
    else
        for index, item in pairs(item_list) do
            local item_str = Str('{1} {2}개', TableItem():getItemName(item['item_id']), comma_value(item['count']))
            if vars['itemLabel' .. index] then
                vars['itemLabel' .. index]:setString(item_str)
            end
        end
    end

    -- 구매 제한
    node = vars['buyLabel' .. index] or vars['buyLabel']
    if node then
        local str = struct_product:getMaxBuyTermStr()
        -- 구매 가능/불가능 텍스트 컬러 변경
        local is_buy_all = struct_product:isBuyAll()
        local color_key = is_buy_all and '{@impossible}' or '{@available}'
        local rich_str = color_key .. str
        node:setString(rich_str)
        
        -- 구매 불가능할 경우 '구매완료' 출력
        node = vars['completeNode' .. index] or vars['completeNode']
        if node then
            node:setVisible(is_buy_all)
        end
    end

    -- 가격
    node = vars['priceLabel' .. index] or vars['priceLabel']
    if node then

        if (struct_product:getPrice() ~= 0) then
            local is_tag_attached = ServerData_IAP.getInstance():setGooglePlayPromotionSaleTag(self, index)
            local is_sale_price_written = false
            if (is_tag_attached == true) then
                is_sale_price_written = ServerData_IAP.getInstance():setGooglePlayPromotionPrice(self, struct_product, index)
            end

            if (is_sale_price_written == false) then
                vars['priceLabel']:setString(struct_product:getPriceStr())
            end
        else -- 상품이 무료인 경우 system font가 아닌 ttf font 적용
            node:setString('')

            node = vars['freeLabel' .. index] or vars['freeLabel']
            if node then
                node:setVisible(true)
            end
        end
    end

    -- 구매 버튼
    node = vars['buyBtn' .. index] or vars['buyBtn']
    if node then
        node:registerScriptTapHandler(function() self:click_buyBtn(tonumber(index)) end)
    end

    -- 재화 아이콘 버튼
    node = vars['priceNode' .. index] or vars['priceNode']
    if node then

    end

    -- 보너스 상품 (mail_content의 마지막 아이템)
    node = vars['itemNode' .. index] or vars['itemNode']
    if node and (vars['bonusNode' .. index] or vars['bonusNode']) then
        node:removeAllChildren()
        
        local item = item_list[#item_list]
        if item then
            local icon = IconHelper:getItemIcon(item['item_id'], item['count'])

            icon:setContentSize(node:getContentSize())
            node:addChild(icon)
        else
            node = vars['bonusNode' .. index] or vars['bonusNode']
            if node then
                node:setVisible(false)
            end
        end
    end

    -- 아이콘 노드
    node = vars['iconNode' .. index] or vars['iconNode']
    if node and (struct_product['icon'] ~= '') then
        node:removeAllChildren()

        local icon = struct_product:makeProductIcon()
        if icon then
            node:addChild(icon)
        end
    end

    
    -- 뱃지 아이콘 추가
    node = vars['badgeNode' .. index] or vars['badgeNode']
    if node then
        node:removeAllChildren()
        local badge_icon = struct_product:makeBadgeIcon()
        if badge_icon then
            node:addChild(badge_icon)
        end
    end
end


-------------------------------------
-- function refresh
-------------------------------------
function UI_Package:refresh()
    local vars = self.vars
	local struct_product = self.m_productList[1]

    if (not struct_product) then
        return
    end

    local is_noti_visible = false

    for index, struct_product in ipairs(self.m_productList) do 
        local purchased_num = g_shopDataNew:getBuyCount(struct_product:getProductID())
        local limit = struct_product:getMaxBuyCount()

        -- 특가 상품이 구매제한 초과 시 기존상품(dependency)으로 교체
        if purchased_num and limit and (purchased_num >= limit) 
            and (self.m_isRefreshedDependency) then
            local dependent_product_id = struct_product:getDependency()

            if dependent_product_id then
                struct_product = g_shopDataNew:getTargetProduct(dependent_product_id)
                
                self.m_productList[index] = struct_product
            end
        end

        self:initEachProduct(index, struct_product)

        is_noti_visible = (struct_product:getPrice() == 0) and (struct_product:isItBuyable())
    end

    if self.vars['notiSprite'] then 
        self.vars['notiSprite']:setVisible(is_noti_visible)
    end


    -- 판매 종료까지 남은 시간
    if vars['timeLabel'] then 
        local end_date = struct_product:getEndDateStr()

        if end_date then
            vars['timeLabel']:setString(end_date)
        else
            vars['timeLabel']:setString('')
        end
    end

    
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Package:initButton()
	local vars = self.vars
    
    local is_popup = self.m_isPopup
    -- 닫기 버튼
    if (vars['closeBtn']) then
        if (not is_popup) then
            vars['closeBtn']:setVisible(false)
        else
            vars['closeBtn']:setVisible(true)
	        vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
        end
    end

    -- 청약철회 버튼
    if vars['contractBtn'] then
        vars['contractBtn']:registerScriptTapHandler(function() self:click_contractBtn() end)
    end

    -- 바로가기 버튼
    if vars['quickBtn'] then
        if (not is_popup) then
            vars['quickBtn']:setVisible(true)
            vars['quickBtn']:registerScriptTapHandler(function() self:click_quickBtn() end)

            cca.pickMePickMe(vars['quickBtn'], 10)
        else
            vars['quickBtn']:setVisible(false)
        end
    end


    
    if (vars['buyBtn']) then
        vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
    end

	if (vars['rewardBtn']) then
		vars['rewardBtn']:registerScriptTapHandler(function() self:click_rewardBtn() end)
	end
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_Package:click_buyBtn(index)
	local struct_product = self.m_productList[index or 1]

	local function cb_func(ret)
        
        if struct_product:isContain('rune_box') then
            ItemObtainResult_ShowMailBox(ret, MAIL_SELECT_TYPE.RUNE_BOX, self.m_obtainResultCloseCb)
        else    
            
            local is_basic_goods_shown = false
            if self.m_package_name and (string.find(self.m_package_name, 'package_lucky_box')) then
                is_basic_goods_shown = true
            end

            if (self.m_mailSelectType ~= MAIL_SELECT_TYPE.NONE) then
                ItemObtainResult_ShowMailBox(ret, self.m_mailSelectType, self.m_obtainResultCloseCb)
            else
                -- 아이템 획득 결과창
                ItemObtainResult_Shop(ret, is_basic_goods_shown, self.m_obtainResultCloseCb)
            end
        end

        -- 갱신이 필요한 상태일 경우
        if ret['need_refresh'] then
            self:refresh()
            g_eventData.m_bDirty = true

        elseif (self.m_isPopup == true) then
            self:close()
		end

        
        if (self.m_cbBuy) then
            self.m_cbBuy(ret)
        end
	end

	struct_product:buy(cb_func)
end

-------------------------------------
-- function click_contractBtn
-------------------------------------
function UI_Package:click_contractBtn()
    GoToAgreeMentUrl()
end

-------------------------------------
-- function click_rewardBtn
-- @brief 보상 안내 = 상품 안내 팝업을 출력한다 rewardBtn 보다는 infoBtn이 적절했을듯
-- @comment 만원의 행복 용으로 추가됨. package_lucky_box.ui
-------------------------------------
function UI_Package:click_rewardBtn()
	local struct_product = self.m_productList[1]

    if (not struct_product) then
        return
    end

	-- 대상 package ui 이름에 _popup을 붙인 것으로 통일
    local ui_name = struct_product and struct_product['package_res']
	local reward_name = ui_name:gsub('.ui', '_popup.ui')

	-- 임시 ui 생성
	local ui = UI()
	ui:load(reward_name)
	UIManager:open(ui, UIManager.POPUP)
	g_currScene:pushBackKeyListener(ui, function() ui:close() end, 'UI_Package_Popup')
	ui.vars['closeBtn']:registerScriptTapHandler(function()
		ui:close()
	end)
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_Package:click_closeBtn()
    self:close()
end


-------------------------------------
-- function click_quickBtn
-------------------------------------
function UI_Package:click_quickBtn()
    if (self.m_package_name and string.find(self.m_package_name, 'rune')) then
        UINavigator:goTo('rune_forge', 'gacha')
    elseif (self.m_package_name == 'package_super_slime_swarm') then
        UINavigator:goTo('slime_combine')
    end
end

-------------------------------------
-- function setBuyCB
-------------------------------------
function UI_Package:setBuyCB(func)
    self.m_cbBuy = func
end


-------------------------------------
-- function setObtainResultCloseCb
-------------------------------------
function UI_Package:setObtainResultCloseCb(cb)
    self.m_obtainResultCloseCb = cb
end

-------------------------------------
-- function setRefreshDependency
-------------------------------------
function UI_Package:setRefreshDependency(is_refresh_dependency)
    self.m_isRefreshedDependency = is_refresh_dependency or true
end


-------------------------------------
-- function setMailSelectType
-------------------------------------
function UI_Package:setMailSelectType(type)
    if (type > MAIL_SELECT_TYPE.NONE) and (type <= MAIL_SELECT_TYPE.SUPER_SLIME) then
        self.m_mailSelectType = type
    end
end

