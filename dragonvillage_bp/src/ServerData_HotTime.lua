-------------------------------------
-- class ServerData_HotTime
-------------------------------------
ServerData_HotTime = class({
        m_serverData = 'ServerData',
        m_hotTimeType = 'table',
        m_hotTimeInfoList = 'table', -- 서버에서 넘어오는 데이터 그대로를 저장
        m_activeEventList = 'table',
        m_listExpirationTime = 'timestamp',

        m_currAdvGameKey = 'number',
        m_ingameHotTimeList = 'list',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_HotTime:init(server_data)
    self.m_serverData = server_data
    self.m_activeEventList = {}
    self.m_listExpirationTime = nil
    self:init_hotTimeType()
end

-------------------------------------
-- function init_hotTimeType
-------------------------------------
function ServerData_HotTime:init_hotTimeType()
    self.m_hotTimeType = {}

    do
        local key = 'gold_1_5x'
        local t_data = {}
        t_data['key'] = key
        t_data['tool_tip'] = Str('획득 골드량 1.5배')
        self.m_hotTimeType[key] = t_data
    end

    do
        local key = 'gold_2x'
        local t_data = {}
        t_data['key'] = key
        t_data['tool_tip'] = Str('획득 골드량 2배')
        self.m_hotTimeType[key] = t_data
    end

    do
        local key = 'exp_1_5x'
        local t_data = {}
        t_data['key'] = key
        t_data['tool_tip'] = Str('드래곤 경험치 획득량 1.5배')
        self.m_hotTimeType[key] = t_data
    end

    do
        local key = 'exp_2x'
        local t_data = {}
        t_data['key'] = key
        t_data['tool_tip'] = Str('드래곤 경험치 획득량 2배')
        self.m_hotTimeType[key] = t_data
    end

    do
        local key = 'stamina_50p'
        local t_data = {}
        t_data['key'] = key
        t_data['tool_tip'] = Str('소비 입장권 1/2')
        self.m_hotTimeType[key] = t_data
    end
end

-------------------------------------
-- function request_hottime
-------------------------------------
function ServerData_HotTime:request_hottime(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')
    
    -- 성공 콜백
    local function success_cb(ret)

        self.m_hotTimeInfoList = ret['all']
        self.m_listExpirationTime = nil

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/hottime')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function refreshActiveList
-------------------------------------
function ServerData_HotTime:refreshActiveList()
    if (not self.m_hotTimeInfoList) then
        return {}
    end

    local curr_time = Timer:getServerTime()

    -- 아직 유효한 시간이면 체크를 하지 않음
    if (self.m_listExpirationTime) and (curr_time < self.m_listExpirationTime) then
        return
    end

    -- 오늘의 자정 시간을 지정
    self.m_listExpirationTime = Timer:getServerTime_midnight(curr_time)

    -- 종료된 이벤트 삭제
    for key,v in pairs(self.m_activeEventList) do
        if ((v['enddate'] / 1000) < curr_time) then
            self.m_activeEventList[key] = nil
        end
    end

    -- 활성화된 항목 추출
    self.m_activeEventList = {}

    for i,v in pairs(self.m_hotTimeInfoList) do

        local expiration_time = nil

        -- 핫타임 시작 시간 전
        if (curr_time < (v['begindate'] / 1000)) then
            expiration_time = (v['begindate'] / 1000)

        -- 핫타임 종료 후
        elseif ((v['enddate'] / 1000) < curr_time) then

        -- 이벤트 내용 있을 경우
        elseif (v['contents']) and (table.count(v['contents']) > 0) then
            local key = v['event']
            self.m_activeEventList[key] = v
            expiration_time = (v['enddate'] / 1000)
        end

        -- 리스트가 유효한 시간 저장
        if expiration_time then
            if (expiration_time < self.m_listExpirationTime) then
                self.m_listExpirationTime = expiration_time
            end
        end
    end
end

-------------------------------------
-- function getActiveHotTimeInfo
-------------------------------------
function ServerData_HotTime:getActiveHotTimeInfo(hottime_nmae)
    self:refreshActiveList()

    local t_event = nil
    for i,v in pairs(self.m_activeEventList) do
        local l_contents = v['contents']
        for _,name in ipairs(l_contents) do
            if (hottime_nmae == name) then
                t_event = v
                break
            end
        end
    end

    return t_event
end

-------------------------------------
-- function getActiveHotTimeInfo_stamina
-------------------------------------
function ServerData_HotTime:getActiveHotTimeInfo_stamina()
    if g_hotTimeData:getActiveHotTimeInfo('stamina_50p') then
        return true, 'stamina_50p', '1/2'
    end

    return false
end

-------------------------------------
-- function getActiveHotTimeInfo_gold
-------------------------------------
function ServerData_HotTime:getActiveHotTimeInfo_gold()
    if g_hotTimeData:getActiveHotTimeInfo('gold_2x') then
        return true, 'gold_2x', 'x2'
    end

    if g_hotTimeData:getActiveHotTimeInfo('gold_1_5x') then
        return true, 'gold_1_5x', 'x1.5'
    end

    return false
end

-------------------------------------
-- function getActiveHotTimeInfo_exp
-------------------------------------
function ServerData_HotTime:getActiveHotTimeInfo_exp()
    if g_hotTimeData:getActiveHotTimeInfo('exp_2x') then
        return true, 'exp_2x', 'x2'
    end

    if g_hotTimeData:getActiveHotTimeInfo('exp_1_5x') then
        return true, 'exp_1_5x', 'x1.5'
    end

    return false
end

-------------------------------------
-- function isHighlightHotTime
-------------------------------------
function ServerData_HotTime:isHighlightHotTime()
    for _,v in pairs(self.m_hotTimeType) do
        local key = v['key']

        if self:getActiveHotTimeInfo(key) then
            return true
        end
    end
    
    return false
end

-------------------------------------
-- function setIngameHotTimeList
-------------------------------------
function ServerData_HotTime:setIngameHotTimeList(game_key, hottime)
    self.m_currAdvGameKey = game_key or 0
    self.m_ingameHotTimeList = hottime or {} 
end

-------------------------------------
-- function getIngameHotTimeList
-------------------------------------
function ServerData_HotTime:getIngameHotTimeList(game_key)
    if (self.m_currAdvGameKey == game_key) then
        return self.m_ingameHotTimeList
    else
        return {}
    end
end

-------------------------------------
-- function makeHotTimeToolTip
-------------------------------------
function ServerData_HotTime:makeHotTimeToolTip(hottime_name, btn)
    
    local desc = ''

    local t_hot_time_type = self.m_hotTimeType[hottime_name]

    if (t_hot_time_type and t_hot_time_type['tool_tip']) then
        desc = t_hot_time_type['tool_tip']
    end

    local str = '{@SKILL_NAME} ' .. Str('핫타임 이벤트') .. '\n {@SKILL_DESC}' .. desc
    local tooltip = UI_Tooltip_Skill(0, 0, str)

    if (tooltip and btn) then
        tooltip:autoPositioning(btn)
    end
end