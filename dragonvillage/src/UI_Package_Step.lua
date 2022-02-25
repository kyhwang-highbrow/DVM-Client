local PARENT = UI_Package_Bundle

-------------------------------------
-- class UI_Package_Step
-------------------------------------
UI_Package_Step = class(PARENT,{
        m_curr_step = 'number',
        m_lStepPids = 'list',
    })


-------------------------------------
-- function init
-------------------------------------
function UI_Package_Step:init(package_name, is_popup)
    self.m_lStepPids = g_shopDataNew:getPakcageStepPidList('package_step')
    self:setCurrentStep()
    self:refresh(self.m_curr_step)

    -- @jhakim 2019.05.40 단계별 패키지 종료할 예정이라 날짜 상관없이 띄움
    self.vars['limitNode']:setVisible(true)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Package_Step:initButton()
    local vars = self.vars
    self.m_lStepPids = g_shopDataNew:getPakcageStepPidList('package_step')
    for idx = 1, #self.m_lStepPids do
        vars['stepBtn'..idx]:registerScriptTapHandler(function() self:click_stepBtn(idx) end)
        
    end
    vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
    vars['contractBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function setCurrentStep
-- @breif 구매내역으로 현재 스텝 체크
-------------------------------------
function UI_Package_Step:setCurrentStep()
    for idx, pid in ipairs(self.m_lStepPids) do
        local buy_cnt = g_shopDataNew:getBuyCount(pid)    
        if (buy_cnt == 0) then
            self.m_curr_step = idx
            break
        end
    end

    if (not self.m_curr_step) then
        self.m_curr_step = 1
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Package_Step:refresh(step)
    if (not step) then
        return
    end

    self:setCurrentStep()

    local vars = self.vars
    local l_item_list = g_shopDataNew:getProductList('package')

    for idx = 1, #self.m_lStepPids do
        vars['stepNode'..idx]:setVisible(idx == step)

        if (idx == step) then
            local target_pid = tonumber(self.m_lStepPids[idx])
            local struct_product = l_item_list[target_pid]

            -- 샵 정보가 없다면 구매 완료인 상태
            local is_buy = struct_product == nil
            vars['buyLabel']:setVisible(not is_buy)
            vars['buyBtn']:setVisible(not is_buy)
            vars['completeNode']:setVisible(is_buy)

            if (struct_product) then
                -- 가격
                local is_tag_attached = ServerData_IAP.getInstance():setGooglePlayPromotionSaleTag(self, struct_product, idx)
                local is_sale_price_written = false
                if (is_tag_attached == true) then
                    is_sale_price_written = ServerData_IAP.getInstance():setGooglePlayPromotionPrice(self, struct_product, idx)
                end

                if (is_sale_price_written == false) then
                    local label = vars['priceLabel' .. idx] or vars['priceLabel']
                    label:setString(struct_product:getPriceStr())
                end

                -- 구매 가능
                local buy_str = struct_product:getMaxBuyTermStr()

                -- 구매 가능/불가능 텍스트 컬러 변경
                local is_buy_all = struct_product:isBuyAll()
                local color_key = is_buy_all and '{@impossible}' or '{@available}'
                local rich_str = color_key .. buy_str
                vars['buyLabel']:setString(rich_str)

                -- 현재 단계보다 높으면 구매 불가
                vars['buyBtn']:setEnabled(self.m_curr_step >= idx)


                -- 상품은 여러개인데 마지막 상품 기준으로 남은 시간 출력
                local end_date = struct_product:getEndDateStr()
                if (vars['timeLabel']) then
                    vars['timeLabel']:setString(end_date)
                end
            end
        end
    end

    -- 구매 단계에 따라 전설드래곤 메세지 출력
    local str = ''
    if (step < #self.m_lStepPids) then
        str = Str('{1}단계 후 전설 드래곤 선택권 획득 가능!', #self.m_lStepPids - step)
    else
        str = Str('전설 드래곤 선택권 획득 가능!')
    end
    vars['infoLabel']:setString(str)


    -- 정보가 눈에 띄도록 흔들어줌
    local action = cca.buttonShakeAction(0.8, 1) -- shake_level, delay_time
    vars['infoNode']:stopAllActions()
    vars['infoNode']:runAction(action)

    -- 정보가 눈에 띄도록 흔들어줌 (전설 선택권 아이콘)
    local action = cca.buttonShakeAction(1, 1) -- shake_level, delay_time
    vars['iconSprite']:stopAllActions()
    vars['iconSprite']:runAction(action)
end

-------------------------------------
-- function click_stepBtn
-------------------------------------
function UI_Package_Step:click_stepBtn(step)
    self:refresh(step)
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_Package_Step:click_buyBtn()
    local l_item_list = g_shopDataNew:getProductList('package')
    local target_pid = self.m_lStepPids[self.m_curr_step]
    local struct_product = l_item_list[target_pid]

    if (struct_product) then
        local function cb_func(ret)
            if (self.m_cbBuy) then
                self.m_cbBuy(ret)
            end

            -- 아이템 획득 결과창
            ItemObtainResult_Shop(ret)

            -- 갱신이 필요한 상태일 경우
            if ret['need_refresh'] then
                self:setCurrentStep()
                self:refresh(self.m_curr_step)
                g_eventData.m_bDirty = true

            elseif (self.m_isPopup == true) then
                self:close()
		    end
	    end

	    struct_product:buy(cb_func)
    end
end