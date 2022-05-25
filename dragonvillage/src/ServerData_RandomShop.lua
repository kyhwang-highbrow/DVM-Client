-------------------------------------
-- class ServerData_RandomShop
-------------------------------------
ServerData_RandomShop = class({
        m_serverData = 'ServerData',
        m_productList = 'table',
        m_refreshTime = 'number',
        m_refreshPrice = 'number',
        m_bDirty = 'boolean',
    })

local REFRESH_TIME_SAVE_KEY = 'random_shop_expired'

-------------------------------------
-- function init
-------------------------------------
function ServerData_RandomShop:init(server_data)
    self.m_serverData = server_data
    self.m_refreshPrice = 100
    self.m_bDirty = false
end

-------------------------------------
-- function getProductList
-------------------------------------
function ServerData_RandomShop:getProductList()
    local ret = {}

    -- StructRandomShopItem List 생성
    if (self.m_productList) then
        for idx, v in pairs(self.m_productList) do
            local struct_item = StructRandomShopItem(v)
            -- 서버에서 키를 상품 인덱스로 넘겨줌
            struct_item['product_idx'] = tonumber(idx)
            table.insert(ret, struct_item)
        end
    end

    -- 우선순위 정렬
    table.sort(ret, function(a,b)
        local a_priority = a['product_idx'] or 99
        local b_priority = b['product_idx'] or 99
        return a_priority < b_priority
    end)

    return ret
end

-------------------------------------
-- function getStatusText
-------------------------------------
function ServerData_RandomShop:getStatusText()
    local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()
    local refresh_time = (self.m_refreshTime / 1000)
    local time = (refresh_time - curr_time)
    
    local str
    if (curr_time > refresh_time) then
        str = ''
        -- 상품 갱신 가능
        self.m_bDirty = true
    else
        str = Str('상품 교체까지 {1} 남음', ServerTime:getInstance():makeTimeDescToSec(time, true, true))
    end

    return str
end

-------------------------------------
-- function response_shopInfo
-------------------------------------
function ServerData_RandomShop:response_shopInfo(ret)
    if (ret['status'] and ret['status'] ~= 0) then
        return
    end

    -- 상품 정보
    if (ret['info'] and ret['info']['products']) then
        self.m_productList = ret['info']['products']
    end

    -- 갱신 시간
    if (ret['info'] and ret['info']['expired_at']) then
        self.m_refreshTime = ret['info']['expired_at']

        -- 상점 하일라이트 노티 갱신을 위해 로컬 데이터로 저장 
        g_settingData:applySettingData(self.m_refreshTime, REFRESH_TIME_SAVE_KEY)
    end

    -- 갱신 비용
    if (ret['refresh_price']) then
        self.m_refreshPrice = ret['refresh_price']
    end
end

-------------------------------------
-- function isHightlightShop
-------------------------------------
function ServerData_RandomShop:isHightlightShop()
    local refresh_time = g_settingData:get(REFRESH_TIME_SAVE_KEY)
    if (refresh_time) then
        local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()
        local _refresh_time = (refresh_time / 1000)
        return (curr_time > _refresh_time) 
    else
        -- 로컬에 저장된 값이 없다면 하일라이트 노티 켜줌 (진입 유도)
        return true
    end
end

-------------------------------------
-- function getRefreshRemainTimeText
-------------------------------------
function ServerData_RandomShop:getRefreshRemainTimeText()
    local remain_text = ''
    if (not self:isHightlightShop()) then
        local refresh_time = g_settingData:get(REFRESH_TIME_SAVE_KEY)
        if (refresh_time) then
            local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()
            local _refresh_time = (refresh_time / 1000)
            local time = math_max(_refresh_time - curr_time, 0)
            if (time > 0) then
                return Str('{1} 남음', ServerTime:getInstance():makeTimeDescToSec(time, true, true))
            end
        end
    end

    return remain_text
end

-------------------------------------
-- function request_shopInfo
-------------------------------------
function ServerData_RandomShop:request_shopInfo(cb_func, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        self:response_shopInfo(ret)

        if (cb_func) then
            cb_func()
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/randomshop_info')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:hideBGLayerColor()
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_refreshInfo
-------------------------------------
function ServerData_RandomShop:request_refreshInfo(cb_func, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        self:response_shopInfo(ret)
        -- 재화 갱신
        g_serverData:networkCommonRespone(ret)

        if (cb_func) then
            cb_func(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/randomshop_refresh')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:hideBGLayerColor()
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_buy
-------------------------------------
function ServerData_RandomShop:request_buy(index, price_type , cb_func, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        self:response_shopInfo(ret)
        -- 재화 갱신
        g_serverData:networkCommonRespone(ret)

        -- 아이템 수령
        g_serverData:networkCommonRespone_addedItems(ret)

        if (cb_func) then
            cb_func(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/randomshop_buy')
    ui_network:setParam('uid', uid)
    ui_network:setParam('index', index)
    ui_network:setParam('price_type', price_type)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:hideBGLayerColor()
    ui_network:request()

    return ui_network
end