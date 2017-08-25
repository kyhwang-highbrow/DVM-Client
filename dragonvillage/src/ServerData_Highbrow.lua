-------------------------------------
-- class ServerData_Highbrow
-------------------------------------
ServerData_Highbrow = class({
        m_serverData = 'ServerData',
        m_hbItemList = 'list',
        m_hbBannerUrl = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Highbrow:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function applyHBItemList
-- @brief 하이브로 상점 목록 사용하기 좋게 만듬
-------------------------------------
function ServerData_Highbrow:applyHBItemList(item_list)
    local l_ret = {}

    for game_key, v in pairs(item_list) do 
        for _, t_item in pairs(v) do
            t_item['game_key'] = game_key
            table.insert(l_ret, StructHighbrowProduct(t_item))
        end
    end
    
    -- 정렬 순서
    -- 1. 수령하지 않은 것
    -- 2. 튜토리얼 보상 먼저
    -- 3. 드빌1
    table.sort(l_ret, function(a, b)
        if (a.done == b.done) then
            if (a.type == b.type) then
                if (a.game_key == 'dv1') then
                    return true
                elseif (b.game_key == 'dv1') then
                    return false
                end
            else
                return a.type < b.type
            end
        else
            if (a.done == false) then
                return true
            elseif (b.done == false) then
                return false
            end
        end            
    end)

    self.m_hbItemList = l_ret
end

-------------------------------------
-- function getHBItemList
-- @brief 하이브로 상점 목록
-------------------------------------
function ServerData_Highbrow:getHBItemList()
    return self.m_hbItemList
end

-------------------------------------
-- function getBannerUrl
-- @brief 하이브로 배너 url
-------------------------------------
function ServerData_Highbrow:getBannerUrl()
    return self.m_hbBannerUrl
end

-------------------------------------
-- function request_getHbProductList
-------------------------------------
function ServerData_Highbrow:request_getHbProductList(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)
        self:applyHBItemList(ret['hb_items'])
        
        -- url도 같이 받는게 좀 이상하지만 나중에 따로 필요하면 분리..
        self.m_hbBannerUrl = ret['banner_url']
        
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/highbrow/item_list')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_buyHbProcduct
-------------------------------------
function ServerData_Highbrow:request_buyHbProcduct(code, game_key, finish_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)
        g_serverData:networkCommonRespone_addedItems(ret)
        g_highlightData:applyHighlightInfo(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/highbrow/buy')
    ui_network:setParam('uid', uid)
    ui_network:setParam('code', code)
    ui_network:setParam('game', game_key)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_buyHBProductTutorial
-------------------------------------
function ServerData_Highbrow:request_buyHBProductTutorial(code, game_key, finish_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)
        g_highlightData:applyHighlightInfo(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/highbrow/tutorial')
    ui_network:setParam('uid', uid)
    ui_network:setParam('code', code)
    ui_network:setParam('game', game_key)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_couponCheck
-------------------------------------
function ServerData_Highbrow:request_couponCheck(coupon, success_cb, result_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/highbrow/coupon_check')
    ui_network:setParam('uid', uid)
    ui_network:setParam('coupon', coupon)
    ui_network:setSuccessCB(success_cb)
    ui_network:setResponseStatusCB(result_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_couponUse
-------------------------------------
function ServerData_Highbrow:request_couponUse(coupon, success_cb, result_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/highbrow/coupon_use')
    ui_network:setParam('uid', uid)
    ui_network:setParam('coupon', coupon)
    ui_network:setSuccessCB(success_cb)
    ui_network:setResponseStatusCB(result_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end
