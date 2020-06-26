-------------------------------------
-- class ServerData_Fevertime
-- @brief 핫타임 (개발 코드 fevertime)
--        기존 핫타임이 있는 상태에서 개선된 핫타임
-- @instance g_fevertimeData
-------------------------------------
ServerData_Fevertime = class({
        m_serverData = 'ServerData',
        m_lFevertime = 'table',
        m_lFevertimeSchedule = 'table',
        m_lFevertimeGlobal = 'table',

        m_expirationTimestamp = 'timestamp',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Fevertime:init(server_data)
    self.m_serverData = server_data
    self.m_lFevertime = {}
    self.m_lFevertimeSchedule = {}
    self.m_lFevertimeGlobal = {}
end


-------------------------------------
-- function request_fevertimeInfo
-------------------------------------
function ServerData_Fevertime:request_fevertimeInfo(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)

        -- server_info 정보를 갱신
        g_serverData:networkCommonRespone(ret)

        self:applyFevertimeData(ret['fevertime'])
        self:applyFevertimeSchedule(ret['fevertime_schedule'])
        self:applyFevertimeGlobal(ret['fevertime_global'])
        self:setExpirationTimestamp()

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/fevertime/info')
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
-- function request_fevertimeActive
-- @brief 일일 핫타임 활성화
-------------------------------------
function ServerData_Fevertime:request_fevertimeActive(id, finish_cb, fail_cb)
-- 유저 ID
    local uid = g_userData:get('uid')

    -- 콜백
    local function success_cb(ret)

        -- server_info 정보를 갱신
        g_serverData:networkCommonRespone(ret)

        self:applyFevertimeData(ret['fevertime'])
        self:applyFevertimeSchedule(ret['fevertime_schedule'])
        self:applyFevertimeGlobal(ret['fevertime_global'])
        self:setExpirationTimestamp()

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/fevertime/active')
    ui_network:setParam('uid', uid)
    ui_network:setParam('id', id)
    ui_network:setSuccessCB(success_cb)
	ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
	--ui_network:hideBGLayerColor()
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function applyFevertimeAtTitleAPI
-------------------------------------
function ServerData_Fevertime:applyFevertimeAtTitleAPI(ret)
    self:applyFevertimeData(ret['fevertime'])
    self:applyFevertimeSchedule(ret['fevertime_schedule'])
    self:applyFevertimeGlobal(ret['fevertime_global'])
    self:setExpirationTimestamp()
end

-------------------------------------
-- function applyFevertimeData
-------------------------------------
function ServerData_Fevertime:applyFevertimeData(t_data)
    if (t_data == nil) then
        return
    end

    self.m_lFevertime = {}
    for i,v in pairs(t_data) do
        local struct_fevertime = StructFevertime:create_forFevertime(v)
        table.insert(self.m_lFevertime, struct_fevertime)
    end

end

-------------------------------------
-- function applyFevertimeSchedule
-------------------------------------
function ServerData_Fevertime:applyFevertimeSchedule(t_data)
    if (t_data == nil) then
        return
    end

    self.m_lFevertimeSchedule = {}
    for i,v in pairs(t_data) do
        if (v['used'] == nil) or (v['used'] == false) then
            local struct_fevertime = StructFevertime:create_forFevertimeSchedule(v)
            table.insert(self.m_lFevertimeSchedule, struct_fevertime)
        end
    end
end

-------------------------------------
-- function applyFevertimeGlobal
-------------------------------------
function ServerData_Fevertime:applyFevertimeGlobal(t_data)
    if (t_data == nil) then
        return
    end

    self.m_lFevertimeGlobal = {}
    for i,v in pairs(t_data) do
        local struct_fevertime = StructFevertime:create_forFevertimeGlobal(v)
        table.insert(self.m_lFevertimeGlobal, struct_fevertime)
    end
end

-------------------------------------
-- function getAllStructFevertimeList
-------------------------------------
function ServerData_Fevertime:getAllStructFevertimeList()
    local l_ret = {}

    table.addList(l_ret, self.m_lFevertime)
    table.addList(l_ret, self.m_lFevertimeSchedule)
    table.addList(l_ret, self.m_lFevertimeGlobal)

    return l_ret
end

-------------------------------------
-- function isActiveDailyFevertimeByType
-- @brief 활성화된 일일 핫타임
-------------------------------------
function ServerData_Fevertime:isActiveDailyFevertimeByType(type)
    for i,struct_fevertime in pairs(self.m_lFevertime) do

        -- 일일 핫타임
        if (struct_fevertime:isDailyHottime() == true) then

            -- 활성화
            if (struct_fevertime:isActiveFevertime() == true) then
                
                -- 타입이 같을 경우
                if (struct_fevertime:getFevertimeType() == type) then
                    return true
                end
            end
        end
    end

    return false
end

-------------------------------------
-- function setExpirationTimestamp
-------------------------------------
function ServerData_Fevertime:setExpirationTimestamp()
    if (self.m_expirationTimestamp == nil) then
        local curr_time = Timer:getServerTime_Milliseconds()
        self.m_expirationTimestamp = curr_time
    end
    

    -- 오늘 자정
    local midnight = Timer:getServerTime_midnight() * 1000
    local expiration_timestamp = self.m_expirationTimestamp

    -- 핫타임 중 시작, 종료 시간 중 빠른 시간으로
    local l_list = self:getAllStructFevertimeList()
    local _time = nil
    for i, struct_fevertime in pairs(l_list) do
        local start_date = struct_fevertime:getStartDateForSort()
        if start_date and (start_date ~= 0) and (expiration_timestamp < start_date) then
            if (_time == nil) or (start_date < _time) then
                _time = start_date
            end
        end

        local end_date = struct_fevertime:getEndDateForSort()
        if end_date and (end_date ~= 0) and (expiration_timestamp < end_date) then
            if (_time == nil) or (end_date < _time) then
                _time = end_date
            end
        end
    end

    self.m_expirationTimestamp = math_min(midnight, _time)
end

-------------------------------------
-- function needToUpdateFevertimeInfo
-------------------------------------
function ServerData_Fevertime:needToUpdateFevertimeInfo()
    local curr_time = Timer:getServerTime_Milliseconds()

    if (self.m_expirationTimestamp < curr_time) then
        return true
    else
        return false
    end
end

-------------------------------------
-- function isHighlightFevertime
-- @brief 알림표시가 필요한 항목이 몇개인지 체크해서 1개 이상이면 true 리턴
--        마을에서 핫타임 버튼에 표시
-- @return boolean
-------------------------------------
function ServerData_Fevertime:isHighlightFevertime()
    local noti_count = 0

    -- 일일 핫타임 활성화 가능한 경우
    for i,struct_fevertime in pairs(self.m_lFevertimeSchedule) do
        if (struct_fevertime:isTodayDailyHottime() == true) then
            noti_count = (noti_count + 1)
        end
    end
    
    -- 핫타임(활성화된 일일 핫타임)
    for i,struct_fevertime in pairs(self.m_lFevertime) do
        if (struct_fevertime:isActiveFevertime() == true) then
            noti_count = (noti_count + 1)
        end
    end

    -- 글로벌 핫타임
    for i,struct_fevertime in pairs(self.m_lFevertimeGlobal) do
        if (struct_fevertime:isActiveFevertime() == true) then
            noti_count = (noti_count + 1)
        end
    end

    return (0 < noti_count)
end


-------------------------------------
-- function isActiveFevertimeByType
-- @brief 해당 타입의 핫타임이 활성화 여부, 값, StructFevertime리스트
-- @return bool, number, table(list)
-------------------------------------
function ServerData_Fevertime:isActiveFevertimeByType(type)
    
    local is_active = false
    local value = 0
    local l_ret = {}

    local l_list = self:getAllStructFevertimeList()
    for i, struct_fevertime in pairs(l_list) do
        if (struct_fevertime:getFevertimeType() == type) then
            if (struct_fevertime:isActiveFevertime() == true) then
                is_active = true
                value = (value + struct_fevertime:getFevertimeValue())
                table.insert(l_ret, clone(struct_fevertime))
            end
        end
    end
    return is_active, value, l_ret
end

-------------------------------------
-- function isActiveFevertime_adventure
-- @brief 모험모드 핫타임
-- @return boolean
-------------------------------------
function ServerData_Fevertime:isActiveFevertime_adventure()
    local is_active_exp_up = self:isActiveFevertimeByType('exp_up') -- 모험 드래곤 경험치 증가
    local is_active_gold_up = self:isActiveFevertimeByType('gold_up') -- 모험 골드 증가
    local is_active_ad_st_dc = self:isActiveFevertimeByType('ad_st_dc') -- 모험 날개 할인

    return is_active_exp_up or is_active_gold_up or is_active_ad_st_dc
end

-------------------------------------
-- function isActiveFevertime_dungeonGdUp
-- @brief 거대용 던전 핫타임
-- @return boolean
-------------------------------------
function ServerData_Fevertime:isActiveFevertime_dungeonGdUp()
    local is_active_dg_gd_item_up = self:isActiveFevertimeByType('dg_gd_item_up') -- 거대용 던전 진화 재료 증가

    return is_active_dg_gd_item_up
end

-------------------------------------
-- function isActiveFevertime_dungeonGtUp
-- @brief 거목 던전 핫타임
-- @return boolean
-------------------------------------
function ServerData_Fevertime:isActiveFevertime_dungeonGtUp()
    local is_active_dg_gt_item_up = self:isActiveFevertimeByType('dg_gt_item_up') -- 거목 던전 친밀도 열매 증가

    return is_active_dg_gt_item_up
end

-------------------------------------
-- function isActiveFevertime_summonLegendUp
-- @brief 전설 드래곤 소환 확률 증가 (sm_legend_up)
-- @return boolean
-------------------------------------
function ServerData_Fevertime:isActiveFevertime_summonLegendUp()
    local is_active, value, l_ret = self:isActiveFevertimeByType('sm_legend_up')
    return is_active
end

-------------------------------------
-- function getRemainTimeTextDetail
-- @brief 남은 시간
-- @return str
-------------------------------------
function ServerData_Fevertime:getRemainTimeTextDetail(type)
    local is_active, value, l_ret = self:isActiveFevertimeByType(type)
    if (is_active == false) then
        return ''
    end

    -- 가장 빠른 end_date
    local end_date = nil
    for i, struct_fevertime in pairs(l_ret) do
        local _end_date = struct_fevertime:getFevertimeEnddate()
        if (_end_date ~= nil) and (0 < _end_date) then
            if (end_date == nil) then
                end_date = _end_date
            elseif (_end_date < end_date) then
                end_date = _end_date
            end
        end
    end

    if (end_date == nil) then
        return ''
    end

    local curr_time = Timer:getServerTime()
    local end_date = end_date / 1000
    local time = math_max((end_date - curr_time), 0)

    return Str('{1} 남음', datetime.makeTimeDesc(time, true, false)) -- params : sec, showSeconds, firstOnly, timeOnly
end

-------------------------------------
-- function getRemainTimeTextDetail_summonLegendUp
-- @brief 남은 시간
-- @return str
-------------------------------------
function ServerData_Fevertime:getRemainTimeTextDetail_summonLegendUp()
    return self:getRemainTimeTextDetail('sm_legend_up')
end

-------------------------------------
-- function convertType_hottimeToFevertime
-- @brief 2020.06.26 이후 이곳에 코드를 추가하지 않아도 작동함. 대신 hottime_type을 그대로 리턴하여 사용
-- @return string
-------------------------------------
function ServerData_Fevertime:convertType_hottimeToFevertime(hottime_type)
    -- 모험 드래곤 경험치 증가
    if (hottime_type == 'exp') then
        return 'exp_up'

    -- 모험 골드 증가
    elseif (hottime_type == 'gold') then
        return 'gold_up'

    -- 모험 날개 할인
    elseif (hottime_type == 'stamina') then
        return 'ad_st_dc'

    -- 룬 해제 비용 할인
    elseif (hottime_type == 'rune') then
        return 'rune_dc'

    -- 룬 강화 비용 할인
    elseif (hottime_type == 'runelvup') then
        return 'rune_lvup_dc'

    -- 드래곤 스킬 이전
    elseif (hottime_type == 'skillmove') then
        return 'skill_move_dc'

    -- 드래곤 강화
    elseif (hottime_type == 'reinforce') then
        return 'reinforce_dc'
    end

    return hottime_type
end