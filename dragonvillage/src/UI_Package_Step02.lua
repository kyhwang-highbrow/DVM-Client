local PARENT = UI_Package_Bundle

local BUTTON_STATE = {}
BUTTON_STATE.NORMAL = 'normal'
BUTTON_STATE.SELECT = 'selected'
BUTTON_STATE.SOLDOUT = 'soldout'
BUTTON_STATE.SOLDOUT_SELECT = 'soldout_selected'

-------------------------------------
-- class UI_Package_Step02
-------------------------------------
UI_Package_Step02 = class(PARENT,{
        m_curr_step = 'number',
        m_lStepPids = 'list',
        m_pacakgeName = 'string',
        m_isAllSoldOut = 'boolean',
    })


-------------------------------------
-- function init
-------------------------------------
function UI_Package_Step02:init(package_name, is_popup)
    self.m_pacakgeName = package_name
    self.m_lStepPids = g_shopDataNew:getPakcageStepPidList(self.m_pacakgeName)
    self:initStep(package_name)
end

-------------------------------------
-- function initStep
-------------------------------------
function UI_Package_Step02:initStep(package_name)
    local vars = self.vars
    for idx = 1, #self.m_lStepPids do
        vars['stepBtn'..idx]:registerScriptTapHandler(function() self:click_stepBtn(idx) end)       
    end
    
    self:setCurrentStep()
    self:refresh(self.m_curr_step)

    -- 종료 임박 출력(하드코딩)
    vars['limitNode']:setVisible(false)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Package_Step02:initButton()
    local vars = self.vars
    
    vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
    vars['contractBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function setCurrentStep
-- @breif 구매내역으로 현재 스텝 체크
-------------------------------------
function UI_Package_Step02:setCurrentStep()
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
function UI_Package_Step02:refresh(step)
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
                vars['priceLabel']:setString(struct_product:getPriceStr())

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

    -- 구매 완료된 상품에 노티
    self:setNoti()

    -- 버튼 상태 갱신
    self:setBuutonState(step) -- 클릭한 스텝
end

-------------------------------------
-- function setBuutonState
-------------------------------------
function UI_Package_Step02:setBuutonState(clicked_step)
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
function UI_Package_Step02:getButtonState(target_step, clicked_step)
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
function UI_Package_Step02:click_stepBtn(step)
    self:refresh(step)
end

-------------------------------------
-- function setNoti
-------------------------------------
function UI_Package_Step02:setNoti()
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
function UI_Package_Step02:click_buyBtn()
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