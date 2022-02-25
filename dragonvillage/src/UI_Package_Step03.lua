local PARENT = UI_Package_Bundle

local BUTTON_STATE = {}
BUTTON_STATE.NORMAL = 'normal'
BUTTON_STATE.SELECT = 'selected'
BUTTON_STATE.SOLDOUT = 'soldout'
BUTTON_STATE.SOLDOUT_SELECT = 'soldout_selected'

-------------------------------------
-- class UI_Package_Step03
-------------------------------------
UI_Package_Step03 = class(PARENT,{
        m_curr_step = 'number',
        m_lStepPids = 'list',
        m_pacakgeName = 'string',
        m_isAllSoldOut = 'boolean',
    })


-------------------------------------
-- function init
-------------------------------------
function UI_Package_Step03:init(package_name, is_popup)
    self.m_pacakgeName = package_name
    self.m_lStepPids = g_shopDataNew:getPakcageStepPidList(self.m_pacakgeName)
    self:initStep(package_name)
end

-------------------------------------
-- function initStep
-------------------------------------
function UI_Package_Step03:initStep(package_name)
    local vars = self.vars
    for idx = 1, #self.m_lStepPids do
        vars['stepBtn'..idx]:registerScriptTapHandler(function() self:click_stepBtn(idx) end)       
    end
    
    self:setCurrentStep()
    self:refresh(self.m_curr_step)

    -- 종료 임박 출력(하드코딩)
    if vars['limitNode'] then
        vars['limitNode']:setVisible(false)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Package_Step03:initButton()
    local vars = self.vars
    
    vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
    vars['contractBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)

    if (vars['infoBtn']) then
        vars['infoBtn']:registerScriptTapHandler(function()   
            local msg1 = Str("'미중복' 알은") .. '\n' .. Str('도감을 기준으로 수집한 적이 없는 드래곤 중 하나를 무작위로 획득합니다.')
            local msg2 = Str('모든 드래곤을 수집했을 경우에는 사용할 수 없습니다.') .. '\n' .. Str('신규 드래곤이 추가 되면 다시 사용할 수 있습니다.')
            MakeSimplePopup2(POPUP_TYPE.OK, msg1, msg2)
        end)
    end
end

-------------------------------------
-- function setCurrentStep
-- @breif 구매내역으로 현재 스텝 체크
-------------------------------------
function UI_Package_Step03:setCurrentStep()
    local sum_buy_cnt = 0
    for idx, pid in ipairs(self.m_lStepPids) do
        local buy_cnt = g_shopDataNew:getBuyCount(pid)
        if (buy_cnt == 0) then
            self.m_curr_step = idx
            break
        end
        sum_buy_cnt = sum_buy_cnt + buy_cnt
    end

    -- 단계별 상품은 한 번씩만 살 수 있는 상태
    -- 상품 갯수와 구매횟수가 같다면 모두 구매했다고 판단
    if (sum_buy_cnt == #self.m_lStepPids) then
        self.m_isAllSoldOut = true
    end

    if (not self.m_curr_step) then
        self.m_curr_step = 1
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Package_Step03:refresh(step)
    if (not step) then
        return
    end

    self:setCurrentStep()

    local vars = self.vars
    if (vars['timeLabel']) then
		vars['timeLabel']:setString('') -- 타임 라벨 초기화
	end    
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
                local is_tag_attached = ServerData_IAP.getInstance():setGooglePlayPromotionSaleTag(self, idx)
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

    self:setLastRewardLabel(step)

    do -- 정보가 눈에 띄도록 흔들어줌
        local node = vars['infoNode']
        if node then
            local action = cca.buttonShakeAction(0.8, 1) -- shake_level, delay_time
            node:stopAllActions()
            node:runAction(action)
        end
    end

    do -- 정보가 눈에 띄도록 흔들어줌 (전설 선택권 아이콘)
        local node = vars['iconSprite']
        if node then
            local action = cca.buttonShakeAction(1, 1) -- shake_level, delay_time
            node:stopAllActions()
            node:runAction(action)
        end
    end

    -- 구매 완료된 상품에 노티
    self:setNoti()

    -- 버튼 상태 갱신
    self:setBuutonState(step) -- 클릭한 스텝
end

-------------------------------------
-- function setLastRewardLabel
-------------------------------------
function UI_Package_Step03:setLastRewardLabel(step)
    local vars= self.vars
    
    vars['infoLabel']:setString('')

    -- 구매 단계에 따라 전설드래곤 메세지 출력
    local str = ''
    local l_item_list = g_shopDataNew:getProductList('package')
    local last_pid = self.m_lStepPids[#self.m_lStepPids]
    if (not last_pid) then
        return
    end

    local last_struct_product = l_item_list[last_pid]
    if (not last_struct_product) then
        return
    end

    -- product_content = 70001;2, 70002;1
    local product_content = last_struct_product['mail_content']
    if (not product_content) then
        return
    end
    
    -- last_item = 70001;2
    local item = pl.stringx.split(product_content, ',')
    local last_item = item[1]
    if (not last_item) then
        return
    end

    local _item = pl.stringx.split(last_item, ';')
    local item_name = TableItem:getItemName(tonumber(_item[1])) or ''
    if (step < #self.m_lStepPids) then
        str = Str('{1}단계 후 {2} 획득 가능!', #self.m_lStepPids - step, Str(item_name))
    else
        str = Str('{1} 획득 가능!', Str(item_name))
    end
    vars['infoLabel']:setString(str)
end

-------------------------------------
-- function setBuutonState
-------------------------------------
function UI_Package_Step03:setBuutonState(clicked_step)
    local vars = self.vars
    for idx = 1, #self.m_lStepPids do
        local state_name = self:getButtonState(idx, clicked_step)     
        if (vars['stepBtnVisual' .. idx]) then    
			local ani_name = string.format('btn_step%d_%s', idx, state_name)
			vars['stepBtnVisual' .. idx]:changeAni(ani_name)
        end
    end
end

-------------------------------------
-- function getButtonState
-- @brief 구매 안한 상태, 선택한 상태, 구매한 상태, 구매한 걸 선택한 상태 
-------------------------------------
function UI_Package_Step03:getButtonState(target_step, clicked_step)
    -- 모든 단계를 구매한 경우
    if (self.m_isAllSoldOut) then
        if (target_step == clicked_step) then
            return BUTTON_STATE.SOLDOUT_SELECT
        else
            return BUTTON_STATE.SOLDOUT
        end       
    end
    
    -- 구매 스텝보다 낮다면 구매한 상태
    if (target_step < self.m_curr_step) then
        if (target_step == clicked_step) then
            return BUTTON_STATE.SOLDOUT_SELECT
        else
            return BUTTON_STATE.SOLDOUT
        end
    -- 구매 스텝보다 높다면 아직 구매 안한 상태
    elseif (target_step >= self.m_curr_step) then
        if (target_step == clicked_step) then
            return BUTTON_STATE.SELECT
        else
            return BUTTON_STATE.NORMAL
        end
    end
end

-------------------------------------
-- function click_stepBtn
-------------------------------------
function UI_Package_Step03:click_stepBtn(step)
    self:refresh(step)
end

-------------------------------------
-- function setNoti
-------------------------------------
function UI_Package_Step03:setNoti()
    local vars = self.vars
    local l_item_list = g_shopDataNew:getProductList('package')

    for idx = 1, #self.m_lStepPids do
        local target_pid = tonumber(self.m_lStepPids[idx])
        local struct_product = l_item_list[target_pid]
        
        -- 샵 정보가 없다면 구매 완료인 상태
        local is_buy = struct_product == nil

        --  구매 완료된 상품에 노티
        if (vars['completeNoti'..idx]) then
            vars['completeNoti'..idx]:setVisible(is_buy)
        end
    end
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_Package_Step03:click_buyBtn()
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