local PARENT = UI

-------------------------------------
-- class UI_Package_SpotSale
-- @brief 깜짝 할인 상품 팝업
-------------------------------------
UI_Package_SpotSale = class(PARENT,{
        m_spotSaleID = 'number', -- table_spot_sale의 key id
        m_structProduct = 'StructProduct',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Package_SpotSale:init(spot_sale_id)
    self.m_spotSaleID = spot_sale_id

    local product_id = TableSpotSale:getProductID(spot_sale_id)
    self.m_structProduct = g_shopDataNew:getTargetProduct(tonumber(product_id))

    self.m_uiName = 'UI_Package_SpotSale'
    local vars = self:load('package_spot_sale.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_Package_SpotSale')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Package_SpotSale:initUI()
    local vars = self.vars

    local spot_sale_id = self.m_spotSaleID
    local ui_idx = TableSpotSale:getUIIdx(spot_sale_id)

    local ui_idx_list, max = TableSpotSale:getUIIdxList()
    max = math_max(max, 10)

    for i=1, max do
        if vars['stateLabel' .. i] then
            vars['stateLabel' .. i]:setVisible(i == ui_idx)
        end

        if vars['titleLabel' .. i] then
            vars['titleLabel' .. i]:setVisible(i == ui_idx)
        end
    end


    do -- 배경 생성
        local res = string.format('ui/package/bg_spot_sale_%.2d.png', ui_idx)
        local bg = cc.Sprite:create(res)
        if bg then
            bg:setDockPoint(cc.p(0.5, 0.5))
            bg:setAnchorPoint(cc.p(0.5, 0.5))
            vars['bgNode']:addChild(bg)
        end
    end

    local struct_product = self.m_structProduct

    -- 아이템명
    local product_name = Str(struct_product['t_name'])
    vars['itemLabel1']:setString(product_name)

    vars['itemLabel1']:setString(struct_product:getDesc())
    
    

    -- 가격
    local node = vars['priceLabel1'] or vars['priceLabel']
    if node then

        if (struct_product:getPrice() ~= 0) then
            local is_tag_attached = ServerData_IAP.getInstance():setGooglePlayPromotionSaleTag(self, struct_product, index)
            local is_sale_price_written = false
            if (is_tag_attached == true) then
                is_sale_price_written = ServerData_IAP.getInstance():setGooglePlayPromotionPrice(self, struct_product, index)
            end

            if (is_sale_price_written == false) then
                node:setString(struct_product:getPriceStr())
            end
        end
    end

    -- 남은 시간
    vars['timeLabel']:setString('')

    -- 보너스 표기
    local bonus_rate = TableSpotSale:getBonusRate(spot_sale_id)
    vars['bonusLabel']:setString(Str('보너스\n{1}%', bonus_rate))
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Package_SpotSale:initButton()
    local vars = self.vars
    if vars['closeBtn'] then
        vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    end

    vars['buyBtn1']:registerScriptTapHandler(function() self:click_buyBtn1() end)
    vars['buyBtn1']:setAutoShake(true)

    if (g_localData:isKoreaServer() or (g_localData:getLang() == 'ko')) then
        vars['contractBtn']:setVisible(true)
        vars['contractBtn']:registerScriptTapHandler(function() GoToAgreeMentUrl() end)
    else
        vars['contractBtn']:setVisible(false)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Package_SpotSale:refresh()
end

-------------------------------------
-- function click_buyBtn1
-- @brief 구매 버튼
-------------------------------------
function UI_Package_SpotSale:click_buyBtn1()
    local struct_product = self.m_structProduct

    local function cb_func(ret)

        -- 즉시 우편함을 띄우기 체크
        local mail_select = false
        if ret['items_list'] then

            -- 깜짝 상품은 단일 상품만 판매하는 것을 고려. 해당 타입 발견 시 즉시 break
            for i,v in pairs(ret['items_list']) do
                local item_id = v['item_id']
                -- 다이아
                if (item_id == ITEM_ID_CASH) then
                    UINavigator:goTo('mail_select', MAIL_SELECT_TYPE.GOODS)
                    mail_select = true
                    break

                -- 골드
                elseif (item_id == ITEM_ID_GOLD) then
                    UINavigator:goTo('mail_select', MAIL_SELECT_TYPE.GOODS)
                    mail_select = true
                    break

                -- 날개
                elseif (item_id == ITEM_ID_ST) then
                    UINavigator:goTo('mail_select', MAIL_SELECT_TYPE.STAMINA)
                    mail_select = true
                    break
                end
            end
        end

        -- 우편함을 즉시 띄우지 않았을 경우에만 실행
        if (not mail_select) then
            -- 아이템 획득 결과창
            ItemObtainResult_Shop(ret)
        end

        -- 구매 완료 후 팝업을 닫지 않고 "구매 완료"를 표시
        local vars = self.vars
        vars['buyBtn1']:setVisible(false)
        vars['completeNode1']:setVisible(true)
        --self:close()
    end
    local sub_msg = nil
    struct_product:buy(cb_func, sub_msg)
end

-------------------------------------
-- function update
-------------------------------------
function UI_Package_SpotSale:update(dt)
    local vars = self.vars

    local spot_sale_id = self.m_spotSaleID
    local end_of_sale_time = g_spotSaleData:getSpotSaleInfo_EndOfSaleTime(spot_sale_id) / 1000
    local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()
    local time = math_max(end_of_sale_time - curr_time, 0)
    local str = ''
    if (0 < time) then
        str = Str('판매 종료까지 {1} 남음', datetime.makeTimeDesc(time, true)) -- param : sec, showSeconds, firstOnly, timeOnly
    end
    vars['timeLabel']:setString(str)
end

--@CHECK
UI:checkCompileError(UI_Package_SpotSale)
