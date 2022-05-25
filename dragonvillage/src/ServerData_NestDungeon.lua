-------------------------------------
-- class ServerData_NestDungeon
-------------------------------------
ServerData_NestDungeon = class({
        m_serverData = 'ServerData',
        m_nestDungeonInfoMap = 'table(map)',
        m_bDirtyNestDungeonInfo = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_NestDungeon:init(server_data)
    self.m_serverData = server_data
    self.m_nestDungeonInfoMap = {}
    self.m_bDirtyNestDungeonInfo = true
end

-------------------------------------
-- function applyNestDungeonInfo
-- @breif 서버에서 전달받은 데이터를 클라이언트에 적용
-------------------------------------
function ServerData_NestDungeon:applyNestDungeonInfo(data)
    self.m_serverData:applyServerData(data, 'nest_info')

    -- 맵의 형태로 사용
    local l_nest_info = self.m_serverData:getRef('nest_info')
    self.m_nestDungeonInfoMap = {}
    for i,v in ipairs(l_nest_info) do
        local dungeon_id = v['mode_id']
        self.m_nestDungeonInfoMap[dungeon_id] = v

        -- 닫히는 시간이 임박했을 때를 위한 테스트 코드 (10초 후 갱신되도록)
        --v['next_invalid_at'] = (ServerTime:getInstance():getCurrentTimestampSeconds() + 10) * 1000

        -- next_valid_at 값이 없으면 현재 시간으로 입력
        if (not v['next_valid_at']) then
            v['next_valid_at'] = ServerTime:getInstance():getCurrentTimestampSeconds() * 1000
        end
    end

    self.m_bDirtyNestDungeonInfo = false
end

-------------------------------------
-- function getNestDungeonInfo
-- @brief 네스트 던전 리스트 항목 얻어옴
--        거대용, 악몽, 거목
-------------------------------------
function ServerData_NestDungeon:getNestDungeonInfo()
    local l_nest_info = self.m_serverData:getRef('nest_info')
    local l_ret = clone(l_nest_info)
    return l_ret
end

-------------------------------------
-- function getNestDungeonInfoIndividual
-- @brief 네스트 던전 리스트 항목 얻어옴
--        거대용, 악몽, 거목
-------------------------------------
function ServerData_NestDungeon:getNestDungeonInfoIndividual(stage_id)
    local dungeon_id = self:getDungeonIDFromStateID(stage_id)
    
    local l_dungeon_list = self:getNestDungeonInfo()

    for i,v in ipairs(l_dungeon_list) do
        if (v['mode_id'] == dungeon_id) then
            return v
        end
    end

    return nil
end

-------------------------------------
-- function getNestDungeonListForUI
-- @brief 네스트 던전 리스트 항목 얻어옴 (UI 전용)
-------------------------------------
function ServerData_NestDungeon:getNestDungeonListForUI()
    local l_dungeon_list = self:getNestDungeonInfo()

    do 
        local t_remove = {}
        for i,v in ipairs(l_dungeon_list) do
            if (v['is_open'] == 0) then
                table.insert(t_remove, 1, i)
            end
        end

        for i,v in ipairs(t_remove) do
            table.remove(l_dungeon_list, v)
        end
    end

    local t_ret = table.listToMap(l_dungeon_list, 'mode_id')
    return t_ret
end

-------------------------------------
-- function getNestDungeonListForUIByType
-- @brief 타입별 네스트 던전 리스트 항목 얻어옴 (UI 전용)
-------------------------------------
function ServerData_NestDungeon:getNestDungeonListForUIByType(d_type)
    local t_dungeon_list = self:getNestDungeonListForUI()
	if (not d_type) then
		return t_dungeon_list
	end

	local t_ret = {}

	for mode_id, dungeon in pairs(t_dungeon_list) do
		local t_dungeon = g_nestDungeonData:parseNestDungeonID(mode_id)
		local dungeon_mode = t_dungeon['dungeon_mode']
		if (dungeon_mode == d_type) then
			t_ret[mode_id] = dungeon
		end
	end

    return t_ret
end

-------------------------------------
-- function getNestDungeonAllMapForUIByType
-------------------------------------
function ServerData_NestDungeon:getNestDungeonAllMapForUIByType(d_type)
    local l_dungeon_list = self:getNestDungeonInfo()
	local t_ret = {}
	
	for _, data in ipairs(l_dungeon_list) do
		local mode_id = data['mode_id']
		local t_dungeon = g_nestDungeonData:parseNestDungeonID(mode_id)
		local dungeon_mode = t_dungeon['dungeon_mode']
		if (dungeon_mode == d_type) then
			t_ret[mode_id] = data
		end
	end

	return t_ret
end


-------------------------------------
-- function requestNestDungeonInfo
-- @brief 서버로부터 네스트던전 open정보를 받아옴
-- @return ui_network
-------------------------------------
function ServerData_NestDungeon:requestNestDungeonInfo(cb_func, fail_cb)
    if (not self.m_bDirtyNestDungeonInfo) then
        if cb_func then
            cb_func()
        end
        return nil
    end

    local uid = g_userData:get('uid')

    -- 성공 시 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)

        if ret['nest_info'] then
            -- 황금던전은 나중에 다시 들어갈 것이 자명함으로 클라에서 처리
            do
                local remove_idx
                for i, v in pairs(ret['nest_info']) do
                    if (v['mode_id'] == 1240000) then
                        remove_idx = i
                    end
                end
                if (remove_idx) then
                    table.remove(ret['nest_info'], remove_idx)
                end
            end

            self:applyNestDungeonInfo(ret['nest_info'])
        end

        if cb_func then
            cb_func(ret)
        end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/game/nest/info')
    ui_network:setParam('uid', uid)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function getNestDungeon_stageList
-- @brief 네스트 던전 모드별 스테이지 리스트
-------------------------------------
function ServerData_NestDungeon:getNestDungeon_stageList(nest_dungeon_id)
    local table_drop = TableDrop()

    -- 네스트던전의 세부 모드별 스테이지 리스트를 조건 체크
    local function condition_func(t_table)
        local stage_id = t_table['stage']
        stage_id = stage_id - (stage_id % 100)
        
        if (stage_id == nest_dungeon_id) then
            return true
        else
            return false
        end
    end

    -- 테이블에서 조건에 맞는 테이블만 리턴
    local l_stage_list = table_drop:filterList_condition(condition_func)

    -- stage(stage_id) 순서로 정렬
    local function sort_func(a, b)
        return a['stage'] < b['stage']
    end
    table.sort(l_stage_list, sort_func)

    return l_stage_list
end

-------------------------------------
-- function getNestDungeon_stageListForUI
-- @brief 네스트 던전 모드별 스테이지 리스트 (UI 전용)
-------------------------------------
function ServerData_NestDungeon:getNestDungeon_stageListForUI(nest_dungeon_id)
    return self:getNestDungeon_stageList(nest_dungeon_id)
end

-------------------------------------
-- function parseNestDungeonID
-- @brief 네스트 
--        거대용, 악몽, 거목
-------------------------------------
function ServerData_NestDungeon:parseNestDungeonID(stage_id)
    -- 1210101
    -- 12xxxxx 모드 구분 (네스트 던전 모드)
    --   1xxxx 네스트 던전 구분 (거대용, 고목, 악몽)
    --    01xx 세부 모드 (속성 or role)
    --      01 티어 (통상적으로 1~10)

    local t_dungeon_id_info = {}
    t_dungeon_id_info['stage_mode'] = getDigit(stage_id, 100000, 2)
    t_dungeon_id_info['dungeon_mode'] = getDigit(stage_id, 10000, 1)
    t_dungeon_id_info['detail_mode'] = getDigit(stage_id, 100, 2)
    t_dungeon_id_info['tier'] = getDigit(stage_id, 1, 2)

    return t_dungeon_id_info
end

-------------------------------------
-- function getDungeonMode
-- @brief 네스트 
--        거대용, 악몽, 거목
-------------------------------------
function ServerData_NestDungeon:getDungeonMode(stage_id)
	local t_dungeon = g_nestDungeonData:parseNestDungeonID(stage_id)
    return t_dungeon['dungeon_mode']
end

-------------------------------------
-- function getDungeonIDFromStateID
-- @brief
-------------------------------------
function ServerData_NestDungeon:getDungeonIDFromStateID(stage_id)
    return stage_id - (stage_id % 100)
end


-------------------------------------
-- function checkNeedUpdateNestDungeonInfo
-- @brief 네스트 던전 항목을 갱신해야 하는지 확인하는 함수
-------------------------------------
function ServerData_NestDungeon:checkNeedUpdateNestDungeonInfo()
    local l_dungeon_list = self:getNestDungeonInfo()

    local server_time = ServerTime:getInstance():getCurrentTimestampSeconds()
    local time_stamp

    for i,v in pairs(l_dungeon_list) do
        -- 고대 유적 던전은 체크하지 않음
        if (v['sub_mode'] == NEST_DUNGEON_ANCIENT_RUIN) then
            return false
        end

        -- 오픈되어있는 던전일 경우 닫힐 때까지의 시간
        if (v['is_open'] == 1) then
            time_stamp = (v['next_invalid_at'] / 1000)

        -- 닫혀있는 던전일 경우 열릴 때까지의 시간
        else
            time_stamp = (v['next_valid_at'] / 1000)
        end
        
        if (time_stamp <= server_time) then
            self.m_bDirtyNestDungeonInfo = true
            return true
        end
    end

    return false
end

-------------------------------------
-- function updateNestDungeonTimer
-- @brief
-------------------------------------
function ServerData_NestDungeon:updateNestDungeonTimer(dungeon_id)
    local t_dungeon_info = self.m_nestDungeonInfoMap[dungeon_id]

    -- 서버상의 시간을 얻어옴
    local server_time = ServerTime:getInstance():getCurrentTimestampSeconds()
	
	local _next_valid_at = t_dungeon_info['next_valid_at']
	local _next_invalid_at = t_dungeon_info['next_invalid_at'] or 0 -- 닫혔을 경우 invaild 값을 주지 않음

    -- 1000분의 1초 -> 1초로 단위 변경
    local next_valid_at = math_floor( _next_valid_at/ 1000)
    t_dungeon_info['remain_valid_time'] = (next_valid_at - server_time)

    -- 1000분의 1초 -> 1초로 단위 변경
    local next_invalid_at = math_floor( _next_invalid_at/ 1000)
    t_dungeon_info['remain_invalid_time'] = (next_invalid_at - server_time)

    do -- 정보 갱신이 필요한지 여부 체크
        local time_stamp
        if (t_dungeon_info['is_open'] == 1) then
            time_stamp = next_invalid_at
        else
            time_stamp = next_valid_at
        end
        
        if (time_stamp <= server_time) then
            t_dungeon_info['dirty_info'] = true
            self.m_bDirtyNestDungeonInfo = true
        end
    end


    return t_dungeon_info
end

-------------------------------------
-- function checkNestDungeonOpen
-- @brief 네스트 던전 항목을 갱신해야 하는지 확인하는 함수
-------------------------------------
function ServerData_NestDungeon:checkNestDungeonOpen(stage_id)
    local dungeon_id = self:getDungeonIDFromStateID(stage_id)
    local t_dungeon_info = self.m_nestDungeonInfoMap[dungeon_id]

    local server_time = ServerTime:getInstance():getCurrentTimestampSeconds()

    local time_stamp
    if (t_dungeon_info['is_open'] == 1) then
        -- 닫히는 시간
        time_stamp = (t_dungeon_info['next_invalid_at'] / 1000)
        return (server_time < time_stamp)
    else
        -- 열리는 시간
        time_stamp = (t_dungeon_info['next_valid_at'] / 1000)
        return (server_time > time_stamp)
    end

    return false
end

-------------------------------------
-- function getNestDungeonRemainTimeText
-- @brief dungeon_id에 해당하는 던전의 남은 시간 텍스트 리턴
--        열린 던전일 경우 닫힐 때까지의 시간
--        닫힌 던전일 경우 열릴 때까지의 시간
-------------------------------------
function ServerData_NestDungeon:getNestDungeonRemainTimeText(dungeon_id)
    -- 던전 남은 시간 업데이트
    local t_dungeon_info = self:updateNestDungeonTimer(dungeon_id)

    local text = ''

    -- 열려있는 던전일 경우
    if (t_dungeon_info['is_open'] == 1) then
        local sec = t_dungeon_info['remain_invalid_time']
        sec = math_max(sec, 0)
        local showSeconds = true
        local firstOnly = false
        text = datetime.makeTimeDesc(sec, showSeconds, firstOnly)
        text = Str('{1} 남음', text)

    -- 닫혀있는 던전일 경우
    else
        local sec = t_dungeon_info['remain_valid_time']
        sec = math_max(sec, 0)
        local showSeconds = true
        local firstOnly = false
        text = datetime.makeTimeDesc(sec, showSeconds, firstOnly)
        text = Str('{1} 후 열림', text)
    end

    return text, t_dungeon_info['dirty_info']
end

-------------------------------------
-- function requestNestDungeonStageList
-- @brief 서버로부터 네스트던전 스테이지 리스트를 받아옴
-------------------------------------
function ServerData_NestDungeon:requestNestDungeonStageList(cb_func)
    local uid = g_userData:get('uid')

    -- 성공 시 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)

        if ret['stage_list'] then
            self:applyNestDungeonStageList(ret['stage_list'])
        end

        if cb_func then
            cb_func()
        end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/game/stage/list')
    ui_network:setParam('uid', uid)
    ui_network:setParam('type', GAME_MODE_NEST_DUNGEON) -- GAME_MODE_ANCIENT_RUIN 던전 정보까지 받아옴
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(success_cb)
    ui_network:request()
end

-------------------------------------
-- function applyNestDungeonStageList
-- @brief 서버에서 전달받은 데이터를 클라이언트에 적용
-------------------------------------
function ServerData_NestDungeon:applyNestDungeonStageList(data)

    -- 서버에서 줄여진 key명칭을 사용
    for i,v in pairs(data) do
        if v['cl_cnt'] then
            v['clear_cnt'] = v['cl_cnt']
        end
    end

    self.m_serverData:applyServerData(data, 'nest_dungeon_stage_list')
end

-------------------------------------
-- function applyNestDungeonStageListWithCheckID
-- @brief 서버에서 전달받은 데이터를 클라이언트에 적용 (users/title에서 모험 stage와 함께 받은 경우)
-------------------------------------
function ServerData_NestDungeon:applyNestDungeonStageListWithCheckID(data)
    -- 서버에서 줄여진 key명칭을 사용
    local new_data = {}

    for stage_id,v in pairs(data) do
        local mode = getDigit(tonumber(stage_id), 100000, 2)
        if (mode == GAME_MODE_NEST_DUNGEON or mode == GAME_MODE_ANCIENT_RUIN) then
            new_data[stage_id] = {}
            if v['cl_cnt'] then
                new_data[stage_id]['clear_cnt'] = v['cl_cnt']
            end
        end
    end

    self.m_serverData:applyServerData(new_data, 'nest_dungeon_stage_list')
end

-------------------------------------
-- function getNestDungeonStageClearInfo
-- @brief
-------------------------------------
function ServerData_NestDungeon:getNestDungeonStageClearInfo(stage_id)
    local t_stage_clear_info = self:getNestDungeonStageClearInfoRef(stage_id)
    return clone(t_stage_clear_info)
end

-------------------------------------
-- function getNestDungeonStageClearInfoRef
-- @brief
-------------------------------------
function ServerData_NestDungeon:getNestDungeonStageClearInfoRef(stage_id)
    local t_stage_clear_info = self.m_serverData:getRef('nest_dungeon_stage_list', tostring(stage_id))

    if (not t_stage_clear_info) then
        t_stage_clear_info = {}
        t_stage_clear_info['clear_cnt'] = 0
        self.m_serverData:applyServerData(t_stage_clear_info, 'nest_dungeon_stage_list', tostring(stage_id))
    end

    return t_stage_clear_info
end

-------------------------------------
-- function applyNestStageClearCnt
-- @brief 스테이지 클리어 횟수 저장
-------------------------------------
function ServerData_NestDungeon:applyNestStageClearCnt(stage_id, cnt)
    self.m_serverData:applyServerData(cnt, 'nest_dungeon_stage_list', tostring(stage_id), 'clear_cnt')
end

-------------------------------------
-- function isOpenStage
-- @brief
-------------------------------------
function ServerData_NestDungeon:isOpenStage(stage_id)
    local prev_stage_id = self:getPrevStageID(stage_id)

    if (not prev_stage_id) then
        return true
    else
        local t_dungeon_id_info = g_nestDungeonData:getNestDungeonStageClearInfo(prev_stage_id)
        local is_open = (0 < t_dungeon_id_info['clear_cnt'])
        return is_open
    end
end

-------------------------------------
-- function getPrevStageID
-- @brief
-------------------------------------
function ServerData_NestDungeon:getPrevStageID(stage_id)
    local t_dungeon_id_info = g_nestDungeonData:parseNestDungeonID(stage_id)
    
    if (t_dungeon_id_info['tier'] <= 1) then
        return nil
    else
        return (stage_id - 1)
    end
end

-------------------------------------
-- function getSimplePrevStageID
-- @brief 같은 종류의 네스트 던전에서 티어만 내려간 스테이지
-------------------------------------
function ServerData_NestDungeon:getSimplePrevStageID(stage_id)
    local t_dungeon_id_info = g_nestDungeonData:parseNestDungeonID(stage_id)
    
    if (t_dungeon_id_info['tier'] <= 1) then
        return nil
    else
        return (stage_id - 1)
    end
end

-------------------------------------
-- function getNextStageID
-- @brief
-------------------------------------
function ServerData_NestDungeon:getNextStageID(stage_id)
    local table_drop = TableDrop()
    local t_drop = table_drop:get(stage_id + 1)

    if t_drop then
        return stage_id + 1
    else
        return nil
    end
end

-------------------------------------
-- function getSimpleNextStageID
-- @brief 같은 종류의 네스트 던전에서 티어만 올라간 스테이지
-------------------------------------
function ServerData_NestDungeon:getSimpleNextStageID(stage_id)
    local table_drop = TableDrop()
    local t_drop = table_drop:get(stage_id + 1)

    if t_drop then
        return stage_id + 1
    else
        return nil
    end
end

-------------------------------------
-- function getStageName
-------------------------------------
function ServerData_NestDungeon:getStageName(stage_id)
    local t_dungeon_id_info = self:parseNestDungeonID(stage_id)

    local table_drop = TableDrop()
    local t_drop = table_drop:get(stage_id)
    local name = Str(t_drop['t_name']) .. ' ' .. Str('{1}단계', t_dungeon_id_info['tier'])

    return name
end

-------------------------------------
-- function getStageCategoryStr
-- @brief
-------------------------------------
function ServerData_NestDungeon:getStageCategoryStr(stage_id)
    local t_dungeon_id_info = self:parseNestDungeonID(stage_id)

    -- 네스트 세부 모드
    local dungeon_mode = t_dungeon_id_info['dungeon_mode']
    local mode_str = ''
    if (dungeon_mode == NEST_DUNGEON_EVO_STONE) then
        mode_str = Str('거대용 던전')

    elseif (dungeon_mode == NEST_DUNGEON_NIGHTMARE) then
        mode_str = Str('악몽 던전')

    elseif (dungeon_mode == NEST_DUNGEON_TREE) then
        mode_str = Str('거목 던전')

    elseif (dungeon_mode == NEST_DUNGEON_GOLD) then
        mode_str = Str('황금 던전')
    
    elseif (dungeon_mode == NEST_DUNGEON_ANCIENT_RUIN) then
        mode_str = Str('고대 유적 던전')

    else
        error('dungeon_mode : ' .. dungeon_mode)
    end

    

    return Str('네스트던전') .. ' > ' .. mode_str
end

-------------------------------------
-- function getNestModeStaminaType
-------------------------------------
function ServerData_NestDungeon:getNestModeStaminaType(dungeon_id)
    local stage_id = dungeon_id + 1
    local stamina_type = TableDrop:getStageStaminaType(stage_id)
    return stamina_type
end

-------------------------------------
-- function isClearNightmare
-- @brief 악몽 던전 모든 스테이지 클리어 여부
-------------------------------------
function ServerData_NestDungeon:isClearNightmare()
    -- 악몽 던전 마지막 스테이지 ID
    local last_stage_id = 1220110

    -- 네스트 던전 정보 받아옴 (타이틀 화면에서 서버에서 받아옴)
    local t_dungeon_id_info = self:getNestDungeonStageClearInfo(last_stage_id)
    if (not t_dungeon_id_info) then
        return false
    end

    local clear_cnt = (t_dungeon_id_info['clear_cnt'] or 0)
    local is_clear = (0 < clear_cnt)
    return is_clear
end