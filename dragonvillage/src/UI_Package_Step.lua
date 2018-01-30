local PARENT = UI_Package_Bundle

-------------------------------------
-- class UI_Package_Step
-------------------------------------
UI_Package_Step = class(PARENT,{
        m_curr_step = 'number',
    })

-- 단계별 패키지 product id
local t_step_pids = {90077, 90078, 90079, 90080}

-------------------------------------
-- function init
-------------------------------------
function UI_Package_Step:init(package_name, is_popup)
    self:setCurrentStep()
    self:refresh(self.m_curr_step)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Package_Step:initButton()
    local vars = self.vars

    for idx = 1, #t_step_pids do
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
    for idx, pid in ipairs(t_step_pids) do
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

    for idx = 1, #t_step_pids do
        vars['stepNode'..idx]:setVisible(idx == step)

        if (idx == step) then
            local target_pid = t_step_pids[idx]
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
                local buy_str = (self.m_curr_step < idx) and '' or struct_product:getMaxBuyTermStr()
                vars['buyLabel']:setString(buy_str)

                -- 현재 단계보다 높으면 구매 불가
                vars['buyBtn']:setEnabled(self.m_curr_step >= idx)
            end
        end
    end
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
    local target_pid = t_step_pids[self.m_curr_step]
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