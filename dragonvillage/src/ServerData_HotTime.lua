--[[ 
### 등록된 핫타임 ###
    event_exchange : 수집 이벤트 (운영툴에서 event, event_open 역시 활성화 되있어야 함)
    event_dice : 주사위 이벤트
    event_gold_dungeon : 황금던전 이벤트

    dc_rune_50 : 룬 해제 50% 할인 이벤트
    dc_rune_100 : 룬 해제 무료 이벤트
    dc_runelvup_50 : 룬 강화 50% 할인 이벤트
    dc_skillmove_50 : 스킬 이전 50% 할인 이벤트

    exp_1_5x : 경험치 1.5배 이벤트
    exp_2x : 경험치 2배 이벤트
    gold_1_5x : 골드 1.5배 이벤트
    gold_2x : 골드 2배 이벤트
    stamina_50p : 활동력 1/2배 이벤트

    buff_exp2x : 경험치 부스터 사용중
    buff_gold2x : 골드 부스터 사용중
]]

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

        -- 부스터 아이템 정보
        m_boosterMailInfo = 'map',
        m_boosterInfoDirty = 'boolean',
    })

-- 할인 이벤트 
HOTTIME_SALE_EVENT = {
    RUNE_RELEASE = 'rune', -- 룬 해제 할인
    RUNE_ENHANCE = 'runelvup', -- 룬 강화 할인
    SKILL_MOVE= 'skillmove', -- 스킬 이전 할인
}

-- 부스터 아이템도 핫타임으로 관리 (사용시 핫타임에 등록됨)
BOOSTER_ITEM_STATE = {
    NORMAL = 1, -- 구매 가능
    AVAILABLE = 2, -- 사용 가능
    INUSE = 3, -- 사용 중
}

-------------------------------------
-- function init
-------------------------------------
function ServerData_HotTime:init(server_data)
    self.m_serverData = server_data
    
	self.m_activeEventList = {}
	self.m_listExpirationTime = nil
	
	self.m_activeDcEventTable = {}
    self.m_dcExpirationTime = nil

    self.m_boosterMailInfo = {}
    self.m_boosterInfoDirty = false

	self:init_hotTimeType()
end

-------------------------------------
-- function init_hotTimeType
-------------------------------------
function ServerData_HotTime:init_hotTimeType()self.m_hotTimeType = {}

    do
        local key = 'gold_1_5x'
        local t_data = {}
        t_data['key'] = key
        t_data['title'] = Str('핫타임 이벤트')
        t_data['tool_tip'] = Str('획득 골드량 50% 증가')
        self.m_hotTimeType[key] = t_data
    end

    do
        local key = 'gold_2x'
        local t_data = {}
        t_data['key'] = key
        t_data['title'] = Str('핫타임 이벤트')
        t_data['tool_tip'] = Str('획득 골드량 100% 증가')
        self.m_hotTimeType[key] = t_data
    end

    do
        local key = 'exp_1_5x'
        local t_data = {}
        t_data['key'] = key
        t_data['title'] = Str('핫타임 이벤트')
        t_data['tool_tip'] = Str('드래곤 경험치 획득량 50% 증가')
        self.m_hotTimeType[key] = t_data
    end

    do
        local key = 'exp_2x'
        local t_data = {}
        t_data['key'] = key
        t_data['title'] = Str('핫타임 이벤트')
        t_data['tool_tip'] = Str('드래곤 경험치 획득량 100% 증가')
        self.m_hotTimeType[key] = t_data
    end

    do
        local key = 'stamina_50p'
        local t_data = {}
        t_data['key'] = key
        t_data['title'] = Str('핫타임 이벤트')
        t_data['tool_tip'] = Str('소비 입장권 50% 할인')
        self.m_hotTimeType[key] = t_data
    end

    -- 부스터 아이템
    do
        local key = 'buff_gold2x'
        local t_data = {}
        t_data['key'] = key
        t_data['title'] = Str('골드 부스터')
        t_data['tool_tip'] = Str('획득 골드량 100% 증가')
        self.m_hotTimeType[key] = t_data
    end

    do
        local key = 'buff_exp2x'
        local t_data = {}
        t_data['key'] = key
        t_data['title'] = Str('경험치 부스터')
        t_data['tool_tip'] = Str('드래곤 경험치 획득량 100% 증가')
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
		self:response_hottime(ret, finish_cb)
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
-- function response_hottime
-------------------------------------
function ServerData_HotTime:response_hottime(ret, finish_cb)
    self.m_hotTimeInfoList = ret['all']
    self.m_listExpirationTime = nil
	self.m_dcExpirationTime = nil

    if finish_cb then
        finish_cb(ret)
    end
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

    -- 활성화된 항목 추출할때 부스터 아이템 로비에서 상태 갱신
    self.m_boosterInfoDirty = true
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
function ServerData_HotTime:getActiveHotTimeInfo(hottime_name)
    self:refreshActiveList()

    local t_event = nil
    for k,v in pairs(self.m_activeEventList) do
        local l_contents = v['contents']
        for _,name in ipairs(l_contents) do
            if (hottime_name == name) then
                t_event = v
                break
            end
        end

        -- 부스터 아이템은 contents가 아닌 이벤트 name으로 검사
        if (hottime_name == k) then
            t_event = v
            break
        end
    end

    return t_event
end

-------------------------------------
-- function getActiveHotTimeInfo_stamina
-------------------------------------
function ServerData_HotTime:getActiveHotTimeInfo_stamina()
    if g_hotTimeData:getActiveHotTimeInfo('stamina_50p') then
        return true, 50
    end

    return false
end

-------------------------------------
-- function getHotTimeBuffText
-------------------------------------
function ServerData_HotTime:getHotTimeBuffText(type)
    local state = BOOSTER_ITEM_STATE.NORMAL
    local str = ''
    local t_info = g_hotTimeData:getActiveHotTimeInfo(type)

    -- 현재 사용중
    if (t_info) then
        state = BOOSTER_ITEM_STATE.INUSE
        local curr_time = Timer:getServerTime()
        local end_time = t_info['enddate']/1000
        local time = (end_time - curr_time)
        str = Str('{@AQUA}{1} 남음', datetime.makeTimeDesc(time, true, true, true))

    -- 수신함에 있다면 사용가능한 상태
    elseif (self.m_boosterMailInfo[type]) then
        state = BOOSTER_ITEM_STATE.AVAILABLE
        str = Str('{@green}사용하기')
        
    else
        str = Str('구매 가능')
    end

    return str, state
end

-------------------------------------
-- function getActiveHotTimeInfo_gold
-------------------------------------
function ServerData_HotTime:getActiveHotTimeInfo_gold()
    local active = false
    local value = 0

    -- 핫타임과 부스터아이템 중복처리
    local t_info = {}
    t_info['gold_2x'] = 100
    t_info['gold_1_5x'] = 50
    t_info['buff_gold2x'] = 100
    
    for k, v in pairs(t_info) do
        if (g_hotTimeData:getActiveHotTimeInfo(k)) then
            active = true
            value = value + v
        end
    end

    return active, value
end

-------------------------------------
-- function getActiveHotTimeInfo_exp
-------------------------------------
function ServerData_HotTime:getActiveHotTimeInfo_exp()
    local active = false
    local value = 0

    -- 핫타임과 부스터아이템 중복처리
    local t_info = {}
    t_info['exp_2x'] = 100
    t_info['exp_1_5x'] = 50
    t_info['buff_exp2x'] = 100

    for k, v in pairs(t_info) do
        if (g_hotTimeData:getActiveHotTimeInfo(k)) then
            active = true
            value = value + v
        end
    end

    return active, value
end

-------------------------------------
-- function isHighlightHotTime
-------------------------------------
function ServerData_HotTime:isHighlightHotTime()
    for _,v in pairs(self.m_hotTimeType) do
        local key = v['key']
        -- 부스터는 포함하지 않음
        if (not string.find(key, 'buff')) and (self:getActiveHotTimeInfo(key)) then
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
-- param hottime_type : stamina, gold, exp
-------------------------------------
function ServerData_HotTime:makeHotTimeToolTip(hottime_type, btn)
    local title = ''
    local desc = ''
    local str = ''

    for k, v in pairs(self.m_hotTimeType) do
        if (string.find(k, hottime_type)) and (g_hotTimeData:getActiveHotTimeInfo(k)) then
            title = v['title']
            desc = v['tool_tip']
            local _str = '{@SKILL_NAME} ' .. title .. '\n {@SKILL_DESC}' .. desc
            str = (str == '') and  (_str) or (str .. '\n\n' .. _str)
        end
    end

    if (str ~= '') then
        local tooltip = UI_Tooltip_Skill(0, 0, str)

        if (tooltip and btn) then
            tooltip:autoPositioning(btn)
        end
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
-- function refresh_boosterMailInfo
-------------------------------------
function ServerData_HotTime:refresh_boosterMailInfo()
    local function update_booster(ret)
        self.m_boosterMailInfo = {} 
        local item_mail_map = g_mailData.m_mMailMap['item']
        if (item_mail_map) then
            for _, struct_mail in pairs(item_mail_map) do
                if (struct_mail:isExpBooster()) then
                    self.m_boosterMailInfo['buff_exp2x'] = struct_mail
                end

                if (struct_mail:isGoldBooster()) then
                    self.m_boosterMailInfo['buff_gold2x'] = struct_mail
                end
            end
        end
    end

    g_mailData:request_mailList(update_booster)
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
-- function getDiscountEventText
-------------------------------------
function ServerData_HotTime:getDiscountEventText(dc_target, only_value)
	local dc_value = self:getDiscountEventValue(dc_target)
	local dc_text
	if (dc_value == 0) then
	    -- nothing to do
	elseif (dc_value == 100) then
		dc_text = self:getDiscountEventText_Free(dc_target, only_value)
	else
		dc_text = self:getDiscountEventText_Value(dc_target, only_value)
	end
	
	return dc_text
end

-------------------------------------
-- function getDiscountEventText_Free
-------------------------------------
function ServerData_HotTime:getDiscountEventText_Free(dc_target, only_value)
    local dc_text = ''

    if (only_value) then
        dc_text = Str('무료')

    elseif (dc_target == HOTTIME_SALE_EVENT.RUNE_RELEASE) then
        dc_text = Str('룬 해제 무료')

    elseif (dc_target == HOTTIME_SALE_EVENT.RUNE_ENHANCE) then
        dc_text = Str('룬 강화 무료')

    elseif (dc_target == HOTTIME_SALE_EVENT.SKILL_MOVE) then
        dc_text = Str('스킬 이전 무료')
    end

    return dc_text
end

-------------------------------------
-- function getDiscountEventText_Value
-------------------------------------
function ServerData_HotTime:getDiscountEventText_Value(dc_target, only_value)
    local dc_value = self:getDiscountEventValue(dc_target)
    local dc_text = ''

    if (only_value) then
        dc_text = Str('{1}% 할인', dc_value)

    elseif (dc_target == HOTTIME_SALE_EVENT.RUNE_RELEASE) then
        dc_text = Str('룬 해제 {1}% 할인', dc_value)

    elseif (dc_target == HOTTIME_SALE_EVENT.RUNE_ENHANCE) then
        dc_text = Str('룬 강화 {1}% 할인', dc_value)

    elseif (dc_target == HOTTIME_SALE_EVENT.SKILL_MOVE) then
        dc_text = Str('스킬 이전 {1}% 할인', dc_value)
    end

    return dc_text
end

-------------------------------------
-- function getDiscountEventList
-------------------------------------
function ServerData_HotTime:getDiscountEventList()
    local l_dc_event = {}
    for k, v in pairs(HOTTIME_SALE_EVENT) do
        local dc_target = v
        local dc_value = self:getDiscountEventValue(dc_target)
        if (dc_value > 0) then
            table.insert(l_dc_event, dc_target)
        end
    end
	
	return l_dc_event
end