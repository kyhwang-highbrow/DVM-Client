local NO_NETWORK = false

-------------------------------------
-- class ServerData_SecretDungeon
-------------------------------------
ServerData_SecretDungeon = class({
        m_serverData = 'ServerData',
        m_secretDungeonInfo = 'table(list)',
        m_secretDungeonInfoMap = 'table(map)',
        m_bDirtySecretDungeonInfo = 'boolean',

		m_bSecretDungeonExist = 'boolean',

        -- 선택된 던전ID
        m_selectedDungeonID = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_SecretDungeon:init(server_data)
    self.m_serverData = server_data
    self.m_secretDungeonInfo = {}
    self.m_secretDungeonInfoMap = {}
    self.m_bDirtySecretDungeonInfo = true
	self.m_bSecretDungeonExist = false

    self.m_selectedDungeonID = nil
end

-------------------------------------
-- function applySecretDungeonInfo
-- @breif 서버에서 전달받은 데이터를 클라이언트에 적용
-------------------------------------
function ServerData_SecretDungeon:applySecretDungeonInfo(data)
    self.m_serverData:applyServerData(data, 'secret_dungeon_list')

    -- 맵의 형태로 사용
    local l_secret_info = self.m_serverData:getRef('secret_dungeon_list')
    self.m_secretDungeonInfo = clone(l_secret_info)

    for _, v in pairs(self.m_secretDungeonInfo) do
        local id = v['id']
        self.m_secretDungeonInfoMap[id] = v
    end

    local function sort_func(a, b)
        return a['closetime'] < b['closetime']
    end

    table.sort(self.m_secretDungeonInfo, sort_func)

	-- 인연던전 노티를 위하여 존재 여부 체크
	self.m_bSecretDungeonExist = (table.count(self.m_secretDungeonInfo) > 0)

    self.m_bDirtySecretDungeonInfo = false
end

-------------------------------------
-- function setFindSecretDungeon
-- @brief 비밀던전을 발견시
-------------------------------------
function ServerData_SecretDungeon:setFindSecretDungeon(dungeon_info)
    self.m_bDirtySecretDungeonInfo = true
end

-------------------------------------
-- function getSecretDungeonInfo
-------------------------------------
function ServerData_SecretDungeon:getSecretDungeonInfo()
    return self.m_secretDungeonInfo
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
    
    local uid = g_userData:get('uid')

    -- 성공 시 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)

        if ret['secret_dungeon_list'] then
            self:applySecretDungeonInfo(ret['secret_dungeon_list'])
        end

        if cb_func then
            cb_func()
        end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/game/secret/info')
    ui_network:setLoadingMsg(Str('인연의 흔적을 흝어보는 중...'))
    ui_network:setParam('uid', uid)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function parseSecretDungeonID
-- @brief 비밀 
--        거대용, 악몽, 거목
-------------------------------------
function ServerData_SecretDungeon:parseSecretDungeonID(stage_id)
    -- 1310101
    -- 13xxxxx 모드 구분 (비밀 던전 모드)
    --   1xxxx 비밀 던전 구분 (황금, 인연)
    --    01xx 세부 모드 (속성 or role)
    --      01 티어 (통상적으로 1~10)

    local t_dungeon_id_info = {}
    t_dungeon_id_info['stage_mode'] = getDigit(stage_id, 100000, 1)
    t_dungeon_id_info['dungeon_mode'] = getDigit(stage_id, 10000, 1)
    t_dungeon_id_info['detail_mode'] = getDigit(stage_id, 100, 2)
    t_dungeon_id_info['tier'] = getDigit(stage_id, 1, 2)

    return t_dungeon_id_info
end

-------------------------------------
-- function checkNeedUpdateSecretDungeonInfo
-- @brief 비밀 던전 항목을 갱신해야 하는지 확인하는 함수
-------------------------------------
function ServerData_SecretDungeon:checkNeedUpdateSecretDungeonInfo()
    local l_dungeon_list = self:getSecretDungeonInfo()

    local server_time = ServerTime:getInstance():getCurrentTimestampSeconds()
    local time_stamp

    for i,v in pairs(l_dungeon_list) do

        local time_stamp = (v['closetime'] / 1000)

        if (time_stamp <= server_time) then
            self.m_bDirtySecretDungeonInfo = true
            return true
        end
    end

    return false
end

-------------------------------------
-- function updateSecretDungeonTimer
-- @brief
-------------------------------------
function ServerData_SecretDungeon:updateSecretDungeonTimer(dungeon_id)
    local t_dungeon_info = self.m_secretDungeonInfoMap[dungeon_id]

    -- 서버상의 시간을 얻어옴
    local server_time = ServerTime:getInstance():getCurrentTimestampSeconds()

    -- 1000분의 1초 -> 1초로 단위 변경
    local next_invalid_at = math_floor(t_dungeon_info['closetime'] / 1000)
    t_dungeon_info['remain_invalid_time'] = (next_invalid_at - server_time)

    do -- 정보 갱신이 필요한지 여부 체크
        local time_stamp = (t_dungeon_info['closetime'] / 1000)
        
        if (time_stamp <= server_time) then
            t_dungeon_info['dirty_info'] = true
            self.m_bDirtySecretDungeonInfo = true
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

    local sec = t_dungeon_info['remain_invalid_time']
    sec = math_max(sec, 0)
    local showSeconds = true
    local firstOnly = false
    text = ServerTime:getInstance():makeTimeDescToSec(sec, showSeconds, firstOnly)
    text = Str('{1} 남음', text)

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
    ui_network:setParam('type', GAME_MODE_SECRET_DUNGEON)
    ui_network:setRevocable(true)
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()
end

-------------------------------------
-- function applySecretDungeonStageList
-- @brief 서버에서 전달받은 데이터를 클라이언트에 적용
-------------------------------------
function ServerData_SecretDungeon:applySecretDungeonStageList(data)

    -- 서버에서 줄여진 key명칭을 사용
    for i,v in pairs(data) do
        if v['cl_cnt'] then
            v['clear_cnt'] = v['cl_cnt']
        end
    end

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
function ServerData_SecretDungeon:isOpenStage(dungeon_id)
    
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
function ServerData_SecretDungeon:getStageName(dungeon_id)
    local t_dungeon_info = self.m_secretDungeonInfoMap[dungeon_id]
    if not t_dungeon_info then return end

    local stage_id = t_dungeon_info['stage']
    local t_dungeon_id_info = self:parseSecretDungeonID(stage_id)
    local dungeon_mode = t_dungeon_id_info['dungeon_mode']

    local name

    -- 인연던전의 경우는 드래곤 이름을 추가
    if (dungeon_mode == SECRET_DUNGEON_GOLD) then
        name = Str('황금 던전')

    elseif (dungeon_mode == SECRET_DUNGEON_RELATION) then
        local did = t_dungeon_info['dragon']
        local dragon_name = TableDragon():getValue(did, 't_name')

        name = Str(dragon_name)
    end

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
-- function getLastMonsterIcon
-- @brief
-------------------------------------
function ServerData_SecretDungeon:getLastMonsterIcon(dungeon_id)
    local t_dungeon_info = self.m_secretDungeonInfoMap[dungeon_id]
    if not t_dungeon_info then return end

    local stage_id = t_dungeon_info['stage']
    local t_dungeon_id_info = self:parseSecretDungeonID(stage_id)
    local dungeon_mode = t_dungeon_id_info['dungeon_mode']
    local icon

    if (dungeon_mode == SECRET_DUNGEON_GOLD) then
        icon = TableStageDesc():getLastMonsterIcon(stage_id)

    elseif (dungeon_mode == SECRET_DUNGEON_RELATION) then
        -- 인연 던전의 경우는 등장 드래곤의 아이콘을 사용
        local did = t_dungeon_info['dragon']
        icon = MakeSimpleDragonCard(did)
        
    end

    return icon
end

-------------------------------------
-- function getMonsterIDList
-------------------------------------
function ServerData_SecretDungeon:getMonsterIDList(stage_id)
    local t_info = g_secretDungeonData:parseSecretDungeonID(stage_id)

    local ret = nil

    if (t_info['dungeon_mode'] == SECRET_DUNGEON_RELATION) then
        local t_dungeon_info = self:getSelectedSecretDungeonInfo()
        if (not t_dungeon_info) then return end

        ret = { t_dungeon_info['dragon'] }

    else
        local table_stage_desc = TableStageDesc()
        if (not table_stage_desc:get(stage_id)) then return end

        ret = table_stage_desc:getMonsterIDList(stage_id)

    end

    return ret
end

-------------------------------------
-- function selectDungeonID
-------------------------------------
function ServerData_SecretDungeon:selectDungeonID(dungeon_id)
    self.m_selectedDungeonID = dungeon_id
end

-------------------------------------
-- function getSelectedSecretDungeonInfo
-- @brief 선택되었던 비밀 던전 정보를 얻어옴
-------------------------------------
function ServerData_SecretDungeon:getSelectedSecretDungeonInfo()
    local id = self.m_selectedDungeonID
    if (not id) then return end

    local t_dungeon_info = self.m_secretDungeonInfoMap[id]
    return t_dungeon_info
end

-------------------------------------
-- function setSecretDungeonExist
-------------------------------------
function ServerData_SecretDungeon:setSecretDungeonExist(b)
	self.m_bSecretDungeonExist = b
end

-------------------------------------
-- function isSecretDungeonExist
-------------------------------------
function ServerData_SecretDungeon:isSecretDungeonExist()
    return self.m_bSecretDungeonExist
end