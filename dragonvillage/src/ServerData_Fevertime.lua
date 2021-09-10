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

-- 할인 이벤트
FEVERTIME_SALE_EVENT = {
    MASTERY_DC = 'mastery_dc', -- 룬 해제 할인
    REINFORCE_DC = 'reinforce_dc', -- 드래곤 강화 할인

    ADVENTURE_ST_DC = 'ad_st_dc',
    GDRAGON_ST_DC = 'dg_gd_st_dc',
    NIGHTMARE_ST_DC = 'dg_nm_st_dc',
    TREE_ST_DC = 'dg_gt_st_dc',
    ANCIENT_RUIN_ST_DC = 'dg_ar_st_dc',
    RUNE_GUARDIAN_ST_DC = 'dg_rg_st_dc',

    RUNE_GACHA_UP = 'rune_gacha_up',
    RUNE_COMBINE_UP = 'rune_combine_up',
}

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
-- @brief 활성화된 피버타임 적용
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
-- @brief (활성화 가능한 + 활성화 중인 + 활성화 끝난) 피버타임 스케쥴
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
-- @brief 모든 유저에게 글로벌 피버타임 적용
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

    -- 핫타임 존재하지 않는 경우 에러 방지
    if (_time == nil) then
        self.m_expirationTimestamp = midnight

    else
        self.m_expirationTimestamp = math_min(midnight, _time)
    end
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
-- function isNotUsedFevertimeExist
-- @brief 사용되지 않은 핫타임이 존재하는가
-------------------------------------
function ServerData_Fevertime:isNotUsedFevertimeExist()
    -- 일일 핫타임 활성화 가능한 경우
    for i,struct_fevertime in pairs(self.m_lFevertimeSchedule) do
        if (struct_fevertime:isTodayDailyHottime() == true) then
            return true
        end
    end

    return false
end

-------------------------------------
-- function getNotUsedFevertimesTypes
-- @brief 사용되지 않은 핫타임의 type을 가져온다.
-------------------------------------
function ServerData_Fevertime:getNotUsedFevertimesTypes(type)

    local today_fevertime_list = {}
    -- 일일 핫타임 활성화 가능한 경우
    for i,struct_fevertime in pairs(self.m_lFevertimeSchedule) do
        if (struct_fevertime:isTodayDailyHottime() == true) then
            table.insert(today_fevertime_list, struct_fevertime)
        end
    end

    return today_fevertime_list
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
    local is_active_ad_st_dc = self:isActiveFevertimeByType(FEVERTIME_SALE_EVENT.ADVENTURE_ST_DC) -- 모험 날개 할인

    return is_active_exp_up or is_active_gold_up or is_active_ad_st_dc
end

-------------------------------------
-- function isActiveFevertime_dungeonGdItemUp
-- @brief 거대용 던전 보상 획득량 증가
-- @return boolean
-------------------------------------
function ServerData_Fevertime:isActiveFevertime_dungeonGdItemUp()
    -- 거대용 던전이 언락되지 않았으면 false
    if g_contentLockData:isContentLock('nest_evo_stone') then 
        return false 
    end

    local is_active_dg_gd_item_up = self:isActiveFevertimeByType('dg_gd_item_up')

    return is_active_dg_gd_item_up
end

-------------------------------------
-- function isActiveFevertime_dungeonGtItemUp
-- @brief 거목 던전 보상 획득량 증가
-- @return boolean
-------------------------------------
function ServerData_Fevertime:isActiveFevertime_dungeonGtItemUp()
    -- 거목 던전이 언락되지 않았으면 false
    if g_contentLockData:isContentLock('nest_tree') then 
        return false 
    end

    local is_active_dg_gt_item_up = self:isActiveFevertimeByType('dg_gt_item_up')

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
-- function isActiveFevertime_pvpHonorUp
-- @brief 명예 획득량 증가
-- @return boolean
-------------------------------------
function ServerData_Fevertime:isActiveFevertime_pvpHonorUp()
    local is_active_pvp_honor_up = self:isActiveFevertimeByType('pvp_honor_up')

    return is_active_pvp_honor_up
end

-------------------------------------
-- function isActiveFevertime_dungeonRuneLegendUp
-- @brief 전설 등급 룬 확률 증가
-- @return boolean
-------------------------------------
function ServerData_Fevertime:isActiveFevertime_dungeonRuneLegendUp()
    -- 룬 파밍 던전인 악몽 던전과 고대 유적 던전이 둘 다 언락 되지 않았으면 false
    if g_contentLockData:isContentLock('nest_nightmare') and g_contentLockData:isContentLock('ancient_ruin') then 
        return false 
    end

    local is_active_dg_rune_legend_up = self:isActiveFevertimeByType('dg_rune_legend_up')

    return is_active_dg_rune_legend_up
end

-------------------------------------
-- function isActiveFevertime_dungeonRuneUp
-- @brief 룬 추가 획득
-- @return boolean
-------------------------------------
function ServerData_Fevertime:isActiveFevertime_dungeonRuneUp()
    -- 룬 파밍 던전인 악몽 던전과 고대 유적 던전이 둘 다 언락 되지 않았으면 false
    if g_contentLockData:isContentLock('nest_nightmare') and g_contentLockData:isContentLock('ancient_ruin') then 
        return false 
    end

    local is_active_dg_rune_up = self:isActiveFevertimeByType('dg_rune_up')

    return is_active_dg_rune_up
end

-------------------------------------
-- function isActiveFevertime_masteryDc
-- @brief 특성 레벨업 비용 할인
-- @return boolean
-------------------------------------
function ServerData_Fevertime:isActiveFevertime_masteryDc()
    local is_active_mastery_dc = self:isActiveFevertimeByType(FEVERTIME_SALE_EVENT.MASTERY_DC)

    return is_active_mastery_dc
end

-------------------------------------
-- function isActiveFevertime_dungeonGtStDc
-- @brief 거목 던전 날개 할인
-- @return boolean
-------------------------------------
function ServerData_Fevertime:isActiveFevertime_dungeonGtStDc()
    -- 거목 던전이 언락 되지 않았으면 false
    if g_contentLockData:isContentLock('nest_tree') then 
        return false 
    end
    local is_active_dg_gt_st_dc = self:isActiveFevertimeByType(FEVERTIME_SALE_EVENT.TREE_ST_DC)

    return is_active_dg_gt_st_dc
end

-------------------------------------
-- function isActiveFevertime_dungeonGdStDc
-- @brief 거대용 던전 날개 할인
-- @return boolean
-------------------------------------
function ServerData_Fevertime:isActiveFevertime_dungeonGdStDc()
    -- 거대용 던전이 언락 되지 않았으면 false
    if g_contentLockData:isContentLock('nest_evo_stone') then 
        return false 
    end
    local is_active_dg_gd_st_dc = self:isActiveFevertimeByType(FEVERTIME_SALE_EVENT.GDRAGON_ST_DC)

    return is_active_dg_gd_st_dc
end

-------------------------------------
-- function isActiveFevertime_dungeonNmStDc
-- @brief 악몽 던전 날개 할인
-- @return boolean
-------------------------------------
function ServerData_Fevertime:isActiveFevertime_dungeonNmStDc()
    -- 악몽 던전이 언락 되지 않았으면 false
    if g_contentLockData:isContentLock('nest_nightmare') then 
        return false 
    end
    local is_active_dg_nm_st_dc = self:isActiveFevertimeByType(FEVERTIME_SALE_EVENT.NIGHTMARE_ST_DC)

    return is_active_dg_nm_st_dc
end

-------------------------------------
-- function isActiveFevertime_dungeonArStDc
-- @brief 고대 유적 던전 날개 할인
-- @return boolean
-------------------------------------
function ServerData_Fevertime:isActiveFevertime_dungeonArStDc()
    -- 고대 유적 던전이 언락 되지 않았으면 false
    if g_contentLockData:isContentLock('ancient_ruin') then 
        return false 
    end
    local is_active_dg_ar_st_dc = self:isActiveFevertimeByType(FEVERTIME_SALE_EVENT.ANCIENT_RUIN_ST_DC)

    return is_active_dg_ar_st_dc
end

-------------------------------------
-- function isActiveFevertime_dungeonRgStDc
-- @brief 룬 수호자 던전 날개 할인
-- @return boolean
-------------------------------------
function ServerData_Fevertime:isActiveFevertime_dungeonRgStDc()
    -- 룬 수호자 던전이 언락 되지 않았으면 false
    if g_contentLockData:isContentLock('rune_guardian') then 
        return false 
    end
    local is_active_dg_rg_st_dc = self:isActiveFevertimeByType(FEVERTIME_SALE_EVENT.RUNE_GUARDIAN_ST_DC)

    return is_active_dg_rg_st_dc
end
-------------------------------------
-- function isActiveFevertime_runeGachaUp
-- @brief 7등급 룬 뽑기 확률 증가
-- @return boolean
-- is_active, value, l_ret 
-------------------------------------
function ServerData_Fevertime:isActiveFevertime_runeGachaUp()
    local is_active local value local l_ret
    is_active, value, l_ret = self:isActiveFevertimeByType(FEVERTIME_SALE_EVENT.RUNE_GACHA_UP)
    return is_active, value, l_ret
end

-------------------------------------
-- function isActiveFevertime_runeCombineUp
-- @brief 7등급 룬 합성 확률 증가
-- @return boolean
-- is_active, value, l_ret 
-------------------------------------
function ServerData_Fevertime:isActiveFevertime_runeCombineUp()
    local is_active local value local l_ret
    is_active, value, l_ret = self:isActiveFevertimeByType(FEVERTIME_SALE_EVENT.RUNE_COMBINE_UP)
    return is_active, value, l_ret
end




-------------------------------------
-- function getRemainTimeTextDetail
-- @brief 현재 걸려있는 핫타임 중 가장 짧게 남은 핫타임의 남은 시간
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
        return FEVERTIME_SALE_EVENT.ADVENTURE_ST_DC

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
        return FEVERTIME_SALE_EVENT.REINFORCE_DC
    end

    return hottime_type
end

-------------------------------------
-- function getDiscountEventValue
-- @brief ServerData_HotTime에서 가져온걸 ServerData_Fevertime용으로 변경
-------------------------------------
function ServerData_Fevertime:getDiscountEventValue(dc_target)
    local is_active, dc_value = self:isActiveFevertimeByType(dc_target)
    dc_value = dc_value * 100

	return dc_value
end

-------------------------------------
-- function ServerData_Fevertime
-- @brief ServerData_HotTime에서 가져온걸 ServerData_Fevertime용으로 변경
-------------------------------------
function ServerData_Fevertime:getDiscountEventText(dc_target, only_value)
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
-- @brief ServerData_HotTime에서 가져온걸 ServerData_Fevertime용으로 변경
-------------------------------------
function ServerData_Fevertime:getDiscountEventText_Free(dc_target, only_value)
    local dc_text = ''

    if (only_value) then
        dc_text = Str('무료')

    elseif (dc_target == FEVERTIME_SALE_EVENT.MASTERY_DC) then
        dc_text = Str('특성 레벨업 무료')
    end

    return dc_text
end

-------------------------------------
-- function getDiscountEventText_Value
-- @brief ServerData_HotTime에서 가져온걸 ServerData_Fevertime용으로 변경
-------------------------------------
function ServerData_Fevertime:getDiscountEventText_Value(dc_target, only_value)
    local dc_value = self:getDiscountEventValue(dc_target)
    local dc_text = ''

    if (only_value) then
        dc_text = Str('{1}% 할인', dc_value)

    elseif (dc_target == FEVERTIME_SALE_EVENT.MASTERY_DC) then
        dc_text = Str('특성 레벨업 {1}% 할인', dc_value)
    end

    return dc_text
end

-------------------------------------
-- function setDiscountEventNode
-- @brief ServerData_HotTime에서 가져온걸 ServerData_Fevertime용으로 변경
-------------------------------------
function ServerData_Fevertime:setDiscountEventNode(dc_target, vars, lua_name, only_value)
    if (dc_target == 'rune' or dc_target == 'runelvup' or dc_target == 'skillmove' or dc_target == 'reinforce') then
        g_hotTimeData:setDiscountEventNode(dc_target, vars, lua_name)
    else
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
end

-------------------------------------
-- function getDiscountEventList
-- @brief ServerData_HotTime에서 가져온걸 ServerData_Fevertime용으로 변경
-------------------------------------
function ServerData_Fevertime:getDiscountEventList()
    local l_dc_event = {}
    l_dc_event = g_hotTimeData:getDiscountEventList()

    for k, v in pairs(FEVERTIME_SALE_EVENT) do
        local dc_target = v
        local is_active, dc_value = self:isActiveFevertimeByType(dc_target)
        if (dc_value > 0) then
            table.insert(l_dc_event, dc_target)
        end
    end
	
	return l_dc_event
end

-------------------------------------
-- function getNotUsedDailyFevertime
-- @param l_type 피버타임 type 리스트
-- @breif l_type에 해당하는 피버타임 중 사용하지 않은 피버타임 리스트를 반환한다.
-- @return usable_fevertime_list 사용하지 않은 피버타임 list
-------------------------------------
function ServerData_Fevertime:getNotUsedDailyFevertime(l_type)
    local today_fevertime_list = self:getNotUsedFevertimesTypes()
    local usable_fevertime_list = {}

    for i, struct_fevertime in pairs(today_fevertime_list) do
        local type = struct_fevertime['type']

        -- 같은 타입의 것이 이미 활성화 되어 있는 핫타임은 어차피 사용하지 못하므로 추가 하지 않는다.
        if (not self:isActiveFevertimeByType(type)) then
            local exist = false
            for _, _type in pairs(l_type) do
                if (type == _type) then
                    exist = true
                end 
            end
        
            if (exist == true) then
                table.insert(usable_fevertime_list, struct_fevertime)
            end
        end
    end

    return usable_fevertime_list
end

-------------------------------------
-- function getNotUsedDailyFevertime_adventure
-- @breif 모험 모드 피버타임 중 사용 가능한 피버타임을 반환한다.
-- @return self:getNotUsedDailyFevertime(l_type) table
-------------------------------------
function ServerData_Fevertime:getNotUsedDailyFevertime_adventure()
    local l_type = {'exp_up', 'gold_up', 'ad_st_dc'}
    return self:getNotUsedDailyFevertime(l_type)
end