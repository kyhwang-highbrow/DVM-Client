-------------------------------------
-- class ServerData_Hatchery
-------------------------------------
ServerData_Hatchery = class({
        m_serverData = 'ServerData',
        m_hatcheryInfo = 'table',   -- 서버에서 넘어오는 정보를 그대로 저장
        m_dirtyHacheryInfo = 'boolean', -- 해처리 정보를 갱신할 필요가 있는지 여부
        m_updatedAt = 'timestamp', -- 해처리 정보를 갱신한 시점의 시간

        m_selectedPickup = 'table', -- 픽업드래곤 선택 정보 ex.{"normal":"120221","unique":"120455"}

        m_isDefinitePickup = 'boolean', -- 다음 픽업 100%

        m_isAutomaticFarewell = 'boolean',

        -- 확률업 소환
        CASH__EVENT_SUMMON_PRICE = 300,
        CASH__EVENT_BUNDLE_SUMMON_PRICE = 3000,

        -- 캐시 소환
        CASH__SUMMON_PRICE = 300,
        CASH__BUNDLE_SUMMON_PRICE = 3000,

        SALE__PERCENTAGE = 0.1,

        -- 우정포인트 소환
        FP__SUMMON_PRICE = 200,
        FP__BUNDLE_SUMMON_PRICE = 100,


        m_pickupStructList = 'list[StructPickup]',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Hatchery:init(server_data)
    self.m_serverData = server_data
    self.m_dirtyHacheryInfo = true
    self.m_updatedAt = nil

    self.m_pickupStructList = {}

    self.m_isAutomaticFarewell = g_settingData:getAutoFarewell('rare') or false
end

-------------------------------------
-- function update_hatcheryInfo
-- @breif
-------------------------------------
function ServerData_Hatchery:update_hatcheryInfo(finish_cb, fail_cb)
    self:checkDirty()

    if (not self.m_dirtyHacheryInfo) then
        finish_cb(self.m_hatcheryInfo)
        return
    end

    self:response_pickupScheduleTable()
    self:request_hatcheryInfo(finish_cb, fail_cb)
end

-------------------------------------
-- function request_hatcheryInfo
-- @breif
-------------------------------------
function ServerData_Hatchery:request_hatcheryInfo(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)

        self:setHacheryInfoTable(ret)

        -- 확률업 드래곤 정보 갱신
        g_eventData:applyChanceUpDragons(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/hatchery_info')
    ui_network:setParam('uid', uid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_summonFriendshipPoint
-- @breif
-------------------------------------
function ServerData_Hatchery:request_summonFriendshipPoint(is_bundle, is_ad, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')
    local is_bundle = is_bundle or false
    local is_ad = is_ad or false

    -- 성공 콜백
    local function success_cb(ret)

        -- fp(우정포인트) 갱신
        g_serverData:networkCommonRespone(ret)

        -- 드래곤들 추가
        g_dragonsData:applyDragonData_list(ret['added_dragons'])

        -- 슬라임들 추가
        g_slimesData:applySlimeData_list(ret['added_slimes'])

        -- 신규 드래곤 new 뱃지 정보 저장
        g_highlightData:saveNewDoidMap()

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/summon/fp')
    ui_network:setParam('uid', uid)
    ui_network:setParam('bundle', is_bundle)
    ui_network:setParam('adv', is_ad)
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
    -- parameters
    local uid = g_userData:get('uid')
    local is_bundle = is_bundle or false
    local is_sale = is_sale or false
    local prev_mileage = g_userData:get('mileage')
	local tutorial = TutorialManager.getInstance():isDoing()
    local auto_farewell_lv = 3

    -- 성공 콜백
    local function success_cb(ret)
        
        -- @analytics
        do
            if (is_bundle) then
                Analytics:trackUseGoodsWithRet(ret, '11회 소환')
                Analytics:firstTimeExperience('DragonSummonCash_11')
            else
                Analytics:trackUseGoodsWithRet(ret, '1회 소환')
            end
        end

        -- cash(캐시) 갱신
        g_serverData:networkCommonRespone(ret)

        -- 추가된 마일리지
        local after_mileage = g_userData:get('mileage')
        local added_mileage = (after_mileage - prev_mileage)
        ret['added_mileage'] = added_mileage

        -- 드래곤들 추가
        local add_dragon_list = self:makeAddedDragonTable(ret['added_dragons'], is_bundle)
        g_dragonsData:applyDragonData_list(add_dragon_list)

        -- 슬라임들 추가
        g_slimesData:applySlimeData_list(ret['added_slimes'])

        -- 신규 드래곤 new 뱃지 정보 저장
        g_highlightData:saveNewDoidMap()

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
	ui_network:setParam('tutorial', tutorial)
    if (self.m_isAutomaticFarewell and is_bundle) then
        ui_network:setParam('auto_goodbye', auto_farewell_lv)
    end
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function makeAddedDragonTable
-- @breif
-------------------------------------
function ServerData_Hatchery:makeAddedDragonTable(org_list, is_bundle)
    local result = {}
    
    if (not self.m_isAutomaticFarewell) or (not is_bundle) then return org_list end

    for key, value in pairs(org_list) do
        if (value['grade'] > 3) then
            result[key] = value
        end
    end

    return result
end

-------------------------------------
-- function request_summonCashEvent
-- @breif
-------------------------------------
function ServerData_Hatchery:request_summonCashEvent(is_bundle, is_sale, finish_cb, fail_cb)
    -- parameters
    local uid = g_userData:get('uid')
    local is_bundle = is_bundle or false
    local is_sale = is_sale or false
    local prev_mileage = g_userData:get('mileage')
    local auto_farewell_lv = 3

    -- 성공 콜백
    local function success_cb(ret)
        
        if (is_bundle) then
            -- @analytics
            Analytics:trackUseGoodsWithRet(ret, '11회 소환')
            Analytics:firstTimeExperience('DragonSummonEvent_11')
        else
            Analytics:trackUseGoodsWithRet(ret, '1회 소환')
        end
            
        -- cash(캐시) 갱신
        g_serverData:networkCommonRespone(ret)

        -- 추가된 마일리지
        local after_mileage = g_userData:get('mileage')
        local added_mileage = (after_mileage - prev_mileage)
        ret['added_mileage'] = added_mileage

        -- 드래곤들 추가
        local add_dragon_list = self:makeAddedDragonTable(ret['added_dragons'], is_bundle)
        g_dragonsData:applyDragonData_list(add_dragon_list)

        -- 슬라임들 추가
        g_slimesData:applySlimeData_list(ret['added_slimes'])

        -- 신규 드래곤 new 뱃지 정보 저장
        g_highlightData:saveNewDoidMap()

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
    if (self.m_isAutomaticFarewell and is_bundle) then
        ui_network:setParam('auto_goodbye', auto_farewell_lv)
    end
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
function ServerData_Hatchery:request_summonPickup(is_bundle, is_sale, finish_cb, fail_cb)
    -- parameters
    local uid = g_userData:get('uid')
    local is_bundle = is_bundle or false
    local is_sale = is_sale or false
    local prev_mileage = g_userData:get('mileage')
    local auto_farewell_lv = 3

    -- 성공 콜백
    local function success_cb(ret)
        
        if (is_bundle) then
            -- @analytics
            Analytics:trackUseGoodsWithRet(ret, '10회 소환')
            Analytics:firstTimeExperience('DragonSummonEvent_10')
        else
            Analytics:trackUseGoodsWithRet(ret, '1회 소환')
        end
            
        -- cash(캐시) 갱신
        g_serverData:networkCommonRespone(ret)

        -- 추가된 마일리지
        local after_mileage = g_userData:get('mileage')
        local added_mileage = (after_mileage - prev_mileage)
        ret['added_mileage'] = added_mileage


        -- 드래곤들 추가
        local add_dragon_list = self:makeAddedDragonTable(ret['added_dragons'], is_bundle)
        g_dragonsData:applyDragonData_list(add_dragon_list)

        -- 슬라임들 추가
        g_slimesData:applySlimeData_list(ret['added_slimes'])

        -- 신규 드래곤 new 뱃지 정보 저장
        g_highlightData:saveNewDoidMap()

        -- 다음 픽업상태 갱신
        if (ret['pickup_next_100'] and tonumber(ret['pickup_next_100'])) then self.m_isDefinitePickup = ret['pickup_next_100'] > 0 end


        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/summon/pickup')
    ui_network:setParam('uid', uid)
    ui_network:setParam('bundle', is_bundle)
    ui_network:setParam('sale', is_sale)
    if (self.m_isAutomaticFarewell and is_bundle) then
        ui_network:setParam('auto_goodbye', auto_farewell_lv)
    end
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
        local t_data = {['egg_id']=700001, ['bundle']=true, ['full_type'] = 'egg_cash_mysteryup_11', ['name']=Str('확률업 10회 소환'), ['desc']=Str('3~5★ 드래곤 부화')}
        t_data['egg_res'] = 'res/item/egg/egg_cash_mysteryup/egg_cash_mysteryup.vrp'
        t_data['price_type'] = 'cash'
        t_data['price'] = ServerData_Hatchery.CASH__EVENT_BUNDLE_SUMMON_PRICE
        table.insert(l_item_list, t_data)

        local t_data = {['egg_id']=700001, ['bundle']=false,  ['full_type'] = 'egg_cash_mysteryup', ['name']=Str('확률업 소환'), ['desc']=Str('3~5★ 드래곤 부화')}
        t_data['egg_res'] = 'res/item/egg/egg_cash_mysteryup/egg_cash_mysteryup.vrp'
        t_data['price_type'] = 'cash'
        t_data['price'] = ServerData_Hatchery.CASH__EVENT_SUMMON_PRICE
        table.insert(l_item_list, t_data)
    end

    do -- 고급 부화
        local t_data = {['egg_id']=700002, ['bundle']=true, ['full_type'] = 'egg_cash_mystery_11', ['name']=Str('고급 부화 10회'), ['desc']=Str('3~5★ 드래곤 부화')}
        t_data['egg_res'] = 'res/item/egg/egg_cash_mystery/egg_cash_mystery.vrp'
        t_data['price_type'] = 'cash'
        t_data['price'] = ServerData_Hatchery.CASH__BUNDLE_SUMMON_PRICE
        table.insert(l_item_list, t_data)

        local t_data = {['egg_id']=700002, ['bundle']=false,  ['full_type'] = 'egg_cash_mystery', ['name']=Str('고급 부화'), ['desc']=Str('3~5★ 드래곤 부화')}
        t_data['egg_res'] = 'res/item/egg/egg_cash_mystery/egg_cash_mystery.vrp'
        t_data['price_type'] = 'cash'
        t_data['price'] = ServerData_Hatchery.CASH__SUMMON_PRICE
        t_data['free_target'] = true --무료 뽑기 대상 알
        table.insert(l_item_list, t_data)
    end

    do -- 우정포인트 부화

        -- 우정포인트 1회 부화는 대표님과 상의해서 제거하기로함 sgkim 2017.06.16
        --local t_data = {['egg_id']=700003, ['bundle']=true, ['full_type'] = 'egg_friendship_10', ['name']=Str('우정 부화 10회'), ['desc']=Str('1~3★ 드래곤 부화')}
        --t_data['egg_res'] = 'res/item/egg/egg_friendship/egg_friendship.vrp'
        --t_data['price_type'] = 'fp'
        --t_data['price'] = ServerData_Hatchery.FP__BUNDLE_SUMMON_PRICE
        --table.insert(l_item_list, t_data)

        local t_data = {['egg_id']=700003, ['bundle']=false,  ['full_type'] = 'egg_friendship', ['name']=Str('우정 부화'), ['desc']=Str('★1~3 드래곤 부화')}
        t_data['egg_res'] = 'res/item/egg/egg_friendship/egg_friendship.vrp'
        t_data['price_type'] = 'fp'
        t_data['price'] = ServerData_Hatchery.FP__SUMMON_PRICE
        table.insert(l_item_list, t_data)
    end

    return l_item_list
end

-------------------------------------
-- function getGachaList
-- @breif 이제 더이상 에그 리스트가 아니다
-------------------------------------
function ServerData_Hatchery:getGachaList()
    local l_item_list = {}
    -- 이벤트 데이터

    --[[
    do -- 확률업
        local t_data = {
            ['name'] = Str('확률업 10+1회 소환'),
            ['egg_id'] = 700001, 
            ['egg_res'] = 'res/item/egg/egg_cash_mysteryup/egg_cash_mysteryup.vrp',
            ['ui_type'] = 'event11',
            ['bundle'] = true,
            ['price_type'] = 'cash',
            ['price'] = ServerData_Hatchery.CASH__EVENT_BUNDLE_SUMMON_PRICE,
        }

        table.insert(l_item_list, t_data)

        local t_data = {
            ['name'] = Str('확률업 소환'),
            ['egg_id'] = 700001, 
            ['egg_res'] = 'res/item/egg/egg_cash_mysteryup/egg_cash_mysteryup.vrp',
            ['ui_type'] = 'event',
            ['bundle'] = false,
            ['price_type'] = 'cash',
            ['price'] = ServerData_Hatchery.CASH__EVENT_SUMMON_PRICE,
        }
        table.insert(l_item_list, t_data)
    end]]

    do -- 고급 부화
        local t_data = {
            ['name'] = Str('고급 소환 10회'),
            ['egg_id'] = 700002, 
            ['egg_res'] = 'res/item/egg/egg_cash_mystery/egg_cash_mystery.vrp',
            ['ui_type'] = 'cash11',
            ['bundle'] = true,
            ['price_type'] = 'cash',
            ['price'] = ServerData_Hatchery.CASH__BUNDLE_SUMMON_PRICE,
        }
        table.insert(l_item_list, t_data)

        local t_data = {
            ['name'] = Str('고급 소환'),
            ['egg_id'] = 700002, 
            ['egg_res'] = 'res/item/egg/egg_cash_mystery/egg_cash_mystery.vrp',
            ['ui_type'] = 'cash',
            ['bundle'] = false,
            ['price_type'] = 'cash',
            ['price'] = ServerData_Hatchery.CASH__SUMMON_PRICE,
            ['free_target'] = true --무료 뽑기 대상 알
        }
        table.insert(l_item_list, t_data)
    end

    do -- 우정포인트 부화
        local t_data = {
            ['name'] = Str('우정 소환'),
            ['egg_id'] = 700003, 
            ['egg_res'] = 'res/item/egg/egg_friendship/egg_friendship.vrp',
            ['ui_type'] = 'fp',
            ['bundle'] = false,
            ['price_type'] = 'fp',
            ['price'] = ServerData_Hatchery.FP__SUMMON_PRICE,
        }
        table.insert(l_item_list, t_data)

        local t_data = {
            ['name'] = Str('우정 소환'),
            ['egg_id'] = 700003, 
            ['egg_res'] = 'res/item/egg/egg_friendship/egg_friendship.vrp',
            ['ui_type'] = 'fp_ad',
            ['bundle'] = false,
            ['is_ad'] = true,
        }
        table.insert(l_item_list, t_data)
    end

    do -- 커스텀 픽업 소환
        local t_data = {
            ['name'] = Str('확률업 10회 소환'),
            ['egg_id'] = 700001, 
            ['egg_res'] = 'res/item/egg/egg_cash_mysteryup/egg_cash_mysteryup.vrp',
            ['ui_type'] = 'event11',
            ['bundle'] = true,
            ['price_type'] = 'cash',
            ['price'] = ServerData_Hatchery.CASH__EVENT_BUNDLE_SUMMON_PRICE,
        }

        table.insert(l_item_list, t_data)

        local t_data = {
            ['name'] = Str('확률업 소환'),
            ['egg_id'] = 700001, 
            ['egg_res'] = 'res/item/egg/egg_cash_mysteryup/egg_cash_mysteryup.vrp',
            ['ui_type'] = 'event',
            ['bundle'] = false,
            ['price_type'] = 'cash',
            ['price'] = ServerData_Hatchery.CASH__EVENT_SUMMON_PRICE,
        }
        table.insert(l_item_list, t_data)
    end

    return l_item_list
end

-------------------------------------
-- function setHacheryInfoTable
-- @breif
-------------------------------------
function ServerData_Hatchery:setHacheryInfoTable(t_data)
    self.m_hatcheryInfo = t_data
    --{
	--    "event": {
	--	    "event": "summon_event",
	--	    "begindate": 1496311200000,
	--	    "enddate": 1500289200000
	--    },
	--    "summon_free_time": 1497691896171,
	--    "mileage": 1138,
	--    "highlight": {
	--	    "summon_free": false
	--    },
	--    "status": 0,
	--    "message": "success"
    --    "chance_up_enddate":{
    --        "chance_up_1_enddate":20191115
    --     }
    --    "chance_up":{
    --      "chance_up_1":121002
    --  },
    --}

    if (t_data['summon_pickup_info']) then self.m_selectedPickup = t_data['summon_pickup_info'] end
    if (t_data['pickup_next_100'] and tonumber(t_data['pickup_next_100'])) then self.m_isDefinitePickup = t_data['pickup_next_100'] > 0 end

    self.m_updatedAt = Timer:getServerTime()
    self.m_dirtyHacheryInfo = false
    
end

-------------------------------------
-- function getMileageAnimationKey
-- @breif 마일리지 상태에 따른 애니메이션 키 반환 (부화소, 가차 결과 UI)
-------------------------------------
function ServerData_Hatchery:getMileageAnimationKey()
    local L_MILEAGE_INFO = {
        {
            ['mileage'] = 50,
            ['egg_id'] = 703004
        },
        {
            ['mileage'] = 170,
            ['egg_id'] = 703002
        },
        {
            ['mileage'] = 260,
            ['egg_id'] = 703019
        },
        {
            ['mileage'] = 700,
            ['egg_id'] = 703003
        },
        {
            ['mileage'] = 1500,
            ['egg_id'] = 703005
        },
    }
    local ani_key_1 = 'mileage_0'
    local ani_key_2 = 'reward_0'

    local mileage = g_userData:get('mileage')
    for i = #L_MILEAGE_INFO, 1, -1 do
        local t_mileage = L_MILEAGE_INFO[i]
        local need_mileage = t_mileage['mileage']

        -- 마일리지 충분하다면 해당 애니메이션 키 반환
        if (need_mileage <= mileage) then
            ani_key_1 = string.format('mileage_%d', i)
            ani_key_2 = string.format('reward_%d', i)
            break            
        end
    end

    return ani_key_1, ani_key_2
end

-------------------------------------
-- function getSummonFreeInfo
-- @breif
-------------------------------------
function ServerData_Hatchery:getSummonFreeInfo(with_str)

    -- 정보 갱신이 필요한 상태이므로 false로 간주
    if (self.m_dirtyHacheryInfo) then
        return false, ''
    end

    if (not self.m_hatcheryInfo) or (not self.m_hatcheryInfo['summon_free_time']) then
        --cclog('# ServerData_Hatchery:getSummonFreeTime() 정보가 없음')
        return
    end

    local summon_free_time = (self.m_hatcheryInfo['summon_free_time'] / 1000)
    local server_time = Timer:getServerTime()

    local can_free = false
    local ret_str = ''
    if (summon_free_time == 0) then
        can_free = true

    elseif (server_time < summon_free_time) then
        can_free = false
        if with_str then
            local gap = (summon_free_time - server_time)
            local showSeconds = true
            local firstOnly = false
            local text = datetime.makeTimeDesc(gap, showSeconds, firstOnly)
            ret_str = Str('{1} 후 무료', text)
        end

    else
        can_free = true
    end

    return can_free, ret_str
end

-------------------------------------
-- function checkDirty
-------------------------------------
function ServerData_Hatchery:checkDirty()
    -- 이미 dirty상태일 경우
    if (self.m_dirtyHacheryInfo) then
        return
    end

    -- 갱신 시간이 없을 경우
    if (not self.m_updatedAt) then
        self.m_dirtyHacheryInfo = true
        return
    end

    -- 단위 (초)
    local server_time = Timer:getServerTime()
    local refresh_sec = 10 * 60 -- 10분마다 갱신
    if ((self.m_updatedAt + refresh_sec) <= server_time) then
        self.m_dirtyHacheryInfo = true
        return
    end

    -- Hatchery Info가 비었을 경우 dirty
    if (not self.m_hatcheryInfo) then
        self.m_dirtyHacheryInfo = true
        return
    end

end

-------------------------------------
-- function setDirty
-------------------------------------
function ServerData_Hatchery:setDirty()
    self.m_dirtyHacheryInfo = true
end


-------------------------------------
-- function checkHighlight
-------------------------------------
function ServerData_Hatchery:checkHighlight()
    -- [소환] 탭 무료 뽑기 가능
    -- [부화] 뽑을 알
    -- [인연] 뽑기 가능한 
    -- [조합] 봅기 가능한

    local highlight = false

    local t_highlight = {}
    t_highlight['summon'] = false
    t_highlight['incubate'] = false
    t_highlight['relation'] = false
    t_highlight['combine'] = false
    --[[
    -- @jhakim 소환/부화/인연 노티 제거
    do -- 소환
        if (self:getSummonFreeInfo()) then
            t_highlight['summon'] = true
            highlight = true
        end
    end

    do -- 부화
        local t_ret = g_eggsData:getEggListForUI()
        if (0 < table.count(t_ret)) then
            t_highlight['incubate'] = true
            highlight = true
        end
    end

    do -- 인연
       local count = self:checkRelationHighlight() 
       if (0 < count) then
            t_highlight['relation'] = true
            highlight = true
       end
    end
    --]]
    do -- 조합
       local count = self:checkCombineHighlight()
       if (0 < count) then
            t_highlight['combine'] = true
            highlight = true
       end
    end

    return highlight, t_highlight
end

-------------------------------------
-- function checkRelationHighlight
-------------------------------------
function ServerData_Hatchery:checkRelationHighlight()
    local table_dragon = TableDragon()

    local function condition_func(t_table)
        if (not t_table['relation_point']) then
            return false
        end
        
        local relation_point = tonumber(t_table['relation_point'])
        if (not relation_point) then
            return false
        end

        if (relation_point <= 0) then
            return false
        end

        local did = t_table['did']
        local cur_rpoint = g_bookData:getRelationPoint(did)
        if (cur_rpoint <= 0) then
            return false
        end

        if (cur_rpoint < relation_point) then
            return false
        end

        return true
    end

    local l_dragon_list = table_dragon:filterTable_condition(condition_func)

    local count = table.count(l_dragon_list)
    return count
end

-------------------------------------
-- function checkCombineHighlight
-------------------------------------
function ServerData_Hatchery:checkCombineHighlight()
    local table_dragon_combine = TableDragonCombine()

    local highlight_cnt = 0

    for i,v in pairs(table_dragon_combine.m_orgTable) do
        local did = v['did']
        local mtrl_cnt, satisfy_cnt = self:combineMaterialInfo(did)

        if (4 <= satisfy_cnt) then
            highlight_cnt = (highlight_cnt + 1)
        end
    end

    return highlight_cnt
end

-------------------------------------
-- function combineMaterialInfo
-------------------------------------
function ServerData_Hatchery:combineMaterialInfo(did)
    local table_dragon_combine = TableDragonCombine()
    local t_dragon_combine = table_dragon_combine:get(did)

    local l_dragon = g_dragonsData:getDragonsListRef()


    local l_cnt = {}
    local l_satisfy = {}
    local did1 = t_dragon_combine['material_1']
    local did2 = t_dragon_combine['material_2']
    local did3 = t_dragon_combine['material_3']
    local did4 = t_dragon_combine['material_4']

    local req_grade = t_dragon_combine['material_grade']
    local req_grade_max_lv = TableGradeInfo:getMaxLv(req_grade)
    local req_evolution = t_dragon_combine['material_evolution']
    

    -- 단순 보유와 조건 충족을 체크해야함
    for i,v in pairs(l_dragon) do
        -- did가 있을 경우
        if isExistValue(v:getDid(), did1, did2, did3, did4) then
            l_cnt[v:getDid()] = true

            if (v:getGrade() < req_grade) then
                -- 등급이 낮아서 불충족
            elseif (v:getGrade() == req_grade) and (v:getLv() < req_grade_max_lv) then
                -- 최대 레벨이 낮아서 불충족 (필요 등급의 max레벨이거나 등급 자체가 더 높아야함)
            elseif (v:getEvolution() < req_evolution) then
                -- 진화도가 낮아서 불충족
            else
                l_satisfy[v:getDid()] = true
            end
        end
    end

    local mtrl_cnt = table.count(l_cnt)
    local satisfy_cnt = table.count(l_satisfy)

    return mtrl_cnt, satisfy_cnt, l_satisfy
end

-------------------------------------
-- function combineMaterialList
-------------------------------------
function ServerData_Hatchery:combineMaterialList(did)
    local table_dragon_combine = TableDragonCombine()
    local t_dragon_combine = table_dragon_combine:get(did)

    local l_dragon = g_dragonsData:getDragonsListRef()


    local l_mtrl = {}
    local did1 = t_dragon_combine['material_1']
    local did2 = t_dragon_combine['material_2']
    local did3 = t_dragon_combine['material_3']
    local did4 = t_dragon_combine['material_4']

    local req_grade = t_dragon_combine['material_grade']
    local req_grade_max_lv = TableGradeInfo:getMaxLv(req_grade)
    local req_evolution = t_dragon_combine['material_evolution']
    

    -- 단순 보유와 조건 충족을 체크해야함
    for i,v in pairs(l_dragon) do
        -- did가 있을 경우
        if isExistValue(v:getDid(), did1, did2, did3, did4) then
            l_mtrl[v['id']] = clone(v)
        end
    end

    return l_mtrl
end


-------------------------------------
-- function request_dragonCombine
-- @breif
-------------------------------------
function ServerData_Hatchery:request_dragonCombine(did, doids, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)

        -- gold(골드) 갱신
        g_serverData:networkCommonRespone(ret)

        -- 드래곤들 추가
        g_dragonsData:applyDragonData_list(ret['added_dragons'])

        -- 재료로 사용된 드래곤 삭제
        if ret['deleted_dragons_oid'] then
            for _,doid in pairs(ret['deleted_dragons_oid']) do
                g_dragonsData:delDragonData(doid)
            end
        end

        -- 신규 드래곤 new 뱃지 정보 저장
        g_highlightData:saveNewDoidMap()

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/combine')
    ui_network:setParam('uid', uid)
    ui_network:setParam('did', did)
    ui_network:setParam('doids', doids)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function getChanceUpEndDate
-- @breif 다음 확률업까지 남은 시간
-------------------------------------
function ServerData_Hatchery:getChanceUpEndDate()
    if (not self.m_hatcheryInfo) then
        return 
    end

    if (not self.m_hatcheryInfo['chance_up_enddate']) then
        return 
    end

    if (not self.m_hatcheryInfo['chance_up_enddate']['chance_up_1_enddate']) then
        return
    end

    local chance_up_end_date = self.m_hatcheryInfo['chance_up_enddate']['chance_up_1_enddate']
    local date_format = 'yyyymmdd HH:MM:SS'
    local parser = pl.Date.Format(date_format)
    chance_up_end_date = chance_up_end_date .. ' 23:59:59'

    local end_date = parser:parse(chance_up_end_date)
    if (not end_date) then
        return
    end

    if (not end_date['time']) then
        return
    end

    local end_time = end_date['time']
    local curr_time = Timer:getServerTime()
    if (end_time > curr_time) then
        local remain_time = end_time - curr_time
        local time_text = datetime.makeTimeDesc(remain_time, true)
        return Str('{1} 남음', time_text)
    end
end



-------------------------------------
-- function request_selectPickup
-- @breif
-------------------------------------
function ServerData_Hatchery:request_selectPickup(did, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        if (ret['summon_pickup_info']) then self.m_selectedPickup = ret['summon_pickup_info'] end

        if finish_cb then
            finish_cb()
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/select_pickup')
    ui_network:setParam('uid', uid)
    ui_network:setParam('did', did)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function getSelectedPickup
-- @breif
-------------------------------------
function ServerData_Hatchery:getSelectedPickup()
    local normal 
    local unique

    if (self.m_selectedPickup) then 
        normal = self.m_selectedPickup['normal'] 
        unique = self.m_selectedPickup['unique'] 
    end

    return tonumber(normal), tonumber(unique)
end

-------------------------------------
-- function isPickupReady
-- @breif 픽업 드래곤들 선택이 완료 되었는가?
-------------------------------------
function ServerData_Hatchery:isPickupReady()
    local normal 
    local unique

    if (self.m_selectedPickup) then 
        normal = self.m_selectedPickup['normal'] 
        unique = self.m_selectedPickup['unique'] 
    end

    return (normal ~= nil) and (unique ~= nil)
end

-------------------------------------
-- function isPickupEmpty
-- @breif 픽업 드래곤 선택 하나도 안되어 있는가?
-------------------------------------
function ServerData_Hatchery:isPickupEmpty()
    local normal 
    local unique

    if (self.m_selectedPickup) then 
        normal = self.m_selectedPickup['normal'] 
        unique = self.m_selectedPickup['unique'] 
    end

    return (normal == nil) and (unique == nil)
end

-------------------------------------
-- function switchHatcheryAutoFarewell
-- @breif 픽업 드래곤 선택 하나도 안되어 있는가?
-------------------------------------
function ServerData_Hatchery:switchHatcheryAutoFarewell(bReset)
    if (bReset) then
        self.m_isAutomaticFarewell = false
    else
        self.m_isAutomaticFarewell = not self.m_isAutomaticFarewell
    end
end


-------------------------------------
-- function response_pickupScheduleTable
-------------------------------------
function ServerData_Hatchery:response_pickupScheduleTable()
    local pickup_schedule_table = TABLE:get('table_pickup_schedule')

    for key, data in pairs(pickup_schedule_table) do
        if checkTimeValid(data['start_date'], data['end_date'], 'yyyy-mm-dd HH:MM:SS') then
            table.insert(self.m_pickupStructList, StructPickup(data))
        end
    end
end


-------------------------------------
-- function getSelectedPickupList
-------------------------------------
function ServerData_Hatchery:getSelectedPickupList()
    return self.m_pickupStructList 
end

-------------------------------------
-- function getPickupStructNumber
-------------------------------------
function ServerData_Hatchery:getPickupStructNumber()
    return #self.m_pickupStructList
end

