-------------------------------------
-- class ServerData_Hatchery
-------------------------------------
ServerData_Hatchery = class({
        m_serverData = 'ServerData',
        m_hatcheryInfo = 'table',   -- 서버에서 넘어오는 정보를 그대로 저장
        m_dirtyHacheryInfo = 'boolean', -- 해처리 정보를 갱신할 필요가 있는지 여부
        m_updatedAt = 'timestamp', -- 해처리 정보를 갱신한 시점의 시간

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
    self.m_dirtyHacheryInfo = true
    self.m_updatedAt = nil
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
        local t_data = {['egg_id']=700001, ['bundle']=true, ['full_type'] = 'egg_cash_mysteryup_11', ['name']=Str('확률업 10+1회 소환'), ['desc']=Str('3~5★ 드래곤 부화')}
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
        local t_data = {['egg_id']=700002, ['bundle']=true, ['full_type'] = 'egg_cash_mystery_11', ['name']=Str('고급 부화 10+1회'), ['desc']=Str('3~5★ 드래곤 부화')}
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

        local t_data = {['egg_id']=700003, ['bundle']=false,  ['full_type'] = 'egg_friendship', ['name']=Str('우정 부화'), ['desc']=Str('1~3★ 드래곤 부화')}
        t_data['egg_res'] = 'res/item/egg/egg_friendship/egg_friendship.vrp'
        t_data['price_type'] = 'fp'
        t_data['price'] = ServerData_Hatchery.FP__SUMMON_PRICE
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
    --}

    
    self.m_updatedAt = Timer:getServerTime()
    self.m_dirtyHacheryInfo = false
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
        cclog('# ServerData_Hatchery:getSummonFreeTime() 정보가 없음')
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
-- function openHatcheryUI
-------------------------------------
function ServerData_Hatchery:openHatcheryUI(close_cb)
    local function finish_cb()
        local ui = UI_Hatchery()
        ui:setCloseCB(close_cb)
    end

    self:update_hatcheryInfo(finish_cb)
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