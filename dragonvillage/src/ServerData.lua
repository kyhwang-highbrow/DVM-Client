-------------------------------------
-- class ServerData
-------------------------------------
ServerData = class({
        m_rootTable = 'table',

        m_nLockCnt = 'number',
        m_bDirtyDataTable = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData:init()
    self.m_rootTable = nil
    self.m_nLockCnt = 0
    self.m_bDirtyDataTable = false
end

-------------------------------------
-- function getInstance
-------------------------------------
function ServerData:getInstance()
    if g_serverData then
        return g_serverData
    end
    
    g_serverData = ServerData()
    g_serverData:loadServerDataFile()

    -- 'user'
    g_userData = ServerData_User(g_serverData)

    -- 'dragons'
    g_dragonsData = ServerData_Dragons(g_serverData)

    -- 'deck'
    g_deckData = ServerData_Deck(g_serverData)

    -- 'staminas' (user/staminas)
    g_staminasData = ServerData_Staminas(g_serverData)

    -- 'nest_info'
    g_nestDungeonData = ServerData_NestDungeon(g_serverData)

    -- 'secret_info'
    g_secretDungeonData = ServerData_SecretDungeon(g_serverData)

    -- 스테이지 관련 유틸
    g_stageData = ServerData_Stage(g_serverData)

    -- 로비 유저 리스트
    g_lobbyUserListData = ServerData_LobbyUserList(g_serverData)

    -- 자동 플레이 설정
    g_autoPlaySetting = ServerData_AutoPlaySetting(g_serverData)

    -- 룬
    g_runesData = ServerData_Runes(g_serverData)

	-- 퀘스트
    g_questData = ServerData_Quest(g_serverData)

    -- 콜로세움
    g_colosseumData = ServerData_Colosseum(g_serverData)

    -- 인벤토리
    g_inventoryData = ServerData_Inventory(g_serverData)

    -- 친구
    g_friendData = ServerData_Friend(g_serverData)

	-- 상점 및 가차
    g_shopData = ServerData_Shop(g_serverData)

    -- 우편함
    g_mailData = ServerData_Mail(g_serverData)

    -- 아이템
    g_itemData = ServerData_Item(g_serverData)

    -- 가챠
    g_gachaData = ServerData_Gacha(g_serverData)

    return g_serverData
end

-------------------------------------
-- function getServerDataSaveFileName
-------------------------------------
function ServerData:getServerDataSaveFileName()
    local file = 'server_data.json'
    local path = cc.FileUtils:getInstance():getWritablePath()

    local full_path = string.format('%s%s', path, file)
    return full_path
end

-------------------------------------
-- function loadServerDataFile
-------------------------------------
function ServerData:loadServerDataFile()
    local f = io.open(self:getServerDataSaveFileName(), 'r')

    if f then
        local content = f:read('*all')

        if #content > 0 then
            self.m_rootTable = json.decode(content)
        end
        f:close()
    else
        self.m_rootTable = {}

        self.m_rootTable['local'] = {}

        -- 기본 설정 데이터
        self.m_rootTable['local']['lowResMode'] = false
        self.m_rootTable['local']['bgm'] = true
        self.m_rootTable['local']['sfx'] = true
        self.m_rootTable['local']['fps'] = false

        self:saveServerDataFile()
    end
end

-------------------------------------
-- function saveServerDataFile
-------------------------------------
function ServerData:saveServerDataFile()
    if (self.m_nLockCnt > 0) then
        self.m_bDirtyDataTable = true
        return
    end

    local f = io.open(self:getServerDataSaveFileName(),'w')
    if (not f) then
        return false
    end

    -- cclog(luadump(self.m_rootTable))
    local content = dkjson.encode(self.m_rootTable, {indent=true})
    f:write(content)
    f:close()

    return true
end

-------------------------------------
-- function clearServerDataFile
-------------------------------------
function ServerData:clearServerDataFile()
    os.remove(self:getServerDataSaveFileName())
end


-------------------------------------
-- function applyServerData
-- @brief 서버로부터 받은 정보로 세이브 데이터를 갱신
-------------------------------------
function ServerData:applyServerData(data, ...)
    local args = {...}
    local cnt = #args

    local container = self.m_rootTable
    for i,key in ipairs(args) do
        if (i < cnt) then
            if (type(container[key]) ~= 'table') then
                container[key] = {}
            end
            container = container[key]
        else
            if (data ~= nil) then
                container[key] = clone(data)
            else
                container[key] = nil
            end
        end
    end

    self:saveServerDataFile()
end

-------------------------------------
-- function get
-- @brief
-------------------------------------
function ServerData:get(...)
    local args = {...}
    local cnt = #args

    local container = self.m_rootTable
    for i,key in ipairs(args) do
        if (i < cnt) then
            if (type(container[key]) ~= 'table') then
                return nil
            end
            container = container[key]
        else
            if (container[key] ~= nil) then
                return clone(container[key])
            end
        end
    end

    return nil
end

-------------------------------------
-- function getRef
-- @brief
-------------------------------------
function ServerData:getRef(...)
    local args = {...}
    local cnt = #args

    local container = self.m_rootTable
    for i,key in ipairs(args) do
        if (i < cnt) then
            if (type(container[key]) ~= 'table') then
                return nil
            end
            container = container[key]
        else
            if (container[key] ~= nil) then
                return container[key]
            end
        end
    end

    return nil
end


-------------------------------------
-- function applySetting
-------------------------------------
function ServerData:applySetting()
    -- fps 출력
    local fps = self:get('local', 'fps')
    cc.Director:getInstance():setDisplayStats(fps)

    -- 저사양모드
    local lowResMode = self:get('local', 'lowResMode')
    setLowEndMode(lowResMode)

    -- 배경음
    local bgm = self:get('local', 'bgm')
    SoundMgr:setBgmOnOff(bgm)

    -- 효과음
    local sfx = self:get('local', 'sfx')
    SoundMgr:setSfxOnOff(sfx)
end

-------------------------------------
-- function developCache
-------------------------------------
function ServerData:developCache()
    if LocalServer then
        LocalServer['user_local_server'] = self:get('cache', 'user_local_server')
    end
end


-------------------------------------
-- function networkCommonRespone
-- @breif 중복되는 코드를 방지하기 위해 ret값에 예약된 데이터를 한번에 처리
-------------------------------------
function ServerData:networkCommonRespone(ret)
    -- 서버 시간 동기화
    if (ret['server_info'] and ret['server_info']['server_time']) then
        local server_time = math_floor(ret['server_info']['server_time'] / 1000)
        Timer:setServerTime(server_time)
    end

    -- 스태미나 동기화
    if (ret['staminas']) then
        local data = ret['staminas']
        self:applyServerData(data, 'user', 'staminas')
    end

    do -- 재화 관련
        -- 캐시
        if ret['cash'] then
            self:applyServerData(ret['cash'], 'user', 'cash')    
        end

        -- 골드
        if ret['gold'] then
            self:applyServerData(ret['gold'], 'user', 'gold')    
        end

        -- 우정포인트
        if ret['fp'] then
            self:applyServerData(ret['fp'], 'user', 'fp')
        end

        -- 열매 갯수
        if ret['fruits'] then
            self:applyServerData(ret['fruits'], 'user', 'fruits')
        end

        -- 진화 재료 갱신
        if ret['evolution_stones'] then
            g_serverData:applyServerData(ret['evolution_stones'], 'user', 'evolution_stones')
        end
    end

	-- 퀘스트 갱신
    if (ret['quest_info']) then
        self:applyServerData(ret['quest_info'], 'quest_info')
    end
end

-------------------------------------
-- function lockSaveData
-- @breif
-------------------------------------
function ServerData:lockSaveData()
    self.m_nLockCnt = (self.m_nLockCnt + 1)
end

-------------------------------------
-- function unlockSaveData
-- @breif
-------------------------------------
function ServerData:unlockSaveData()
    self.m_nLockCnt = (self.m_nLockCnt -1)

    if (self.m_nLockCnt <= 0) then
        if self.m_bDirtyDataTable then
            self:saveServerDataFile()
        end
        self.m_bDirtyDataTable = false
    end
end

-------------------------------------
-- function networkCommonRespone_addedItems
-- @breif 중복되는 코드를 방지하기 위해 ret값에 예약된 데이터를 한번에 처리
--        아이템 지급 부분
-------------------------------------
function ServerData:networkCommonRespone_addedItems(ret)
    local t_added_items = ret['added_items']

    if (not t_added_items) then
        return
    end


    -- 캐시 (갱신)
    if t_added_items['cash'] then
        self:applyServerData(t_added_items['cash'], 'user', 'cash')    
    end

    -- 골드 (갱신)
    if t_added_items['gold'] then
        self:applyServerData(t_added_items['gold'], 'user', 'gold')    
    end

    -- 우정포인트 (갱신)
    if t_added_items['fp'] then
        self:applyServerData(t_added_items['fp'], 'user', 'fp')
    end

    -- 명예 (갱신)
    if t_added_items['honor'] then
        self:applyServerData(t_added_items['honor'], 'user', 'honor')
    end

    -- 훈장 (갱신)
    if t_added_items['badge'] then
        self:applyServerData(t_added_items['badge'], 'user', 'badge')
    end

    -- 라테아 (갱신)
    if t_added_items['lactea'] then
        self:applyServerData(t_added_items['lactea'], 'user', 'lactea')    
    end

    -- 열매 갯수 (전체 갱신)
    if t_added_items['fruits'] then
        self:applyServerData(t_added_items['fruits'], 'user', 'fruits')
    end

    -- 진화 재료 갱신 (전체 갱신)
    if t_added_items['evolution_stones'] then
        self:applyServerData(t_added_items['evolution_stones'], 'user', 'evolution_stones')
    end

    -- 스태미나 동기화 (전체 갱신)
    if (t_added_items['staminas']) then
        self:applyServerData(t_added_items['staminas'], 'user', 'staminas')
    end

    -- 드래곤 (추가)
    if t_added_items['dragons'] then
        g_dragonsData:applyDragonData_list(t_added_items['dragons'])
    end

    -- 추가된 룬 적용 (추가)
    if t_added_items['runes'] then
        g_runesData:applyRuneData_list(t_added_items['runes'])
    end

    --t_added_items['tickets']
end