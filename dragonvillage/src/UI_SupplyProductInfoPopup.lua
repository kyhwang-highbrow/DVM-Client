local PARENT = UI

-------------------------------------
-- class UI_SupplyProductInfoPopup
-------------------------------------
UI_SupplyProductInfoPopup = class(PARENT,{
    m_supplyData = 'table',
    --{
    --    ['supply_id']=1004;
    --    ['period']=14;
    --    ['daily_content']='gold;1000000';
    --    ['t_name']='14일 골드 보급';
    --    ['product_content']='cash;1590';
    --    ['t_desc']='';
    --    ['type']='daily_gold';
    --    ['product_id']=120104;
    --    ['ui_priority']=40;
    --    ['period_option']=1;
    --}

    m_structProduct = 'StructProduct',
    m_buyCb = 'function',
})

-------------------------------------
-- class init
-------------------------------------
function UI_SupplyProductInfoPopup:init(data)
    local ui_name = 'supply_product_info_popup_' .. data['type'] .. '.ui'

    if (not checkUIFileExist(ui_name)) then
        ui_name = 'supply_product_info_popup.ui'
    end

    self:load(ui_name)
    UIManager:open(self, UIManager.POPUP)

    -- UI 클래스명 지정
    self.m_uiName = 'UI_SupplyProductInfoPopup'
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_SupplyProductInfoPopup')

    self.m_supplyData = data

    local pid = data['product_id']

    self.m_structProduct = g_shopData:getProduct('package', pid)

    self:initUI()
    self:initButton()
    self:refresh()
end


-------------------------------------
-- class initUI
-------------------------------------
function UI_SupplyProductInfoPopup:initUI()
    local vars = self.vars

    local t_data = self.m_supplyData

    -- 패키지 이름
    if vars['titleLabel'] and t_data['t_name'] and (t_data['t_name'] ~= '') then
        vars['titleLabel']:setString(Str(t_data['t_name']))
    end
    
    -- 다이아 즉시 획득량
    if vars['obtainLabel'] and t_data['product_content'] and (t_data['product_content'] ~= '') then
        local package_item_str = t_data['product_content']
        local count = ServerData_Item:getItemCountFromPackageItemString(package_item_str, ITEM_ID_CASH)
        vars['obtainLabel']:setString(Str('즉시 획득 {1}', comma_value(count)))
    end

    -- n일간 매일 수령
    if vars['periodLabel'] and t_data['period'] and (t_data['period'] ~= '') then
        local period = t_data['period']

        local original_string = vars['periodLabel']:getString()

        if (original_string ~= '') then
            vars['periodLabel']:setString(Str(original_string, period))
        end
    end


    -- 일간 보상 아이콘
    if vars['itemNode'] and t_data['daily_content'] and (t_data['daily_content'] ~= '') then
        local package_item_str = t_data['daily_content']
        local l_item_list_mail = ServerData_Item:parsePackageItemStr(package_item_str)
        if l_item_list_mail[1] then
            local t_item_data = l_item_list_mail[1]
            local item_id = t_item_data['item_id']
            local item_cnt = t_item_data['count']
            local card = UI_ItemCard(item_id, item_cnt)
            card.root:setSwallowTouch(false)
            vars['itemNode']:addChild(card.root)
        end
    end

    local struct_product = self.m_structProduct
    -- 상품 가격 표기
    local is_tag_attached = ServerData_IAP.getInstance():setGooglePlayPromotionSaleTag(self, struct_product, nil)
    local is_sale_price_written = false
    if (is_tag_attached == true) then
        is_sale_price_written = ServerData_IAP.getInstance():setGooglePlayPromotionPrice(self, struct_product, nil)
    end

    if (is_sale_price_written == false) and vars['priceLabel'] then
        vars['priceLabel']:setString(struct_product:getPriceStr())
    end -- // 상품 가격 표기
end

-------------------------------------
-- class initButton
-------------------------------------
function UI_SupplyProductInfoPopup:initButton()
    local vars = self.vars

    if vars['closeBtn'] then
        vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    end

    if vars['buyBtn'] then
        vars['buyBtn']:registerScriptTapHandler(function() 
            self.m_structProduct:buy(self.m_buyCb)
            self:close()
        end)
    end


end

-------------------------------------
-- class refresh
-------------------------------------
function UI_SupplyProductInfoPopup:refresh()
    
end

-------------------------------------
-- class refresh
-------------------------------------
function UI_SupplyProductInfoPopup:setBuyCallback(callback_func)
    self.m_buyCb = callback_func
end



--@CHECK
UI:checkCompileError(UI_SupplyProductInfoPopup)

