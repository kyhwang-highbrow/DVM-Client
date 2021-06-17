local PARENT = UI

-------------------------------------
-- class UI_Package
-------------------------------------
UI_Package = class(PARENT, {
        m_structProduct = 'StructProduct',
        m_isPopup = 'boolean',
        m_cbBuy = 'function',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_Package:init(struct_product, is_popup)
    local ui_name = struct_product and struct_product['package_res']
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

    self.m_structProduct = struct_product

    self:initUI()
	self:initButton(is_popup)
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Package:initUI()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Package:refresh()
    local vars = self.vars
	local struct_product = self.m_structProduct

    if (not struct_product) then
        return
    end

    local l_item_list = ServerData_Item:parsePackageItemStr(struct_product['mail_content'])

    -- 성장 패키지는 개수만 표시
    local is_only_cnt = string.find(struct_product['sku'], 'growthpack')

    -- 구성품
    if (l_item_list) then
        for idx, data in ipairs(l_item_list) do
            
            local name = TableItem:getItemName(data['item_id'])
            local cnt = data['count']

            local str = (is_only_cnt) and Str('{1}개', comma_value(cnt)) or Str('{1}\n{2}개', name, comma_value(cnt))

            local label = vars['itemLabel'..idx]
            if (label) then
                label:setString(str)
            end
        end
    end

    if vars['iconNode'] and (struct_product['icon'] ~= '') then
        local icon = struct_product:makeProductIcon()
        if icon then
            vars['iconNode']:addChild(icon)
        end
    end

    if vars['itemLabel'] then
        vars['itemLabel']:setString(struct_product:getItemNameWithCount())
    end

    -- 구매 제한
    if vars['buyLabel'] then
        local str = struct_product:getMaxBuyTermStr()
        -- 구매 가능/불가능 텍스트 컬러 변경
        local is_buy_all = struct_product:isBuyAll()
        local color_key = is_buy_all and '{@impossible}' or '{@available}'
        local rich_str = color_key .. str
        vars['buyLabel']:setString(rich_str)
        
        -- 구매 불가능할 경우 '구매완료' 출력
        if (vars['completeNode']) then
            vars['completeNode']:setVisible(is_buy_all)
        end
    end
	
    -- 가격
    if vars['priceLabel'] then
	    local price = struct_product:getPriceStr()
        vars['priceLabel']:setString(price)
    end

    -- 판매종료시간 있는 경우 표시
    local time_label = vars['timeLabel']
    local end_date = struct_product:getEndDateStr()
    if (time_label) then
        if (end_date) then
            time_label:setString(end_date)
        else    
            time_label:setString('')
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Package:initButton(is_popup)
	local vars = self.vars
    if (vars['buyBtn']) then
        vars['buyBtn']:getParent():setSwallowTouch(false)
        vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
    end

    if (vars['closeBtn']) then
	    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    end

    if vars['contractBtn'] then
        vars['contractBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
    end
	if (vars['rewardBtn']) then
		vars['rewardBtn']:registerScriptTapHandler(function() self:click_rewardBtn() end)
	end
    if (not is_popup) then
        if (vars['closeBtn']) then
            vars['closeBtn']:setVisible(false)
        end
    end
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_Package:click_buyBtn()
	local struct_product = self.m_structProduct

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
function UI_Package:click_infoBtn()
    GoToAgreeMentUrl()
end

-------------------------------------
-- function click_rewardBtn
-- @brief 보상 안내 = 상품 안내 팝업을 출력한다 rewardBtn 보다는 infoBtn이 적절했을듯
-- @comment 만원의 행복 용으로 추가됨. package_lucky_box.ui
-------------------------------------
function UI_Package:click_rewardBtn()
	local struct_product = self.m_structProduct

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
-- function setBuyCB
-------------------------------------
function UI_Package:setBuyCB(func)
    self.m_cbBuy = func
end
