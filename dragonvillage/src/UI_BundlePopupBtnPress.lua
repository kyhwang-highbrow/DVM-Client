-- button에서 registerScriptPressHandler함수로 콜백 함수 등록
-- n초 이상 터치를 유지하면 최초 1회 호출됨
-- 이때 스케쥴러(update)함수를 등록해서 매 프레임 호출

-- 종료 타입
-- 상품 갯수가 1 이하일 때 - 버튼
-- 구매 한도 
-- 재화 부족

-------------------------------------
-- class UI_BundlePopupBtnPress
-------------------------------------
UI_BundlePopupBtnPress = class({
        m_bundlePopupUI = 'UI_BundlePopup',
        m_updateNode = 'cc.Node',
        m_quantityBtn = 'UIC_Button',

        m_blockUI = 'UI_BlockPopup',

        m_timer = 'number',
        m_timerResetCount = 'number', -- 누르고 있는동안 타이머가 몇번 돌았는지

        --------------------------
        m_isAdd = 'boolean' -- 현재 누르고 있는 버튼이 +인지, -인지
    })

-------------------------------------
-- function init
-------------------------------------
function UI_BundlePopupBtnPress:init(bundle_popup_ui)
    self.m_bundlePopupUI = bundle_popup_ui

    -- update함수를 위한 노드 추가
    self.m_updateNode = cc.Node:create()
    bundle_popup_ui.root:addChild(self.m_updateNode)

    self:resetQuantityBtnPress()
end

-------------------------------------
-- function resetQuantityBtnPress
-- @brief 상태 초기화
-------------------------------------
function UI_BundlePopupBtnPress:resetQuantityBtnPress()
    self.m_quantityBtn = nil
    self.m_timer = 0
    self.m_timerResetCount = 0
    self.m_updateNode:unscheduleUpdate()
    
    if (self.m_blockUI) then
        self.m_blockUI:close()
    end
end


-------------------------------------
-- function quantityBtnPressHandler
-- @brief 수량 조절 버튼이 press입력을 받기 시작할 때 호출
-- @param btn 눌리고 있는 버튼
-- @param is_add가 true면 +, false면 -
-------------------------------------
function UI_BundlePopupBtnPress:quantityBtnPressHandler(btn, is_add)
    if (self.m_quantityBtn) then
        return
    end

    local bundle_popup_ui = self.m_bundlePopupUI

    self.m_blockUI = UI_BlockPopup() -- 이 UI가 살아있는 동안에는 backkey를 막아준다.
    self.m_quantityBtn = btn
    self.m_isAdd= is_add

    self.m_updateNode:scheduleUpdateWithPriorityLua(function(dt) return self:update(dt) end, 0)
end

-------------------------------------
-- function update
-------------------------------------
function UI_BundlePopupBtnPress:update(dt)
    if (not self.m_quantityBtn:isSelected()) then
        self:resetQuantityBtnPress()
        return
    end

    self.m_timer = (self.m_timer - dt)
    while (self.m_timer <= 0) do

        -- 상품 정보
        local bundle_popup_ui = self.m_bundlePopupUI
        local struct_product = bundle_popup_ui.m_structProduct
        local count = bundle_popup_ui.m_count
        local is_add = self.m_isAdd
        
        if (is_add) then
            count = count + 1
        else
            count = count - 1
        end

        -- 1 이하 예외처리
        if (count < 1) then
		    count = 1
            self:resetQuantityBtnPress()
		    return
	    end

        if (count > 1000) then
            count = 1000
            self:resetQuantityBtnPress()
            return
        end

        local price_type = struct_product:getPriceType()

        -- 구매 한도 예외처리
        local max_buy_cnt = tonumber(struct_product['max_buy_count'])
        local cur_buy_cnt
        if (rawget(struct_product, price_type)) then
            if (struct_product[price_type] ~= nil) then
                cur_buy_cnt = g_dmgateData:getProductCount(struct_product['product_id'])
            else
                return
            end
        else
            cur_buy_cnt = g_shopData:getBuyCount(struct_product['product_id'])
        end

        if (max_buy_cnt) then
            if (count > max_buy_cnt - cur_buy_cnt) then
                self:resetQuantityBtnPress()
                return
            end
        end

        -- 재화 부족 예외처리
        local price = struct_product:getPrice()
        
        local price_type_id
        if (rawget( struct_product, price_type)) then
            price_type_id = struct_product[price_type]
        end
        if (not UIHelper:checkPrice_toastMessage(price_type, price * count, price_type_id)) then
            self:resetQuantityBtnPress()
            return
        end

        bundle_popup_ui.m_count = count
        bundle_popup_ui:refresh()

        self.m_timerResetCount = self.m_timerResetCount + 1
        local next_waiting_time = self:getWaitingTime()
        self.m_timer = (self.m_timer + next_waiting_time)
    end
end

-------------------------------------
-- function getWaitingTime
-- @brief 오래 누를수록 짧은 시간 반환
-------------------------------------
function UI_BundlePopupBtnPress:getWaitingTime()
    local reset_count = self.m_timerResetCount

    if (reset_count <= 3) then
        return 0.2
    elseif (reset_count <= 9) then
        return 0.1
    elseif (reset_count <= 24) then
        return 0.05
    else
        return 0.025
    end
end