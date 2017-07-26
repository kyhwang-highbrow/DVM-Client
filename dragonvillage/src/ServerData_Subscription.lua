-- 테이블
-- table_subscription_list
-- table_shop_cash
-- table_shop_basic

-------------------------------------
-- class ServerData_Subscription
-- @breif 구독형 상품 관리
-- @dependency ServerData_Shop
-------------------------------------
ServerData_Subscription = class({
        m_serverData = 'ServerData',
        m_bDirty = 'bool',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Subscription:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function openSubscriptionPopup
-- @brief
--        1. 상점 리스트를 서버에서 받아옴
--           (리스트를 받아오지 못하였을 경우 종료)
--        2. 
-------------------------------------
function ServerData_Subscription:openSubscriptionPopup()
    self:ckechDirty()

    local function cb_func()
        UI_Shop()
    end

    if (not self:isDirty()) then
        cb_func()
        return
    end

    -- 서버에 상품정보 요청
	self:request_subscriptionInfo(cb_func)
end

-------------------------------------
-- function request_subscriptionInfo
-------------------------------------
function ServerData_Subscription:request_subscriptionInfo(cb_func)

    -- 콜백 함수
    local function success_cb(ret)
        self:response_subscriptionInfo(ret)

		if (cb_func) then
			cb_func(ret)
		end
    end

    g_shopDataNew:request_shopInfo(success_cb)
end

-------------------------------------
-- function response_subscriptionInfo
-------------------------------------
function ServerData_Subscription:response_subscriptionInfo(ret)
    if (ret['status'] ~= 0) then
        return
    end

    cclog('### response_subscriptionInfo(ret) call!!')

    local table_shop_cash = self:listToDic(ret['table_shop_cash'], 'product_id')
    local table_shop_basic = self:listToDic(ret['table_shop_basic'], 'product_id')
    local table_subscription_list = self:listToDic(ret['table_subscription_list'], 'list_id')
    
    for i,v in pairs(table_subscription_list) do
        cclog('idx ' .. i)
        local product_id = v['product_id']
        local start_date = v['start_date']
        local end_date = v['end_date']
        local next = v['next']
        local ui_priority = v['ui_priority'] and tonumber(v['ui_priority'])
        if (not ui_priority) then
            ui_priority = 0
        end
        local t_product = nil

        t_product = table_shop_cash[product_id] or table_shop_basic[product_id]

        if t_product then
            local struct_product = StructProduct(t_product)
            struct_product:setStartDate(start_date) -- 판매 시작 시간
            struct_product:setEndDate(end_date) -- 판매 종료 시간
            -- next 필요
            struct_product:setUIPriority(ui_priority) -- UI정렬 순선 (높으면 앞쪽에 노출)
            self:insertProduct(struct_product)
        end
    end
end

-------------------------------------
-- function ckechDirty
-------------------------------------
function ServerData_Subscription:ckechDirty()
    g_shopDataNew:ckechDirty()
end

-------------------------------------
-- function setDirty
-------------------------------------
function ServerData_Subscription:setDirty()
    g_shopDataNew:setDirty()
end

-------------------------------------
-- function isDirty
-------------------------------------
function ServerData_Subscription:isDirty()
    return g_shopDataNew:isDirty()
end

-------------------------------------
-- function listToDic
-------------------------------------
function ServerData_Subscription:listToDic(l_data, key)
    return g_shopDataNew:listToDic(l_data, key)
end