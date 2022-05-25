-------------------------------------
-- class ServerData_Exchange
-------------------------------------
ServerData_Exchange = class({
        m_serverData = 'ServerData',
        
        m_bDirtyExchangeInfo = 'boolean',

        m_lExchange = 'table',
        m_mProductList = 'map[list]'
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Exchange:init(server_data)
    self.m_serverData = server_data
    
    self.m_bDirtyExchangeInfo = true

    self.m_lExchange = {}
    self.m_mProductList = {}
end

-------------------------------------
-- function ckechUpdateExchangeInfo
-- @brief 정보가 갱신되어야하는지 여부를 확인
-------------------------------------
function ServerData_Exchange:ckechUpdateExchangeInfo()
    if self.m_bDirtyExchangeInfo then
        return
    end

    -- 추후에 time stamp등을 확인해서 여부를 설정할 것
    -- self.m_bDirtyExchangeInfo = true
end

-------------------------------------
-- function request_exchangeInfo
-------------------------------------
function ServerData_Exchange:request_exchangeInfo(finish_cb, fail_cb)
    -- 정보가 갱신되어야하는지 여부를 확인
    self:ckechUpdateExchangeInfo()

    -- 갱신할 필요가 없으면 즉시 리턴
    if (self.m_bDirtyExchangeInfo == false) then
        if finish_cb then
            finish_cb()
        end
        return
    end

    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        local server_time = ServerTime:getInstance():getCurrentTimestampSeconds()

        self.m_lExchange = {}
        self.m_mProductList = {}

        self.m_bDirtyExchangeInfo = false

        g_serverData:networkCommonRespone_addedItems(ret)

        do -- 이벤트 정보
            if (ret['table_exchange_list']) then
                for _, v in ipairs(ret['table_exchange_list']) do
                    table.insert(self.m_lExchange, v)

                    local exchange_type = v['group_type']
                    self.m_mProductList[exchange_type] = {}
                end
            end
        end

        do -- 상품 정보
            if (ret['table_exchange']) then
                --TABLE['exchange'] = TableExchange(ret['table_exchange'])

                -- 활성화 중인 이벤트 상품만 따로 저장
                for i, v in ipairs(ret['table_exchange']) do
                    local exchange_type = v['group_type']
                    local end_date

                    if (v['limit_time_end_date'] ~= '') then
                        end_date = Timer:strToTimeStamp(v['limit_time_end_date'])
                    end

                    -- 판매가 종료된 상품
                    if (end_date and end_date < server_time) then
                        
                    elseif (self.m_mProductList[exchange_type]) then
                        table.insert(self.m_mProductList[exchange_type], StructExchangeProductData(v))
                    end
                end
            end
        end
        
        if (finish_cb) then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/exchange/info')
    ui_network:setParam('uid', uid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_exchange
-- @brief 교환소의 아이템으로 교환(구매)
-------------------------------------
function ServerData_Exchange:request_exchange(product_id, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)        
        g_serverData:networkCommonRespone_addedItems(ret)

        if (finish_cb) then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/exchange/buy')
    ui_network:setParam('uid', uid)
    ui_network:setParam('product_id', product_id)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function getProductList
-------------------------------------
function ServerData_Exchange:getProductList(exchange_type)
    return self.m_mProductList[exchange_type]
end

-------------------------------------
-- function getResTabIcon
-------------------------------------
function ServerData_Exchange:getResTabIcon(exchange_type)
    for i, v in ipairs(self.m_lExchange) do
        if (exchange_type == v['group_type']) then
            return v['icon']
        end
    end
end

-------------------------------------
-- function canBuyProduct
-- @brief 구매 가능 여부 검사
-------------------------------------
function ServerData_Exchange:canBuyProduct(price_type, price_value)
    local user_price = 0

    -- 지불 재화 개수 저장
    if (price_type == 'x') then
        user_price = 0
    else
        user_price = g_userData:get(price_type)    
    end

    if (not user_price) then
        error('price_type : ' .. price_type)
    end

    -- 개수 확인
    if (price_value > user_price) then
        local t_item = TableItem():getRewardItem(price_type)
        local need_price_str = comma_value(price_value - user_price)
        local msg = Str('{1} {2}개가 부족합니다.', t_item['t_name'], comma_value(need_price_str))
        
        return false, msg
    end

    return true
end