-------------------------------------
-- class ServerData_RandomShop
-------------------------------------
ServerData_RandomShop = class({
        m_serverData = 'ServerData',
        m_productList = 'table',
        m_refreshTime = 'number',
        m_bDirty = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_RandomShop:init(server_data)
    self.m_serverData = server_data
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
            -- 서버에서 키를 우선순위로 넘겨줌
            struct_item['ui_priority'] = tonumber(idx)
            table.insert(ret, struct_item)
        end
    end

    -- 우선순위 정렬
    table.sort(ret, function(a,b)
        local a_priority = a['ui_priority'] or 99
        local b_priority = b['ui_priority'] or 99
        return a_priority < b_priority
    end)

    return ret
end

-------------------------------------
-- function getStatusText
-------------------------------------
function ServerData_RandomShop:getStatusText()
    local curr_time = Timer:getServerTime()
    local refresh_time = (self.m_refreshTime / 1000)
    local time = (refresh_time - curr_time)
    
    local str
    if (curr_time > refresh_time) then
        str = ''
        -- 상품 갱신 가능
        self.m_bDirty = true
    else
        str = Str('상품 교체까지 {1} 남음', datetime.makeTimeDesc(time, false, true))
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
    end
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
            cb_func()
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