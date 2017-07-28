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
        m_dicProduct = '[subscription_category][struct_product]',
        m_subscribedInfoList = 'list[StructSubscribedInfo]', -- 구독 중인 상품 정보
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Subscription:init(server_data)
    self.m_serverData = server_data

    self.m_dicProduct = {}
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
        if self:getSubscribedInfo() then
            UI_SubscriptionPopup_Ing()
        else
            UI_SubscriptionPopup()
        end
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
function ServerData_Subscription:request_subscriptionInfo(cb_func, fail_cb)

    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        self:response_subscriptionInfo(ret)

		if (cb_func) then
			cb_func(ret)
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/subscription')
    ui_network:setParam('uid', uid)
    ui_network:hideLoading()
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
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
        local product_id = v['product_id']
        local t_product = nil
        t_product = table_shop_cash[product_id] or table_shop_basic[product_id]

        if t_product then
            local struct_product_subsc = StructProductSubscription:create(t_product, v)
            self:insertProduct(struct_product_subsc)
        end
    end

    -- 구독 중인 상품에 대한 처리
    self.m_subscribedInfoList = {}
    local user_subscription_list = ret['user_subscription_list']
    for i,v in pairs(user_subscription_list) do
        local struct_subsc_info = StructSubscribedInfo(v)
        table.insert(self.m_subscribedInfoList, struct_subsc_info)
    end
end

-------------------------------------
-- function ckechDirty
-------------------------------------
function ServerData_Subscription:ckechDirty()
    if self.m_bDirty then
        return
    end

    -- 만료 시간 체크 할 것!
    --self.m_expirationData
    self.m_bDirty = true
end

-------------------------------------
-- function setDirty
-------------------------------------
function ServerData_Subscription:setDirty()
    self.m_bDirty = true
end

-------------------------------------
-- function isDirty
-------------------------------------
function ServerData_Subscription:isDirty()
    return self.m_bDirty
end

-------------------------------------
-- function listToDic
-------------------------------------
function ServerData_Subscription:listToDic(l_data, key)
    local t_ret = {}

    for i,v in pairs(l_data) do
        local _key = v[key]
        t_ret[_key] = v
    end

    return t_ret
end

-------------------------------------
-- function clearProduct
-------------------------------------
function ServerData_Subscription:clearProduct()
    for i,_ in pairs(self.m_dicProduct) do
        self.m_dicProduct[i] = {}
    end
end

-------------------------------------
-- function insertProduct
-------------------------------------
function ServerData_Subscription:insertProduct(struct_product)
    local subscription_category = struct_product:getSubscriptionCategory()

    if (not self.m_dicProduct[subscription_category]) then
        self.m_dicProduct[subscription_category] = {}
    end

    table.insert(self.m_dicProduct[subscription_category], struct_product)
end


-------------------------------------
-- function getSubscriptionProductInfo
-- @brief
-- @return StructProductSubscription
-------------------------------------
function ServerData_Subscription:getSubscriptionProductInfo(subscription_category)
    local l_product = self.m_dicProduct[subscription_category]

    if (not l_product) then
        return nil
    end

    local first_product = nil
    local low_product_id = nil
    for i,v in pairs(l_product) do
        if (not first_product) or (v['product_id'] < low_product_id) then
            first_product = v
            low_product_id = v['product_id']
        end
    end

    return first_product
end

-------------------------------------
-- function getSubscriptionProductInfo_usePid
-- @brief product_id로 상품 정보 가져옴
-- @return StructProductSubscription
-------------------------------------
function ServerData_Subscription:getSubscriptionProductInfo_usePid(product_id)
    local struct_product = nil

    for _,l_list in pairs(self.m_dicProduct) do
        for _,v in pairs(l_list) do
            if (product_id == v['product_id']) then
                struct_product = v
                break
            end
        end
    end

    return struct_product
end

-------------------------------------
-- function getBasicSubscriptionProductInfo
-- @brief 일반 월정액 상품 정보
-------------------------------------
function ServerData_Subscription:getBasicSubscriptionProductInfo()
    return self:getSubscriptionProductInfo('basic')
end

-------------------------------------
-- function getPremiumSubscriptionProductInfo
-- @brief 프리미엄 월정액 상품 정보
-------------------------------------
function ServerData_Subscription:getPremiumSubscriptionProductInfo()
    return self:getSubscriptionProductInfo('premium')
end


-------------------------------------
-- function getSubscribedInfo
-- @brief 구독 중인 상품 정보
-- @return StructSubscribedInfo
-- 2017-07-28 sgkim
-- 현재까지 구독은 하나만 할 수 있는 기획이어서 그렇게 가정하고 코딩함
-------------------------------------
function ServerData_Subscription:getSubscribedInfo()
    return self.m_subscribedInfoList[1]
end

-------------------------------------
-- function getAvailableProduct
-- @brief 구매 가능한 상품
-------------------------------------
function ServerData_Subscription:getAvailableProduct()
    local info = self:getSubscribedInfo() -- StructSubscribedInfo

    if (not info) then
        return nil
    end

    local product_id = info:getNextProductID()

    return self:getSubscriptionProductInfo_usePid(product_id)
end
