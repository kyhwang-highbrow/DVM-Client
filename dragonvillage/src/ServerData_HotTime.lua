--[[ 
### 등록된 핫타임 ###
    event_exchange : 수집 이벤트 (운영툴에서 event, event_open 역시 활성화 되있어야 함)
    event_dice : 주사위 이벤트
    event_gold_dungeon : 황금던전 이벤트
    event_match_card : 카드 짝맞추기 이벤트
    event_mandraquest : 만드라고라의 모험 이벤트
    event_bingo : 빙고 이벤트

    dc_rune_50 : 룬 해제 50% 할인 이벤트
    dc_rune_100 : 룬 해제 무료 이벤트
    dc_runelvup_50 : 룬 강화 50% 할인 이벤트
    dc_skillmove_50 : 스킬 이전 50% 할인 이벤트
    dc_reinforce_20 -> 강화 20% 할인
    dc_reinforce_30 -> 강화 30% 할인
    dc_reinforce_50 -> 강화 50% 할인

    exp_1_5x : 경험치 1.5배 이벤트
    exp_2x : 경험치 2배 이벤트
    gold_1_5x : 골드 1.5배 이벤트
    gold_2x : 골드 2배 이벤트
    stamina_50p : 활동력 1/2배 이벤트

    buff_exp2x : 경험치 부스터 사용중
    buff_gold2x : 골드 부스터 사용중

    event_legend_chance_up : 전설 드래곤 소환 확률 2배
]]

-------------------------------------
---@class ServerData_HotTime
---@return ServerData_HotTime
-- @brief 핫타임 뿐만 아니라 운영툴에서 걸어주는 이벤트를 관리한다.
-------------------------------------
ServerData_HotTime = class({
        m_serverData = 'ServerData',
        m_hotTimeType = 'table',
        m_hotTimeInfoList = 'table', -- 서버에서 넘어오는 데이터 그대로를 저장
        m_hotTimeInfoMap = 'Map<string, hottimeinfo>', -- 서버에서 넘어오는 데이터를 MAP으로 정제해서 저장       
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
    DRAGON_REINFORCE = 'reinforce', -- 드래곤 강화
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
    self.m_hotTimeInfoMap = {}
	
	self.m_activeDcEventTable = {}
    self.m_dcExpirationTime = nil

    self.m_boosterMailInfo = {}
    self.m_boosterInfoDirty = false

	self:init_hotTimeType()
end

local CLAN_BUFF_INFO
-------------------------------------
-- function init_hotTimeType
-------------------------------------
function ServerData_HotTime:init_hotTimeType()
	CLAN_BUFF_INFO = {
		-- 클랜 버프
		['gold_bonus_rate'] = {
			['title'] = Str('클랜 버프'),
			['tool_tip'] = Str('획득 골드량 {1}% 증가'),
		},
		['exp_bonus_rate'] = {
			['title'] = Str('클랜 버프'),
			['tool_tip'] = Str('드래곤 경험치 획득량 {1}% 증가'),
		},
	}

    self.m_hotTimeType = {
		['gold_1_5x'] = {
			['key'] = 'gold_1_5x',
			['type'] = 'gold',
			['title'] = Str('핫타임 이벤트'),
			['tool_tip'] = Str('획득 골드량 {1}% 증가', 50),
			['value'] = 50,
		},
		['gold_2x'] = {
			['key'] = 'gold_2x',
			['type'] = 'gold',
			['title'] = Str('핫타임 이벤트'),
			['tool_tip'] = Str('획득 골드량 {1}% 증가', 100),
			['value'] = 100,
		},

		['exp_1_5x'] = {
			['key'] = 'exp_1_5x',
			['type'] = 'exp',
			['title'] = Str('핫타임 이벤트'),
			['tool_tip'] =  Str('드래곤 경험치 획득량 {1}% 증가', 50),
			['value'] = 50,
		},
		['exp_2x'] = {
			['key'] = 'exp_2x',
			['type'] = 'exp',
			['title'] = Str('핫타임 이벤트'),
			['tool_tip'] =  Str('드래곤 경험치 획득량 {1}% 증가', 100),
			['value'] = 100,
		},
		['stamina_50p'] = {
			['key'] = 'stamina_50p',
			['type'] = 'stamina',
			['title'] = Str('핫타임 이벤트'),
			['tool_tip'] = Str('소비 입장권 {1}% 할인', 50),
			['value'] = 50,
		},

		-- 부스터 아이템
		['buff_gold2x'] = {
			['key'] = 'buff_gold2x',
			['type'] = 'gold',
			['title'] = Str('골드 부스터'),
			['tool_tip'] = Str('획득 골드량 {1}% 증가', 100),
			['value'] = 100,
		},
		['buff_exp2x'] = {
			['key'] = 'buff_exp2x',
			['type'] = 'exp',
			['title'] = Str('경험치 부스터'),
			['tool_tip'] = Str('드래곤 경험치 획득량 {1}% 증가', 100),
			['value'] = 100,
		},
	}
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
    self.m_hotTimeInfoMap = {}

    -- 핫타임 맵 생성
    for _, v in ipairs(self.m_hotTimeInfoList) do
        local event_key = v['event']
        self.m_hotTimeInfoMap[event_key] = v
    end

    
	self.m_dcExpirationTime = nil

    if finish_cb then
        finish_cb(ret)
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
--- @function getHottimeEvent
--- @brief map으로 바로 가져오도록 하는 함수
-------------------------------------
function ServerData_HotTime:getHottimeEvent(event_name)
    return self.m_hotTimeInfoMap[event_name]
end

-------------------------------------
--- @function isActiveEvent
--- @brief event 항목의 이름 검사
-------------------------------------
function ServerData_HotTime:isActiveEvent(event_name)
    local t_event = self:getHottimeEvent(event_name)
    if t_event == nil then
        return false
    end

    -- 단말기(local)의 타임존 (단위 : 초)
    local timezone_local = datetime.getTimeZoneOffset()
    -- 서버(server)의 타임존 (단위 : 초)
    local timezone_server = Timer:getServerTimeZoneOffset()
    local offset = (timezone_local - timezone_server)

    local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()
    local begin_time = (t_event['begindate']/1000) + offset
    local end_time = (t_event['enddate']/1000) + offset

    if begin_time <= curr_time and curr_time <= end_time then
        return true
    end

    return false
end

-------------------------------------
--- @function getEventRemainTime
--- @brief event 항목의 남은 시간 (sec)
-------------------------------------
function ServerData_HotTime:getEventRemainTime(event_name)
	local t_event = self:getHottimeEvent(event_name)
    if t_event == nil then
        return 0
    end

    local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()
    local end_time = t_event['enddate']/1000
    local time = (end_time - curr_time)
    return time
end

-------------------------------------
--- @function getEventStartTime
--- @brief event 항목의 시작 시간(sec)
-------------------------------------
function ServerData_HotTime:getEventStartTime(event_name)
    local t_event = self:getHottimeEvent(event_name)
    if t_event == nil then
        return nil
    end

    return t_event['begindate']/1000
end

-------------------------------------
--- @function getEventRemainTimeText
--- @brief event 항목의 남은 시간 텍스트
-------------------------------------
function ServerData_HotTime:getEventRemainTimeText(event_name)
    local remain_time = self:getEventRemainTime(event_name)
    if (remain_time > 0) then
        return Str('{1} 남음', ServerTime:getInstance():makeTimeDescToSec(remain_time, true, true))
    else
        return ''
    end
end

-------------------------------------
--- @function getEventRemainTimeTextDetail
--- @brief event 항목의 남은 시간 텍스트
-------------------------------------
function ServerData_HotTime:getEventRemainTimeTextDetail(event_name)
    local remain_time = self:getEventRemainTime(event_name)
    if (remain_time > 0) then
        return Str('{1} 남음', ServerTime:getInstance():makeTimeDescToSec(remain_time, true, false))
    else
        return ''
    end
end

-------------------------------------
--- @function getEventRemainSec
--- @brief event 항목의 남은 초
-------------------------------------
function ServerData_HotTime:getEventRemainSec(event_name)
    return self:getEventRemainTime(event_name)
end

-------------------------------------
--- @function getActiveHotTimeInfo
--- @brief content 항목 검사 .. 이것들은 미리 정의되어야 한다
-------------------------------------
function ServerData_HotTime:getActiveHotTimeInfo(hottime_name)
    local t_event = nil
    for k, v in pairs(self.m_hotTimeInfoMap) do
        if self:isActiveEvent(k) == true then
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

    local value = 0

    -- fevertime의 정보를 가져온다. fevertime에서는 1이 100%이기 때문에 100을 곱해준다.
    local _is_active, _value, _l_ret = g_fevertimeData:isActiveFevertimeByType('ad_st_dc')
    value = (value + (_value * 100))

    return (value > 0), value
end

-------------------------------------
-- function getActiveHotTimeInfo_gold
-- @brief value 값은 getActiveBonusValue 호출로 서버에서 불러온다.
-------------------------------------
function ServerData_HotTime:getActiveHotTimeInfo_gold()
    local value = self:getActiveBonusValue('gold')

    -- fevertime의 정보를 가져온다. fevertime에서는 1이 100%이기 때문에 100을 곱해준다.
    local _is_active, _value, _l_ret = g_fevertimeData:isActiveFevertimeByType('gold_up')
    value = (value + (_value * 100))

    return (value > 0), value
end

-------------------------------------
-- function getActiveHotTimeInfo_exp
-- @brief value 값은 getActiveBonusValue 호출로 서버에서 불러온다.
-------------------------------------
function ServerData_HotTime:getActiveHotTimeInfo_exp()
    local value = self:getActiveBonusValue('exp')

    -- fevertime의 정보를 가져온다. fevertime에서는 1이 100%이기 때문에 100을 곱해준다.
    local _is_active, _value, _l_ret = g_fevertimeData:isActiveFevertimeByType('exp_up')
    value = (value + (_value * 100))

    return (value > 0), value
end

-------------------------------------
-- function getActiveBonusValue
-- @brief 받은 타입의 활성화된 보너스 수치 리턴
-- @param bonus_type : gold, exp, stamina, dg_gd_item_up, dg_gt_item_up
-- @comment hottime, buff, clan_buff의 통칭은 bonus로 충분할까요?
-------------------------------------
function ServerData_HotTime:getActiveBonusValue(bonus_type)
	local value = 0

	-- 핫타임 버프 + 부스터 버프
	for k, v in pairs(self.m_hotTimeType) do
		if (v['type'] == bonus_type) then
			if (self:getActiveHotTimeInfo(k)) then
				value = value + v['value']
			end
		end
	end

	-- 클랜 버프 추가
	if (not g_clanData:isClanGuest()) then
		value = value + g_clanData:getClanStruct():getClanBuffByType(CLAN_BUFF_TYPE[bonus_type:upper()])
	end

	return value
end

-------------------------------------
-- function getHottimeInfo
-------------------------------------
function ServerData_HotTime:getHottimeInfo(hottime_type)
	if (not self.m_hotTimeType[hottime_type]) then
		return 
	end
	return self.m_hotTimeType[hottime_type]
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
--- @function getHotTimeBuffText
-------------------------------------
function ServerData_HotTime:getHotTimeBuffText(type)
    local state = BOOSTER_ITEM_STATE.NORMAL
    local str = ''
    local t_info = self:getActiveHotTimeInfo(type)

    -- 현재 사용중
    if (t_info) then
        local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()
        local end_time = t_info['enddate']/1000
        local time = (end_time - curr_time)
        -- 남은시간이 양수인 경우만 상태 변경 
        if (time > 0) then
            state = BOOSTER_ITEM_STATE.INUSE
            str = Str('{@AQUA}{1} 남음', ServerTime:getInstance():makeTimeDescToSec(time, true, true, true))
        end

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
    local str = ''

    do -- fevertime 핫타임 버프 정보
        local fevertime_type = g_fevertimeData:convertType_hottimeToFevertime(hottime_type)
        local is_active, value, l_ret = g_fevertimeData:isActiveFevertimeByType(fevertime_type)

        -- StructFevertime
        for k, struct_fevertime in pairs(l_ret) do
		    local title = struct_fevertime:getFevertimeName()
            local desc = struct_fevertime:getFevertimeDesc()
            desc = string.gsub(desc, '{@default}', '{@SKILL_DESC}')

			local _str = string.format('{@SKILL_NAME} %s\n  {@SKILL_DESC} %s', title, desc)
            str = (str == '') and  (_str) or (str .. '\n\n' .. _str)
        end
    end

	-- 핫타임 버프 정보
    for k, v in pairs(self.m_hotTimeType) do
		local title, desc

		-- 정의된 키만 사용한다.
		if (string.find(k, hottime_type)) then
			if (self:getActiveHotTimeInfo(k)) then
				title = v['title']
				desc = v['tool_tip']
			end
		end

		if (title ~= nil) then
			local _str = string.format('{@SKILL_NAME} %s\n  {@SKILL_DESC} %s', title, desc)
			str = (str == '') and  (_str) or (str .. '\n\n' .. _str)
		end
    end

	-- 클랜 버프 정보  
	if (not g_clanData:isClanGuest()) then
		for clan_buff_type, t_data in pairs(CLAN_BUFF_INFO) do
			local title, desc

			if (string.find(clan_buff_type, hottime_type)) then
				local value = g_clanData:getClanStruct():getClanBuffByType(clan_buff_type)
				if (value > 0) then
					title = t_data['title']
					desc = Str(t_data['tool_tip'], value)
				end
			end

			if (title ~= nil) then
				local _str = string.format('{@SKILL_NAME} %s\n  {@SKILL_DESC} %s', title, desc)
				str = (str == '') and  (_str) or (str .. '\n\n' .. _str)
			end
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
-- function makeHotTimeToolTip_onlyClanBuff
-- param hottime_type : stamina, gold, exp
-------------------------------------
function ServerData_HotTime:makeHotTimeToolTip_onlyClanBuff(hottime_type, btn)
    local str = ''

    -- 클랜 버프 정보  
	if (not g_clanData:isClanGuest()) then
		for clan_buff_type, t_data in pairs(CLAN_BUFF_INFO) do
			local title, desc

			if (string.find(clan_buff_type, hottime_type)) then
				local value = g_clanData:getClanStruct():getClanBuffByType(clan_buff_type)
				if (value >= 0) then
					title = t_data['title']
					desc = Str(t_data['tool_tip'], value)
				end
			end

			if (title ~= nil) then
				local _str = string.format('{@SKILL_NAME} %s\n  {@SKILL_DESC} %s', title, desc)
				str = (str == '') and  (_str) or (str .. '\n\n' .. _str)
			end
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
-- function refreshActivatedDiscountEvent
-------------------------------------
function ServerData_HotTime:refreshActivatedDiscountEvent()
    local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()
    local active_dc_event_table = (self.m_activeDcEventTable or {})

	-- 종료된 이벤트 삭제
    for key, v in pairs(active_dc_event_table) do
        if ((v['enddate'] / 1000) < curr_time) then
            active_dc_event_table[key] = nil
        end
    end

	    -- 아직 유효한 시간이면 체크를 하지 않음
    if (self.m_dcExpirationTime) and (curr_time < self.m_dcExpirationTime) then
        return
    end

    -- 오늘의 자정 시간을 지정
    self.m_dcExpirationTime = ServerTime:getInstance():getMidnightTimeStampSeconds()

    -- 활성화된 항목 추출
    self.m_activeDcEventTable = {}
    local hottime_info_list = (self.m_hotTimeInfoList or {})
	for i, v in pairs(hottime_info_list) do

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

                    -- 할인률이 더 높은 이벤트로 설정
					if (self.m_activeDcEventTable[dc_target]['value'] < value) then 
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
	local dc_value = 0
    -- 75레벨 이하 룬 해제비용 삭제되서 할인 이벤트 적용 자체를 안하도록 수정
    -- 띠지 노출 제거용
    if dc_target == 'rune' then
        local user_level = g_userData:get('lv')
        local free_level = g_constant:get('INGAME', 'FREE_RUNE_UNEQUIP_USER_LV')
        if user_level <= free_level then
            return 0
        end
    end
    
    local active_dc_event_table = (self.m_activeDcEventTable or {})
	for target, v in pairs(active_dc_event_table) do
		if (target == dc_target) then
			dc_value = v['value']
			break
		end
	end

    -- fevertime 추가
    local hottime_type = dc_target
    local fevertime_type = g_fevertimeData:convertType_hottimeToFevertime(hottime_type)
    local is_active, value, l_ret = g_fevertimeData:isActiveFevertimeByType(fevertime_type)
    dc_value = dc_value + (value * 100) -- fevertime의 정보를 가져온다. fevertime에서는 1이 100%이기 때문에 100을 곱해준다.

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

    elseif (dc_target == HOTTIME_SALE_EVENT.DRAGON_REINFORCE) then
        dc_text = Str('드래곤 강화 무료')

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

    elseif (dc_target == HOTTIME_SALE_EVENT.DRAGON_REINFORCE) then
        dc_text = Str('드래곤 강화 {1}% 할인', dc_value)
    end

    return dc_text
end

-------------------------------------
-- function setDiscountEventNode
-- @param : dc_target - HOTTIME_SALE_EVENT key
-- @param : vars - ui vars
-- @param : lua_name - sprite lua_name
-- @param : only_value - full text or value text
-------------------------------------
function ServerData_HotTime:setDiscountEventNode(dc_target, vars, lua_name, only_value)
    local dc_value = self:getDiscountEventValue(dc_target)
    if (not dc_value) or (dc_value == 0) then
        return
    end

    local sprite = vars[lua_name]
    local action_tag = 99
    if (sprite) then
        sprite:setVisible(true)
        -- 액션이 없는 경우에만 추가
        local is_play = sprite:getActionByTag(action_tag)
        if (not is_play) then
            -- 흔들림 액션 추가
            local action = cca.buttonShakeAction(1, 2)
            action:setTag(action_tag)
            sprite:runAction(action)
        end
    end

    -- 라벨이 있는 경우 텍스트 표기
    local _lua_name = string.gsub(lua_name, 'Sprite', 'Label')
    local text = self:getDiscountEventText(dc_target, only_value)
    local label = vars[_lua_name]
    if (label) then
        label:setString(text)
    end
end

-------------------------------------
-- function getDiscountEventList
-------------------------------------
function ServerData_HotTime:getDiscountEventList()
	self:refreshActivatedDiscountEvent()

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