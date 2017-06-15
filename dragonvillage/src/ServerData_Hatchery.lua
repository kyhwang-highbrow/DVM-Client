-------------------------------------
-- class ServerData_Hatchery
-------------------------------------
ServerData_Hatchery = class({
        m_serverData = 'ServerData',

        -- 확률업 소환
        CASH__EVENT_SUMMON_PRICE = 300,
        CASH__EVENT_BUNDLE_SUMMON_PRICE = 3000,

        -- 캐시 소환
        CASH__SUMMON_PRICE = 300,
        CASH__BUNDLE_SUMMON_PRICE = 3000,

        SALE__PERCENTAGE = 0.1,

        -- 우정포인트 소환
        FP__SUMMON_PRICE = 10,
        FP__BUNDLE_SUMMON_PRICE = 100,
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
    local prev_mileage = g_userData:get('mileage')

    -- 성공 콜백
    local function success_cb(ret)

        -- cash(캐시) 갱신
        g_serverData:networkCommonRespone(ret)

        -- 추가된 마일리지
        local after_mileage = g_userData:get('mileage')
        local added_mileage = (after_mileage - prev_mileage)
        ret['added_mileage'] = added_mileage

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
    local prev_mileage = g_userData:get('mileage')

    -- 성공 콜백
    local function success_cb(ret)

        -- cash(캐시) 갱신
        g_serverData:networkCommonRespone(ret)

        -- 추가된 마일리지
        local after_mileage = g_userData:get('mileage')
        local added_mileage = (after_mileage - prev_mileage)
        ret['added_mileage'] = added_mileage

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

-------------------------------------
-- function getSummonEggList
-- @breif
-------------------------------------
function ServerData_Hatchery:getSummonEggList()
    local l_item_list = {}

    do -- 이벤트 데이터
        local t_data = {['egg_id']=700001, ['bundle']=true, ['full_type'] = 'egg_cash_mysteryup', ['name']=Str('확률업 10+1회 소환'), ['desc']=Str('3~5★ 드래곤 부화')}
        t_data['price_type'] = 'cash'
        t_data['price'] = ServerData_Hatchery.CASH__EVENT_BUNDLE_SUMMON_PRICE
        table.insert(l_item_list, t_data)

        local t_data = {['egg_id']=700001, ['bundle']=false,  ['full_type'] = 'egg_cash_mysteryup', ['name']=Str('확률업 소환'), ['desc']=Str('3~5★ 드래곤 부화')}
        t_data['price_type'] = 'cash'
        t_data['price'] = ServerData_Hatchery.CASH__EVENT_SUMMON_PRICE
        table.insert(l_item_list, t_data)
    end

    do -- 고급 부화
        local t_data = {['egg_id']=700002, ['bundle']=true, ['full_type'] = 'egg_cash_mystery', ['name']=Str('고급 부화 10+1회'), ['desc']=Str('3~5★ 드래곤 부화')}
        t_data['price_type'] = 'cash'
        t_data['price'] = ServerData_Hatchery.CASH__BUNDLE_SUMMON_PRICE
        table.insert(l_item_list, t_data)

        local t_data = {['egg_id']=700002, ['bundle']=false,  ['full_type'] = 'egg_cash_mystery', ['name']=Str('고급 부화'), ['desc']=Str('3~5★ 드래곤 부화')}
        t_data['price_type'] = 'cash'
        t_data['price'] = ServerData_Hatchery.CASH__SUMMON_PRICE
        table.insert(l_item_list, t_data)
    end

    do -- 우정포인트 부화
        local t_data = {['egg_id']=700003, ['bundle']=true, ['full_type'] = 'egg_friendship', ['name']=Str('우정 부화 10+1회'), ['desc']=Str('1~3★ 드래곤 부화')}
        t_data['price_type'] = 'fp'
        t_data['price'] = ServerData_Hatchery.FP__BUNDLE_SUMMON_PRICE
        table.insert(l_item_list, t_data)

        local t_data = {['egg_id']=700003, ['bundle']=false,  ['full_type'] = 'egg_friendship', ['name']=Str('우정 부화'), ['desc']=Str('1~3★ 드래곤 부화')}
        t_data['price_type'] = 'fp'
        t_data['price'] = ServerData_Hatchery.FP__SUMMON_PRICE
        table.insert(l_item_list, t_data)
    end

    return l_item_list
end