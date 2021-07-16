local PARENT = UI

-------------------------------------
-- class UI_Package
-------------------------------------
UI_Package = class(PARENT, {
        m_package_name = 'string',
        m_structProduct = 'StructProduct',
        m_productList = 'List[StructProduct]',
        m_isPopup = 'boolean',
        m_cbBuy = 'function',
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
	self.m_uiName = 'UI_Package'

    local vars = self:load(ui_name)
    if (is_popup) then
        UIManager:open(self, UIManager.POPUP)
        -- 백키 지정
        g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_Package')
    end
	
	-- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self.m_productList = struct_product_list

    self:initUI()
	self:initButton(is_popup)
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

    -- 상품 설명
    node = vars['itemLabel' .. index] or vars['itemLabel']
    if node then
        if (not struct_product['use_desc']) or (struct_product['use_desc'] == '') then
            node:setString(struct_product:getItemNameWithCount())
        else
            node:setString(struct_product:getDesc())
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
            node:setString(struct_product:getPriceStr())
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
        local icon = struct_product:makeProductIcon()
        if icon then
            node:addChild(icon)
        end
    end

    
    -- 뱃지 아이콘 추가
    node = vars['badgeNode' .. index] or vars['badgeNode']
    if node then
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
function UI_Package:initButton(is_popup)
	local vars = self.vars
    
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

function UI_Package:click_quickBtn()
    if (string.find(self.m_package_name, 'rune')) then
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



