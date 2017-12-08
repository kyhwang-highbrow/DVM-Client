-------------------------------------
-- class ServerData_HotTime
-- @brief 핫타임 뿐만 아니라 운영툴에서 걸어주는 이벤트를 관리한다.
-------------------------------------
ServerData_HotTime = class({
        m_serverData = 'ServerData',
        m_hotTimeType = 'table',
        m_hotTimeInfoList = 'table', -- 서버에서 넘어오는 데이터 그대로를 저장
        m_activeEventList = 'table',
        m_listExpirationTime = 'timestamp',

        m_currAdvGameKey = 'number',
        m_ingameHotTimeList = 'list',

		-- 할인 이벤트는 따로 관리
		m_activeDcEventTable = 'table', -- <dc_target, dv_value>
		m_dcExpirationTime = 'timestamp',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_HotTime:init(server_data)
    self.m_serverData = server_data
    
	self.m_activeEventList = {}
	self.m_listExpirationTime = nil
	
	self.m_activeDcEventTable = {}
    self.m_dcExpirationTime = nil

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
        t_data['tool_tip'] = Str('소비 입장권 50% 할인')
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
		self.m_dcExpirationTime = nil

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

        -- 활성 이벤트
        else
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

--[[
hottime event table 구조
{
      "begindate":1511276400000,
      "info":{
        "begin_date":"20171122",
        "begin_hour":"0",
        "end_date":"20171214",
        "end_hour":"10",
        "desc":" 주사위이벤트 활성화용"
      },
      "enddate":1513213200000,
      "contents":[],
      "event":"event_dice"
    }
]]
-------------------------------------
-- function isActiveEvent
-- @brief event 항목의 이름 검사
-------------------------------------
function ServerData_HotTime:isActiveEvent(event_name)
	self:refreshActiveList()

    for _, t in pairs(self.m_activeEventList) do
        if (t['event'] == event_name) then
            return true
        end
    end
    return false
end

-------------------------------------
-- function getActiveHotTimeInfo
-- @brief content 항목 검사 .. 이것들은 미리 정의되어야 한다
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
        return true, 'stamina_50p', '50%'
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











-------------------------------------
-- function getDiscountEventList
-------------------------------------
function ServerData_HotTime:refreshActivatedDiscountEvent()
    local curr_time = Timer:getServerTime()

	-- 종료된 이벤트 삭제
    for key, v in pairs(self.m_activeDcEventTable) do
        if ((v['enddate'] / 1000) < curr_time) then
            self.m_activeDcEventTable[key] = nil
        end
    end

	    -- 아직 유효한 시간이면 체크를 하지 않음
    if (self.m_dcExpirationTime) and (curr_time < self.m_dcExpirationTime) then
        return
    end

    -- 오늘의 자정 시간을 지정
    self.m_dcExpirationTime = Timer:getServerTime_midnight(curr_time)

    -- 활성화된 항목 추출
    self.m_activeDcEventTable = {}
	for i, v in pairs(self.m_hotTimeInfoList) do

		local name = v['event']
		local begin_at = v['begindate']
		local end_at = v['enddate']
		local dc_target, value = string.match(name, 'dc_(%a+)_(%d+)')
		value = tonumber(value)

		if (dc_target) then
			local expiration_time

			-- 핫타임 시작 시간 전
			if (begin_at) and (curr_time < (begin_at / 1000)) then
				expiration_time = (begin_at / 1000)

			-- 핫타임 종료 후
			elseif (end_at) and ((end_at / 1000) < curr_time) then
				
			-- 활성 이벤트
			else
				if (self.m_activeDcEventTable[dc_target]) then
					if (self.m_activeDcEventTable[dc_target]['value'] > value) then 
						self.m_activeDcEventTable[dc_target] = {['enddate'] = end_at, ['value'] = value}
					end
				else
					self.m_activeDcEventTable[dc_target] = {['enddate'] = end_at, ['value'] = value}
				end
				expiration_time = (end_at / 1000)
			end


			-- 리스트가 유효한 시간 저장
			if expiration_time then
				if (expiration_time < self.m_dcExpirationTime) then
					self.m_dcExpirationTime = expiration_time
				end
			end

		end
    end
end

-------------------------------------
-- function getDiscountEventList
-------------------------------------
function ServerData_HotTime:getDiscountEventList()
	self:refreshActivatedDiscountEvent()

	return self.m_activeDcEventTable
end

-------------------------------------
-- function getDiscountEventValue
-------------------------------------
function ServerData_HotTime:getDiscountEventValue(dc_target)
	self:refreshActivatedDiscountEvent()

	local dc_value = 0
	for target, v in pairs(self.m_activeDcEventTable) do
		if (target == dc_target) then
			dc_value = v['value']
			break
		end
	end

	return dc_value
end

-------------------------------------
-- function getDiscountEventValue
-------------------------------------
function ServerData_HotTime:getDiscountEventText(dc_target)
	local dc_value = self:getDiscountEventValue(dc_target)
	
	local dc_text
	if (dc_value == 0) then
		-- nothing to do
	elseif (dc_value == 100) then
		dc_text = Str('무료')
	else
		dc_text = string.format('%d%%', dc_value)
	end
	
	return dc_text
end
