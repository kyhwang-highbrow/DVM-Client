-------------------------------------
-- class ServerData_Hatchery
-------------------------------------
ServerData_Hatchery = class({
        m_serverData = 'ServerData',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Hatchery:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function request_summonFriendshipPoint
-- @breif
-------------------------------------
function ServerData_Hatchery:request_summonFriendshipPoint(is_bundle, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')
    local is_bundle = is_bundle or false

    -- 성공 콜백
    local function success_cb(ret)

        -- fp(우정포인트) 갱신
        g_serverData:networkCommonRespone(ret)

        -- 드래곤들 추가
        g_dragonsData:applyDragonData_list(ret['added_dragons'])

        -- 슬라임들 추가
        g_slimesData:applySlimeData_list(ret['added_slimes'])

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/summon/fp')
    ui_network:setParam('uid', uid)
    ui_network:setParam('bundle', is_bundle)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_summonCash
-- @breif
-------------------------------------
function ServerData_Hatchery:request_summonCash(is_bundle, is_sale, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')
    local is_bundle = is_bundle or false
    local is_sale = is_sale or false

    -- 성공 콜백
    local function success_cb(ret)

        -- cash(캐시) 갱신
        g_serverData:networkCommonRespone(ret)

        -- 드래곤들 추가
        g_dragonsData:applyDragonData_list(ret['added_dragons'])

        -- 슬라임들 추가
        g_slimesData:applySlimeData_list(ret['added_slimes'])

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/summon/cash')
    ui_network:setParam('uid', uid)
    ui_network:setParam('bundle', is_bundle)
    ui_network:setParam('sale', is_sale)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_summonCashEvent
-- @breif
-------------------------------------
function ServerData_Hatchery:request_summonCashEvent(is_bundle, is_sale, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')
    local is_bundle = is_bundle or false
    local is_sale = is_sale or false

    -- 성공 콜백
    local function success_cb(ret)

        -- cash(캐시) 갱신
        g_serverData:networkCommonRespone(ret)

        -- 드래곤들 추가
        g_dragonsData:applyDragonData_list(ret['added_dragons'])

        -- 슬라임들 추가
        g_slimesData:applySlimeData_list(ret['added_slimes'])

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/summon/event')
    ui_network:setParam('uid', uid)
    ui_network:setParam('bundle', is_bundle)
    ui_network:setParam('sale', is_sale)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end