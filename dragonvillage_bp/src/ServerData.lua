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

    -- 'tamers'
    g_tamerData = ServerData_Tamer(g_serverData)

    -- 'dragons'
    g_dragonsData = ServerData_Dragons(g_serverData)

    -- 슬라임
    g_slimesData = ServerData_Slimes(g_serverData)

    -- 'deck'
    g_deckData = ServerData_Deck(g_serverData)

    -- 'staminas' (user/staminas)
    g_staminasData = ServerData_Staminas(g_serverData)

    -- 'adventure'
    g_adventureData = ServerData_Adventure(g_serverData)
    g_adventureFirstRewardData = ServerData_AdventureFirstReward(g_serverData)

    -- 'nest_info'
    g_nestDungeonData = ServerData_NestDungeon(g_serverData)

    -- 'secret_info'
    g_secretDungeonData = ServerData_SecretDungeon(g_serverData)

    -- 고대의 탑
    g_ancientTowerData = ServerData_AncientTower(g_serverData)

    -- 스테이지 관련 유틸
    g_stageData = ServerData_Stage(g_serverData)

    -- 자동 플레이 설정
    g_autoPlaySetting = ServerData_AutoPlaySetting(g_serverData)

    -- 룬
    g_runesData = ServerData_Runes(g_serverData)

    -- 알 (eggs)
    g_eggsData = ServerData_Eggs(g_serverData)

    -- 부화소
    g_hatcheryData = ServerData_Hatchery(g_serverData)

	-- 퀘스트
    g_questData = ServerData_Quest(g_serverData)

    -- 가방
    g_inventoryData = ServerData_Inventory(g_serverData)

    -- 친구
    g_friendData = ServerData_Friend(g_serverData)

	-- 상점 및 가차
    g_shopDataNew = ServerData_Shop(g_serverData)

    -- 구독형 상품
    g_subscriptionData = ServerData_Subscription(g_serverData)

    -- 우편함
    g_mailData = ServerData_Mail(g_serverData)

    -- 아이템
    g_itemData = ServerData_Item(g_serverData)

    -- 출석체크
    g_attendanceData = ServerData_Attendance(g_serverData)

    -- 이벤트 교환소
    g_exchangeData = ServerData_Exchange(g_serverData)

    -- 접속시간 이벤트
    g_accessTimeData = ServerData_AccessTime(g_serverData)

    -- 탐험
    g_explorationData = ServerData_Exploration(g_serverData)

    -- 핫타임
    g_hotTimeData = ServerData_HotTime(g_serverData)

    -- 도감
    g_bookData = ServerData_Book(g_serverData)

    -- 이벤트
    g_eventData = ServerData_Event(g_serverData)

    -- 하일라이트
    g_highlightData = ServerData_Highlight(g_serverData)

	-- 랭킹
    g_rankData = ServerData_Ranking(g_serverData)

	-- 진형
    g_formationData = ServerData_Formation(g_serverData)

	-- 게시판
    g_boardData = ServerData_DragonBoard(g_serverData)
    
    -- 테이머 선택
    g_startTamerData = ServerData_StartTamer(g_serverData)

    -- 콜로세움
    g_colosseumData = ServerData_Colosseum(g_serverData)

    -- 마스터의 길
    g_masterRoadData = ServerData_MasterRoad(g_serverData)

    -- 콘텐츠 잠금
    g_contentLockData = ServerData_ContentLock(g_serverData)

    -- 자동 재화 줍기 (Auto Item Pick)
    g_autoItemPickData = ServerData_AutoItemPick(g_serverData)

    -- 튜토리얼
    g_tutorialData = ServerData_Tutorial(g_serverData)

    -- 하이브로
    g_highbrowData = ServerData_Highbrow(g_serverData)

    -- 광고
    g_advertisingData = ServerData_Advertising(g_serverData)

    -- 진화재료
    g_evolutionStoneData = ServerData_EvolutionStone(g_serverData)

    -- 친선전
    g_friendMatchData = ServerData_FriendMatch(g_serverData)

    -- 드래곤의 숲
    ServerData_Forest:getInstance(g_serverData)

    -- 테이머 코스튬
    g_tamerCostumeData = ServerData_TamerCostume(g_serverData)

    -- 교환 이벤트 
    g_exchangeEventData = ServerData_ExchangeEvent(g_serverData)

    -- 레벨업 패키지
    g_levelUpPackageData = ServerData_LevelUpPackage(g_serverData)

    -- 클랜
    g_clanData = ServerData_Clan(g_serverData)

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
        f:close()

        if (#content > 0) then
            self.m_rootTable = json_decode(content)
            return
        end
    end
        
    self.m_rootTable = {}
    self.m_rootTable['local'] = {}

    self:saveServerDataFile()
end

-------------------------------------
-- function saveServerDataFile
-------------------------------------
function ServerData:saveServerDataFile(force)
    if (not force) then
        return
    end

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

    local dirty = false

    local container = self.m_rootTable
    for i,key in ipairs(args) do
        if (i < cnt) then
            if (type(container[key]) ~= 'table') then
                container[key] = {}
                dirty = true
            end
            container = container[key]
        else
            if (container[key] ~= data) then
                if (data ~= nil) then
                    container[key] = clone(data)
                else
                    container[key] = nil
                end
                dirty = true
            end
        end
    end

    -- 변경사항이 있을 때에만 저장
    if dirty then
        self:saveServerDataFile()
    end
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
-- function networkCommonRespone
-- @breif 중복되는 코드를 방지하기 위해 ret값에 예약된 데이터를 한번에 처리
-------------------------------------
function ServerData:networkCommonRespone(ret)
    if (not ret) then
        return
    end

    -- 서버 시간 동기화
    if (ret['server_info'] and ret['server_info']['server_time']) then
        local server_time = math_floor(ret['server_info']['server_time'] / 1000)
        Timer:setServerTime(server_time)

        local server_midnight_time_stamp = ret['server_info']['midnight']
        if server_midnight_time_stamp then
            Timer.m_midnightTimeStamp = (server_midnight_time_stamp / 1000)
        end
    end

    -- 접속 시간 동기화
    if (ret['access_time']) then
        g_accessTimeData:networkCommonRespone(ret)
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

        -- 자수정
        if ret['amethyst'] then
            self:applyServerData(ret['amethyst'], 'user', 'amethyst')
        end

        -- 우정포인트
        if ret['fp'] then
            self:applyServerData(ret['fp'], 'user', 'fp')
        end

        -- 마일리지
        if ret['mileage'] then
            self:applyServerData(ret['mileage'], 'user', 'mileage')
        end

        -- 열매 갯수
        if ret['fruits'] then
            self:applyServerData(ret['fruits'], 'user', 'fruits')
        end

        -- 알 갯수
        if ret['eggs'] then
            self:applyServerData(ret['eggs'], 'user', 'eggs')
        end

        -- 진화 재료 갱신
        if ret['evolution_stones'] then
            self:applyServerData(ret['evolution_stones'], 'user', 'evolution_stones')
        end

        -- 티켓 갱신
        if ret['tickets'] then
            self:applyServerData(ret['tickets'], 'user', 'tickets')
        end

        -- 캡슐
        if ret['capsule'] then
            self:applyServerData(ret['capsule'], 'user', 'capsule')
        end
    end

	-- 퀘스트 갱신
    if (ret['quest_info']) then
        self:applyServerData(ret['quest_info'], 'quest_info')
    end

    -- 자동 재화 줍기 갱신
    if (ret['auto_item_pick']) then
        g_autoItemPickData:applyAutoItemPickData(ret['auto_item_pick'])
    end

    -- UI 하일라이트 정보 갱신
    g_highlightData:applyHighlightInfo(ret)
    
    -- 탑바 갱신
    if (g_topUserInfo) then
        g_topUserInfo:refreshData()
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
-- function RefreshGoods
-- @breif 이런 단순 반복적인 로직은 로컬함수나 Helper로 사용
-------------------------------------
local function RefreshGoods(t_ret, goods)
    if t_ret[goods] then
        g_serverData:applyServerData(t_ret[goods], 'user', goods)
        t_ret[goods] = nil
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

    t_added_items = clone(t_added_items)

    -- 캐시 (갱신)
    RefreshGoods(t_added_items, 'cash')

    -- 자수정 (갱신)
    RefreshGoods(t_added_items, 'amethyst')

    -- 골드 (갱신)
    RefreshGoods(t_added_items, 'gold')

    -- 우정포인트 (갱신)
    RefreshGoods(t_added_items, 'fp')

    -- 마일리지 (갱신)
    RefreshGoods(t_added_items, 'mileage')

    -- 명예 (갱신)
    RefreshGoods(t_added_items, 'honor')

    -- 훈장 (갱신)
    RefreshGoods(t_added_items, 'badge')

    -- 캡슐 (갱신)
    RefreshGoods(t_added_items, 'capsule')

    -- 열매 갯수 (전체 갱신)
    RefreshGoods(t_added_items, 'fruits')

    -- 알 갯수 (전체 갱신)
    RefreshGoods(t_added_items, 'eggs')

    -- 진화 재료 갱신 (전체 갱신)
    RefreshGoods(t_added_items, 'evolution_stones')

    -- 티켓 갱신 (전체 갱신)
    RefreshGoods(t_added_items, 'tickets')

    -- 스태미나 동기화 (전체 갱신)
    RefreshGoods(t_added_items, 'staminas')

    -- 드래곤 (추가)
    if t_added_items['dragons'] then
        g_dragonsData:applyDragonData_list(t_added_items['dragons'])
        t_added_items['dragons'] = nil
    end

    -- 슬라임 (추가)
    if t_added_items['slimes'] then
        g_slimesData:applySlimeData_list(t_added_items['slimes'])
        t_added_items['slimes'] = nil
    end

    -- 추가된 룬 적용 (추가)
    if t_added_items['runes'] then
        g_runesData:applyRuneData_list(t_added_items['runes'])
        t_added_items['runes'] = nil
    end

    -- 인연포인트 (전체 갱신)
    if (t_added_items['relation']) then
        g_bookData:applyRelationPoints(t_added_items['relation'])
        t_added_items['relation'] = nil
    end

    -- 이외에도 아이템 테이블에 존재하는 재화 정보는 갱신
    for k, v in pairs(t_added_items) do
        if (v) then
            local t_item = TableItem():getRewardItem(k)
            if (t_item) then
                self:applyServerData(v, 'user', k)
            end
        end
    end

    -- 탑바 갱신
    if (g_topUserInfo) then
        g_topUserInfo:refreshData()
    end
end

-------------------------------------
-- function setServerTable
-- @breif
-------------------------------------
function ServerData:setServerTable(ret, table_name)
    if (not ret[table_name]) then
        cclog('## table_name : "' .. table_name .. '" 테이블 정보를 서버에서 주지 않았습니다.')
        return
    end

    TABLE:setServerTable(table_name, ret[table_name])
end

-------------------------------------
-- function request_serverTables
-- @breif
-------------------------------------
function ServerData:request_serverTables(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        
        -- 서버에서 넘겨받는 테이블 저장
        local server_table_info = TABLE:getServerTableInfo()
        for table_name,_ in pairs(server_table_info) do
            self:setServerTable(ret, table_name)
        end

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/tables')
    ui_network:setParam('uid', uid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end