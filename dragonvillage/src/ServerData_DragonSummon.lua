-------------------------------------
-- class ServerData_DragonSummon
-------------------------------------
ServerData_DragonSummon = class({
        m_serverData = 'ServerData',

        -- 서버의 시스템 정보
        m_dragonSummonTable = 'table', -- 서버로부터 소환 리스트를 받아옴
        m_mileageRewardInfo = 'table',

        -- 유저의 진행 정보
        m_userSummonInfo = 'table',
        m_mileage = 'number', -- 마일리지 보유량

        -- 무료 드래곤 소환 정보
        m_freeSummonInfo = 'StructFreeDragonSummonInfo',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_DragonSummon:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function request_dragonSummonInfo
-------------------------------------
function ServerData_DragonSummon:request_dragonSummonInfo(finish_cb)

    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        self:organizeData(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/summon/info')
    ui_network:setParam('uid', uid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end


-------------------------------------
-- function organizeData
-------------------------------------
function ServerData_DragonSummon:organizeData(ret)    
    self.m_dragonSummonTable = ret['dragon_summon_table']
    self.m_mileageRewardInfo = ret['mileage_reward_info']

    -- 마일리지가 높은 순서대로 정렬
    local function sort_func(a, b)
        return a['mileage'] > b['mileage']
    end
    table.sort(self.m_mileageRewardInfo, sort_func)

    self.m_userSummonInfo = table.listToMap(ret['user_summon_info'], 'dsmid')
    self.m_mileage = ret['mileage']

    -- 무료 뽑기 데이터 갱신
    if ret['free_summon_info'] then
        self.m_freeSummonInfo = StructFreeDragonSummonInfo(ret['free_summon_info'])
    end
end

-------------------------------------
-- function getMileageRewardInfo
-------------------------------------
function ServerData_DragonSummon:getMileageRewardInfo(mileage)
    for i,v in pairs(self.m_mileageRewardInfo) do
        if (v['mileage'] == mileage) then
            return v
        end
    end

    return nil
end

-------------------------------------
-- function openDragonSummon
-------------------------------------
function ServerData_DragonSummon:openDragonSummon()
    local function finish_cb()
        UI_DragonSummon()
    end

    self:request_dragonSummonInfo(finish_cb)
end

-------------------------------------
-- function getDisplaySummonList
-------------------------------------
function ServerData_DragonSummon:getDisplaySummonList()
   local l_list = {}
   
   

   for i,v in pairs(self.m_dragonSummonTable) do
        local data = self:checkInvalidSummon(v)
        if data then
            l_list[data['dsmid']] = clone(data)
        end
   end

   return l_list
end

-------------------------------------
-- function checkInvalidSummon
-------------------------------------
function ServerData_DragonSummon:checkInvalidSummon(v)
    local server_time = Timer:getServerTime()

    local start_date = Timer:strToTimeStamp(v['start_date'])
    local end_date = Timer:strToTimeStamp(v['end_date'])

    -- 판매가 시작되지 않은상품
    if (server_time < start_date) then
        return
    end

    -- 판매가 종료된 상품
    if (end_date < server_time) then
        return
    end

    local dsmid = v['dsmid']
    local t_user_info = self:getUserSummonInfo(dsmid)

    -- 구매 횟수 제한이 초과되었을 경우
    if (v['limit_purchase']~='') then
        if (v['limit_purchase'] <= t_user_info['purchase_cnt']) then
            return
        end
    end

        -- 할인 이벤트 확인
    v['disc_event_active'] = false
    if (v['disc_start_date'] ~= '') and (v['disc_end_date'] ~= '') then
        local disc_start_date = Timer:strToTimeStamp(v['disc_start_date'])
        local disc_end_date = Timer:strToTimeStamp(v['disc_end_date'])

        -- 할인 이벤트 중
        if (disc_start_date <= server_time) and (server_time <= disc_end_date) then

            -- 이벤트 상품 구매 횟수
            if (v['disc_limit'] == '') or (t_user_info['disc_purchase_cnt'] < v['disc_limit']) then
                v['disc_event_active'] = true
            end
        end
    end

    v['purchase_cnt'] = t_user_info['purchase_cnt']
    v['disc_purchase_cnt'] = t_user_info['disc_purchase_cnt']

    return v
end

-------------------------------------
-- function request_dragonSummon
-------------------------------------
function ServerData_DragonSummon:request_dragonSummon(dsmid, type, price_type, price, is_discount, is_free, finish_cb)

    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        -- gold, cash
        g_serverData:networkCommonRespone(ret)

        -- 드래곤들 추가
        g_dragonsData:applyDragonData_list(ret['added_dragons'])

        -- 마일리지 갱신
        self.m_mileage = ret['mileage']

        -- 무료 뽑기 데이터 갱신
        if ret['free_summon_info'] then
            self.m_freeSummonInfo = StructFreeDragonSummonInfo(ret['free_summon_info'])
        end

        local user_info = self:getUserSummonInfo(dsmid)
        user_info['purchase_cnt'] = (user_info['purchase_cnt'] + 1)
        user_info['disc_purchase_cnt'] = (user_info['disc_purchase_cnt'] + 1)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/summon')
    ui_network:setParam('uid', uid)
    ui_network:setParam('dsmid', dsmid)
    ui_network:setParam('type', type)
    ui_network:setParam('price_type', price_type)
    ui_network:setParam('price', price)
    ui_network:setParam('is_free', is_free)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function getUserSummonInfo
-------------------------------------
function ServerData_DragonSummon:getUserSummonInfo(dsmid)
    if (not self.m_userSummonInfo[dsmid]) then
        local t_data = {}
        t_data['disc_purchase_cnt'] = 0
        t_data['purchase_cnt'] = 0
        self.m_userSummonInfo[dsmid] = t_data
    end
    return self.m_userSummonInfo[dsmid]
end


-------------------------------------
-- function request_mileageReward
-------------------------------------
function ServerData_DragonSummon:request_mileageReward(finish_cb)
    local mileage = self.m_mileage

    -- 캐시가 충분히 있는지 체크
    if (mileage < 20) then
        MakeSimplePopup(POPUP_TYPE.OK, Str('마일리지 획득정도에 따라 다양한 보상을 얻을 수 있습니다.\n최소 20마일리지가 누적되어야 보상을 받을 수 있습니다.'))
        return
    end

    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        -- 공통 응답 처리 (골드 갱신을 위해)
        g_serverData:networkCommonRespone(ret)

        -- 마일리지 갱신
        self.m_mileage = ret['mileage']

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/mileage/reward')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end


-------------------------------------
-- function getFreeDragonSummonType
-------------------------------------
function ServerData_DragonSummon:getFreeDragonSummonType(dsmid)
    return self.m_freeSummonInfo:getFreeDragonSummonType(dsmid)
end

-------------------------------------
-- function getFreeDragonSummonTimeText
-------------------------------------
function ServerData_DragonSummon:getFreeDragonSummonTimeText(free_type)
    return self.m_freeSummonInfo:getFreeDragonSummonTimeText(free_type)
end

-------------------------------------
-- function canFreeDragonSummon
-------------------------------------
function ServerData_DragonSummon:canFreeDragonSummon(free_type)
    return self.m_freeSummonInfo:canFreeDragonSummon(free_type)
end