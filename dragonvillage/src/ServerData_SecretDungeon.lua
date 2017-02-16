local NO_NETWORK = true

-------------------------------------
-- class ServerData_SecretDungeon
-------------------------------------
ServerData_SecretDungeon = class({
        m_serverData = 'ServerData',
        m_secretDungeonInfoMap = 'table(map)',
        m_bDirtySecretDungeonInfo = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_SecretDungeon:init(server_data)
    self.m_serverData = server_data
    self.m_bDirtySecretDungeonInfo = true
end

-------------------------------------
-- function applySecretDungeonInfo
-- @breif 서버에서 전달받은 데이터를 클라이언트에 적용
-------------------------------------
function ServerData_SecretDungeon:applySecretDungeonInfo(data)
    self.m_serverData:applyServerData(data, 'secret_info')

    -- 맵의 형태로 사용
    local l_secret_info = self.m_serverData:getRef('secret_info')
    self.m_secretDungeonInfoMap = {}
    for i,v in ipairs(l_secret_info) do
        local dungeon_id = v['mode_id']
        self.m_secretDungeonInfoMap[dungeon_id] = v

        -- 닫히는 시간이 임박했을 때를 위한 테스트 코드 (10초 후 갱신되도록)
        --v['next_invalid_at'] = (Timer:getServerTime() + 10) * 1000
    end

    self.m_bDirtySecretDungeonInfo = false
end

-------------------------------------
-- function getSecretDungeonInfo
-- @brief 비밀 던전 리스트 항목 얻어옴
--        거대용, 악몽, 거목
-------------------------------------
function ServerData_SecretDungeon:getSecretDungeonInfo()
    local l_secret_info = self.m_serverData:getRef('secret_info')
    local l_ret = clone(l_secret_info)
    return l_ret
end

-------------------------------------
-- function getSecretDungeonInfoIndividual
-- @brief 비밀 던전 리스트 항목 얻어옴
--        황금, 인연
-------------------------------------
function ServerData_SecretDungeon:getSecretDungeonInfoIndividual(stage_id)
    local dungeon_id = self:getDungeonIDFromStateID(stage_id)
    
    local l_dungeon_list = self:getSecretDungeonInfo()

    for i,v in ipairs(l_dungeon_list) do
        if (v['mode_id'] == dungeon_id) then
            return v
        end
    end

    return nil
end

-------------------------------------
-- function getSecretDungeonListForUI
-- @brief 비밀 던전 리스트 항목 얻어옴 (UI 전용)
-------------------------------------
function ServerData_SecretDungeon:getSecretDungeonListForUI()
    local l_dungeon_list = self:getSecretDungeonInfo()

    do -- 악몽(2)던전은 sub_mode가 1인 항목만 포함
       -- 악몽던전에 스테이지 리스트는 공통으로 표시하기 때문
        local t_remove = {}
        for i,v in ipairs(l_dungeon_list) do
            if (v['mode'] == 2) and (v['sub_mode']~=1) then
                table.insert(t_remove, 1, i)
            elseif (v['is_open'] == 0) then
                table.insert(t_remove, 1, i)
            end
        end

        for i,v in ipairs(t_remove) do
            table.remove(l_dungeon_list, v)
        end
    end

    do -- 오픈되고 mode_id가 빠른 순으로 정렬
        local function sort_func(a, b) 
            if a['is_open'] > b['is_open'] then
                return true
            elseif a['is_open'] < b['is_open'] then
                return false
            end

            return a['mode_id'] < b['mode_id']
        end

        table.sort(l_dungeon_list, sort_func)
    end

    return l_dungeon_list
end

-------------------------------------
-- function requestSecretDungeonInfo
-- @brief 서버로부터 비밀던전 open정보를 받아옴
-------------------------------------
function ServerData_SecretDungeon:requestSecretDungeonInfo(cb_func)
    if (not self.m_bDirtySecretDungeonInfo) then
        if cb_func then
            cb_func()
        end
        return
    end

    if (not NO_NETWORK) then
        local uid = g_userData:get('uid')

        -- 성공 시 콜백
        local function success_cb(ret)
            g_serverData:networkCommonRespone(ret)

            if ret['secret_info'] then
                self:applySecretDungeonInfo(ret['secret_info'])
            end

            if cb_func then
                cb_func()
            end
        end

        local ui_network = UI_Network()
        ui_network:setUrl('/game/secret/info')
        ui_network:setParam('uid', uid)
        ui_network:setRevocable(true)
        ui_network:setSuccessCB(function(ret) success_cb(ret) end)
        ui_network:request()

    else
        if cb_func then
            cb_func()
        end
    end
end

-------------------------------------
-- function getSecretDungeon_stageList
-- @brief 비밀 던전 스테이지 리스트
-------------------------------------
function ServerData_SecretDungeon:getSecretDungeon_stageList()
    local l_stage_list = {}

    if (NO_NETWORK) then
        -- 비밀던전의 세부 모드별 스테이지 리스트를 조건 체크
        local function condition_func(t_table)
            local stage_id = t_table['stage']
            local t_info = self:parseSecretDungeonID(stage_id)
            if (t_info['stage_mode'] == GAME_MODE_SECRET_DUNGEON) then
                return true
            else
                return false
            end
        end

        -- 테이블에서 조건에 맞는 테이블만 리턴
        local table_drop = TableDrop()
        l_stage_list = table_drop:filterList_condition(condition_func)

        -- stage(stage_id) 순서로 정렬
        local function sort_func(a, b)
            return a['stage'] < b['stage']
        end
        table.sort(l_stage_list, sort_func)

    end

    return l_stage_list
end

-------------------------------------
-- function getSecretDungeon_stageListForUI
-- @brief 비밀 던전 모드별 스테이지 리스트 (UI 전용)
-------------------------------------
function ServerData_SecretDungeon:getSecretDungeon_stageListForUI()
    local l_dungeon_list = self:getSecretDungeon_stageList()

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

    return l_dungeon_list
end

-------------------------------------
-- function parseSecretDungeonID
-- @brief 비밀 
--        거대용, 악몽, 거목
-------------------------------------
function ServerData_SecretDungeon:parseSecretDungeonID(stage_id)
    -- 21101
    -- 2xxxx 모드 구분 (비밀 던전 모드)
    --  1xxx 비밀 던전 구분 (황금, 인연)
    --   1xx 세부 모드 (속성 or role)
    --    01 티어 (통상적으로 1~10)

    local t_dungeon_id_info = {}
    t_dungeon_id_info['stage_mode'] = getDigit(stage_id, 10000, 1)
    t_dungeon_id_info['dungeon_mode'] = getDigit(stage_id, 1000, 1)
    t_dungeon_id_info['detail_mode'] = getDigit(stage_id, 100, 1)
    t_dungeon_id_info['tier'] = getDigit(stage_id, 1, 2)

    return t_dungeon_id_info
end

-------------------------------------
-- function getDungeonIDFromStateID
-- @brief
-------------------------------------
function ServerData_SecretDungeon:getDungeonIDFromStateID(stage_id)
    return stage_id - (stage_id % 100)
end

-------------------------------------
-- function updateSecretDungeonTimer
-- @brief
-------------------------------------
function ServerData_SecretDungeon:updateSecretDungeonTimer(stage_id)
    local t_dungeon_info
    
    if (NO_NETWORK) then
        local t_info = ServerData_SecretDungeon:parseSecretDungeonID(stage_id)
        if (t_info['dungeon_mode'] == SECRET_DUNGEON_GOLD) then
            stage_id = 31001
        end

        local table_secret_dungeon = TableSecretDungeon():get(stage_id)

        t_dungeon_info = {
            is_open = 1,
            remain_invalid_time = table_secret_dungeon['playable_time'],
            dirty_info = false
        }

    else
        t_dungeon_info = self.m_secretDungeonInfoMap[stage_id]

        -- 서버상의 시간을 얻어옴
        local server_time = Timer:getServerTime()

        -- 1000분의 1초 -> 1초로 단위 변경
        local next_valid_at = math_floor(t_dungeon_info['next_valid_at'] / 1000)
        t_dungeon_info['remain_valid_time'] = (next_valid_at - server_time)

        -- 1000분의 1초 -> 1초로 단위 변경
        local next_invalid_at = math_floor(t_dungeon_info['next_invalid_at'] / 1000)
        t_dungeon_info['remain_invalid_time'] = (next_invalid_at - server_time)

        do -- 정보 갱신이 필요한지 여부 체크
            local time_stamp
            if (t_dungeon_info['is_open'] == 1) then
                time_stamp = (t_dungeon_info['next_invalid_at'] / 1000)
            else
                time_stamp = (t_dungeon_info['next_valid_at'] / 1000)
            end
        
            if (time_stamp <= server_time) then
                t_dungeon_info['dirty_info'] = true
                self.m_bDirtySecretDungeonInfo = true
            end
        end
    end


    return t_dungeon_info
end

-------------------------------------
-- function getSecretDungeonRemainTimeText
-- @brief dungeon_id에 해당하는 던전의 남은 시간 텍스트 리턴
--        열린 던전일 경우 닫힐 때까지의 시간
--        닫힌 던전일 경우 열릴 때까지의 시간
-------------------------------------
function ServerData_SecretDungeon:getSecretDungeonRemainTimeText(dungeon_id)
    -- 던전 남은 시간 업데이트
    local t_dungeon_info = self:updateSecretDungeonTimer(dungeon_id)

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
-- function requestSecretDungeonStageList
-- @brief 서버로부터 비밀던전 스테이지 리스트를 받아옴
-------------------------------------
function ServerData_SecretDungeon:requestSecretDungeonStageList(cb_func)
    local uid = g_userData:get('uid')

    -- 성공 시 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)

        if ret['stage_list'] then
            self:applySecretDungeonStageList(ret['stage_list'])
        end

        if cb_func then
            cb_func()
        end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/game/stage/list')
    ui_network:setParam('uid', uid)
    ui_network:setParam('type', 2)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()
end

-------------------------------------
-- function applySecretDungeonStageList
-- @brief 서버에서 전달받은 데이터를 클라이언트에 적용
-------------------------------------
function ServerData_SecretDungeon:applySecretDungeonStageList(data)
    self.m_serverData:applyServerData(data, 'secret_dungeon_stage_list')
end

-------------------------------------
-- function getSecretDungeonStageClearInfo
-- @brief
-------------------------------------
function ServerData_SecretDungeon:getSecretDungeonStageClearInfo(stage_id)
    local t_stage_clear_info = self:getSecretDungeonStageClearInfoRef(stage_id)
    return clone(t_stage_clear_info)
end

-------------------------------------
-- function getSecretDungeonStageClearInfoRef
-- @brief
-------------------------------------
function ServerData_SecretDungeon:getSecretDungeonStageClearInfoRef(stage_id)
    local t_stage_clear_info = self.m_serverData:getRef('secret_dungeon_stage_list', tostring(stage_id))

    if (not t_stage_clear_info) then
        t_stage_clear_info = {}
        t_stage_clear_info['clear_cnt'] = 0
        self.m_serverData:applyServerData(t_stage_clear_info, 'secret_dungeon_stage_list', tostring(stage_id))
    end

    return t_stage_clear_info
end

-------------------------------------
-- function isOpenStage
-- @brief
-------------------------------------
function ServerData_SecretDungeon:isOpenStage(stage_id)
    return true
end

-------------------------------------
-- function getPrevStageID
-- @brief
-------------------------------------
function ServerData_SecretDungeon:getPrevStageID(stage_id)
    local t_dungeon_id_info = g_secretDungeonData:parseSecretDungeonID(stage_id)
    
    if (t_dungeon_id_info['tier'] <= 1) then
        return nil
    else
        return (stage_id - 1)
    end
end

-------------------------------------
-- function getSimplePrevStageID
-- @brief 같은 종류의 비밀 던전에서 티어만 내려간 스테이지
-------------------------------------
function ServerData_SecretDungeon:getSimplePrevStageID(stage_id)
    local t_dungeon_id_info = g_secretDungeonData:parseSecretDungeonID(stage_id)
    
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
function ServerData_SecretDungeon:getNextStageID(stage_id)
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
-- @brief 같은 종류의 비밀 던전에서 티어만 올라간 스테이지
-------------------------------------
function ServerData_SecretDungeon:getSimpleNextStageID(stage_id)
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
function ServerData_SecretDungeon:getStageName(stage_id)
    local t_dungeon_id_info = self:parseSecretDungeonID(stage_id)

    local table_drop = TableDrop()
    local t_drop = table_drop:get(stage_id)
    local name = Str(t_drop['t_name'])

    return name
end

-------------------------------------
-- function getStageCategoryStr
-- @brief
-------------------------------------
function ServerData_SecretDungeon:getStageCategoryStr(stage_id)
    local t_dungeon_id_info = self:parseSecretDungeonID(stage_id)

    -- 비밀 세부 모드
    local dungeon_mode = t_dungeon_id_info['dungeon_mode']
    local mode_str = ''
    if (dungeon_mode == SECRET_DUNGEON_GOLD) then
        mode_str = Str('황금 던전')

    elseif (dungeon_mode == SECRET_DUNGEON_RELATION) then
        mode_str = Str('인연 던전')

    else
        error('dungeon_mode : ' .. dungeon_mode)
    end

    

    return Str('비밀던전') .. ' > ' .. mode_str
end

-------------------------------------
-- function goToSecretDungeonScene
-------------------------------------
function ServerData_SecretDungeon:goToSecretDungeonScene(stage_id)
    local request_secret_dungeon_info
    local request_secret_dungeon_stage_list
    local replace_scene

    -- 비밀 던전 리스트 정보 얻어옴
    request_secret_dungeon_info = function()
        g_secretDungeonData:requestSecretDungeonInfo(request_secret_dungeon_stage_list)
    end

    -- 비밀 던전 스테이지 리스트 얻어옴
    request_secret_dungeon_stage_list = function()
        g_secretDungeonData:requestSecretDungeonStageList(replace_scene)
    end

    -- 비밀 던전 씬으로 전환
    replace_scene = function()
        local scene = SceneSecretDungeon(stage_id)
        scene:runScene()
    end

    --request_secret_dungeon_info()
    replace_scene()
end