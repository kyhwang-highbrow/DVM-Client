-------------------------------------
---@class ServerData
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
    self.m_rootTable = {}
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

    -- 시험의 탑
    g_attrTowerData = ServerData_AttrTower(g_serverData)

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

    -- 마을 알림 (lobby_notice)
    g_lobbyNoticeData = ServerData_LobbyNotice(g_serverData)

    -- 우편함
    g_mailData = ServerData_Mail(g_serverData)

    -- 아이템
    g_itemData = ServerData_Item(g_serverData)

    -- 출석체크
    g_attendanceData = ServerData_Attendance(g_serverData)

    -- 첫 충전 선물(첫 결제 보상)
    g_firstPurchaseEventData = ServerData_FirstPurchaseEvent(g_serverData)

    -- 누적 결제 보상
    g_purchasePointData = ServerData_PurchasePoint(g_serverData)

    -- 일일 결제 보상
    g_purchaseDailyData = ServerData_PurchaseDaily(g_serverData)

    -- 이벤트 교환소
    g_exchangeData = ServerData_Exchange(g_serverData)

    -- 접속시간 이벤트
    g_accessTimeData = ServerData_AccessTime(g_serverData)

    -- 탐험
    g_explorationData = ServerData_Exploration(g_serverData)

    -- 핫타임
    g_hotTimeData = ServerData_HotTime(g_serverData)
    g_fevertimeData = ServerData_Fevertime(g_serverData)

    -- 도감
    g_bookData = ServerData_Book(g_serverData)

    -- 이벤트
    g_eventData = ServerData_Event(g_serverData)

    -- 이벤트
    g_eventDiceData = ServerData_EventDice()

    -- 알파벳 이벤트
    g_eventAlphabetData = ServerData_EventAlphabet()

    -- 이벤트
    g_eventGoldDungeonData = ServerData_EventGoldDungeon()

    -- 이벤트
    g_eventMatchCardData = ServerData_EventMatchCard()

    -- 깜짝 출현 이벤트
    g_eventAdventData = ServerData_EventAdvent()

    -- 하일라이트
    g_highlightData = ServerData_Highlight(g_serverData)

	-- 랭킹
    g_rankData = ServerData_Ranking(g_serverData)

    -- 드래곤 픽율
    g_dragonPickRateData = ServerData_DragonPickRate(g_serverData)

	-- 진형
    g_formationData = ServerData_Formation(g_serverData)

    -- 진형
    g_formationArenaData = ServerData_FormationArena(g_serverData)

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
    g_advertisingData = ServerData_Advertising.getInstance()

    -- 광고 룰렛 (2022.12.16 @dhkim)
    g_advRouletteData = ServerData_Roulette(g_serverData)

    -- 진화재료
    g_evolutionStoneData = ServerData_EvolutionStone(g_serverData)

    -- 친선전
    g_friendMatchData = ServerData_FriendMatch(g_serverData)

    -- 드래곤의 숲
    ServerData_Forest:getInstance(g_serverData)

    -- 테이머 코스튬
    g_tamerCostumeData = ServerData_TamerCostume(g_serverData)

    -- 드래곤 스킨 (@dhkim 23.02.13 추가) 
    g_dragonSkinData = ServerData_DragonSkin(g_serverData)

    -- 교환 이벤트 
    g_exchangeEventData = ServerData_ExchangeEvent(g_serverData)

    -- 빙고 이벤트 
    g_eventBingoData = ServerData_EventBingo()

    -- 할로윈 룬 축제(할로윈 이벤트)
    g_eventRuneFestival = ServerData_EventRuneFestival()

    -- 레벨업 패키지
    g_levelUpPackageData = ServerData_LevelUpPackage(g_serverData)
    g_levelUpPackageDataOld = ServerData_LevelUpPackageOld(g_serverData)

    -- 모험돌파 패키지
    g_adventureClearPackageData01 = ServerData_AdventureClearPackage01(g_serverData)

    -- 모험돌파 패키지 (신규)
    g_adventureClearPackageData02 = ServerData_AdventureClearPackage02(g_serverData)

    -- 모험돌파 패키지 (2020.08.24)
    g_adventureClearPackageData03 = ServerData_AdventureClearPackage03(g_serverData)

    -- 모험 돌파 패키지
    g_adventureBreakthroughPackageData = ServerData_AdventureBreakthroughPackage(g_serverData)

    -- 시험의 탑 정복 선물 패키지 (2020.11.25)
    g_attrTowerPackageData = ServerData_AttrTowerPackage(g_serverData)

    -- 차원문 돌파 패키지 (21.05.18)
    g_dmgatePackageData = ServerData_DmgatePackage(g_serverData)
    
    -- 드래곤 획득 패키지
    g_getDragonPackage = ServerData_GetDragonPackage(g_serverData)

    -- 배틀패스 패키지
    g_battlePassData = ServerData_BattlePass(g_serverData)

    -- 클랜 던전 (땅) 패키지 (@dhkim 2023.01.12)
    g_clanDungeonEarthPackageData = ServerData_ClanRaidEarthPackage(g_serverData)
    -- 클랜 던전 (물) 패키지 (@dhkim 2023.01.12)
    g_clanDungeonWaterPackageData = ServerData_ClanRaidWaterPackage(g_serverData)
    -- 클랜 던전 (불) 패키지 (@dhkim 2023.01.12)
    g_clanDungeonFirePackageData = ServerData_ClanRaidFirePackage(g_serverData)
    -- 클랜 던전 (빛) 패키지 (@dhkim 2023.01.12)
    g_clanDungeonLightPackageData = ServerData_ClanRaidLightPackage(g_serverData)
    -- 클랜 던전 (어둠) 패키지 (@dhkim 2023.01.12)
    g_clanDungeonDarkPackageData = ServerData_ClanRaidDarkPackage(g_serverData)

    -- 클랜
    g_clanData = ServerData_Clan(g_serverData)
    
    -- 클랜 랭킹
    g_clanRankData = ServerData_ClanRank(g_serverData)

    -- 클랜 던전
    g_clanRaidData = ServerData_ClanRaid(g_serverData)

	-- 일일 미션
	g_dailyMissionData = ServerData_DailyMission(g_serverData)

	-- 캡슐 신전
	g_capsuleBoxData = ServerData_CapsuleBox(g_serverData)

    -- 드래곤 성장일지
    g_dragonDiaryData = ServerData_DragonDiary(g_serverData)

    -- 시즌
    g_seasonData = ServerData_Season(g_serverData)

    -- 고대 유적 던전
    g_ancientRuinData = ServerData_AncientRuin(g_serverData)
    
    -- 랜덤상점 
    g_randomShopData = ServerData_RandomShop(g_serverData)

    -- 콜로세움 (신규)
    g_arenaData = ServerData_Arena(g_serverData)

    -- 콜로세움 (개편 후)
    g_arenaNewData = ServerData_ArenaNew(g_serverData)

    -- 그랜드 콜로세움
    g_grandArena = ServerData_GrandArena(g_serverData)

    -- 챌린지 모드
    g_challengeMode = ServerData_ChallengeMode(g_serverData)

    -- 만드라고라의 모험 이벤트
    g_mandragoraQuest = ServerData_EventMandragoraQuest(g_serverData)

    -- 깜짝 할인 상품
    g_spotSaleData = ServerData_SpotSale(g_serverData)

    -- 특별제안 패키지
    g_personalpackData = ServerData_Personalpack()

    -- 환상 던전 이벤
    g_illusionDungeonData = Serverdata_IllusionDungeon()

    -- 클랜전
    g_clanWarData = ServerData_ClanWar()

    -- 원격 설정
    g_remoteConfig = ServerData_RemoteConfig()

    -- 보급소(정액제)
    g_supply = ServerData_Supply()

    -- 초보자 선물(신규 유저 전용 상점)
    g_newcomerShop = ServerData_NewcomerShop()

    -- 벼룩시장
    g_fleaShop = ServerData_FleaShop()

    -- 드래곤 이미지 퀴즈 이벤트
    g_eventImageQuizData = ServerData_EventImageQuiz()

    -- 복주머니 이벤트
    g_eventLFBagData = ServerData_EventLFBag()

    -- 죄악의 화신 토벌작전 이벤트
    g_eventIncarnationOfSinsData = ServerData_EventIncarnationOfSins()

    -- 룬 메모
    g_runeMemoData = ServerData_RuneMemo(g_serverData)

    -- 시련 (차원문)
    g_dmgateData = ServerData_Dmgate(g_serverData)

    --- 콜로세움 참여 이벤트
    g_eventArenaPlayData = ServerData_EventArenaPlay(g_serverData)

    --- 콜로세움 참여 이벤트
    g_leagueRaidData = ServerData_LeagueRaid(g_serverData)

    --- 콜로세움 참여 이벤트
    g_eventLeagueRaidData = ServerData_EventLeagueRaidPlay(g_serverData)

    --- 신규 드래곤 이벤트
    g_eventDragonStoryDungeon = ServerData_StoryDungeonEvent(g_serverData)

    -- Highbrow VIP 
    g_highbrowVipData = ServerData_HighbrowVip.getInstance(g_serverData)

    return g_serverData
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
            if (container[key] ~= data) then
                if (data ~= nil) then
                    container[key] = clone(data)
                else
                    container[key] = nil
                end
            end
        end
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
--     {
--         ['midnight']=1653436800000;
--         ['hour']=0;
--         ['timezone']='UTC';
--         ['server_time']=1653409423399;
-- }

    -- 시간
    if (ServerTime ~= nil) then
        -- ret['server_info'] 값이 있을 경우 갱신
        ServerTime:getInstance():applyResponse(ret)
    end


    if (ret['server_info'] and ret['server_info']['server_time']) then
        local server_time = math_floor(ret['server_info']['server_time'] / 1000)
        Timer:setServerTime(server_time)

        -- UTC 기준 시간 
        if (ret['server_info']['hour']) then
            local hour = ret['server_info']['hour'] 
            Timer:setUTCHour(hour)
        end

        -- timezone 
        if (ret['server_info']['timezone']) then
            local timezone = ret['server_info']['timezone'] 
            Timer:setTimeZone(timezone)
        end

        -- 서버 상의 자정 시간
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

		-- 토파즈
        if ret['topaz'] then
            self:applyServerData(ret['topaz'], 'user', 'topaz')
        end

        -- 드래곤 소환권
        if ret['summon_dragon_ticket'] then
            self:applyServerData(ret['summon_dragon_ticket'], 'user', 'summon_dragon_ticket')
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

        -- 알파벳 갱신
        if ret['alphabet'] then
            self:applyServerData(ret['alphabet'], 'user', 'alphabet')
        end
        
        -- 외형 변환 재료 갱신
        if ret['transform_materials'] then
            self:applyServerData(ret['transform_materials'], 'user', 'transform_materials')
        end

        -- 강화 포인트 갱신
        if ret['reinforce_point'] then
            self:applyServerData(ret['reinforce_point'], 'user', 'reinforce_point')
        end

        -- 티켓 갱신
        if ret['tickets'] then
            self:applyServerData(ret['tickets'], 'user', 'tickets')
        end

        -- 캡슐
        if ret['capsule'] then
            self:applyServerData(ret['capsule'], 'user', 'capsule')
        end
        
        -- 클랜 코인
        if ret['clancoin'] then
            self:applyServerData(ret['clancoin'], 'user', 'clancoin')
        end
		     
        -- 캡슐 코인
        if ret['capsule_coin'] then
            self:applyServerData(ret['capsule_coin'], 'user', 'capsule_coin')
        end

        -- 기억 (별의 기억)
        if ret['memory'] then
            self:applyServerData(ret['memory'], 'user', 'memory')
        end

        -- 룬 연마석
        if ret['grindstone'] then
            self:applyServerData(ret['grindstone'], 'user', 'grindstone')    
        end

        -- Max확정권
        if ret['max_fixed_ticket'] then
            self:applyServerData(ret['max_fixed_ticket'], 'user', 'max_fixed_ticket')    
        end

        -- 옵션 유지권
        if ret['opt_keep_ticket'] then
            self:applyServerData(ret['opt_keep_ticket'], 'user', 'opt_keep_ticket')    
        end

        -- 고대 주화
        if ret['ancient'] then
            self:applyServerData(ret['ancient'], 'user', 'ancient')
        end

        -- 메달 (210330 기준 차원문 보상)
        if ret['medal'] then
            self:applyServerData(ret['medal'], 'user', 'medal')
        end

        -- 자동줍기 아이템
        if ret['auto_root'] then
            self:applyServerData(ret['auto_root'], 'user', 'auto_root')
        end

        -- 아모르의 서
        if ret['amor'] then
            self:applyServerData(ret['amor'], 'user', 'amor')
        end

        -- 망각의 서
        if ret['oblivion'] then
            self:applyServerData(ret['oblivion'], 'user', 'oblivion')
        end

        -- 룬 축복서
        if ret['rune_bless'] then
            self:applyServerData(ret['rune_bless'], 'user', 'rune_bless')
        end

        -- 환상 던전 토큰
        if ret['illusion_token_01'] then
            self:applyServerData(ret['illusion_token_01'], 'user', 'event_illusion')
        end

        -- 드래곤의 먹이
        if ret['dragon_food'] then
            self:applyServerData(ret['dragon_food'], 'user', 'dragon_food')
        end

        -- 드래곤 경험치
        if ret['dragon_exp'] then
            self:applyServerData(ret['dragon_exp'], 'user', 'dragon_exp')
        end

        -- 룬 10개 뽑기 상자
        if ret['rune_box'] then
            self:applyServerData(ret['rune_box'], 'user', 'rune_box')
        end

        -- 룬 10개 뽑기 다이아 소모량
        if ret['rune_gacha_cash'] then
            self:applyServerData(ret['rune_gacha_cash'], 'user', 'rune_gacha_cash')
        end

        -- 찬란한 날개
        if ret['st_100'] then
            self:applyServerData(ret['st_100'], 'user', 'st_100')
        end

        -- 이벤트 토큰
        if ret['event_token'] then
            self:applyServerData(ret['event_token'], 'user', 'event_token')
        end

        -- 드래곤 스킨 리스트 갱신
        if (ret['dragon_skins']) then
            self:applyServerData(ret['dragon_skins'], 'user', 'dragon_skins')
        end

		-- 모든 특성 재료 (구 공통 특성 재료 포함)
        -- @mskim 기존 mastery_materials_02~04를 mastery_materials 컨테이너로 통합하여 수령함
        if ret['mastery_materials'] then
            self:applyServerData(ret['mastery_materials'], 'user', 'mastery_materials')
        end

        -- 스토리 던전 이벤트 토큰
        if ret['token_story_dungeon'] then
            self:applyServerData(ret['token_story_dungeon'], 'user', 'token_story_dungeon')
        end

        -- 스토리 던전 이벤트 티켓
        if ret['ticket_story_dungeon'] then
            self:applyServerData(ret['ticket_story_dungeon'], 'user', 'ticket_story_dungeon')
        end

        -- 용맹훈장
        if ret['valor'] then
            self:applyServerData(ret['valor'], 'user', 'valor')
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

    -- 코스튬 획득 정보 갱신
    if (ret['tamers_costume']) then
        g_tamerCostumeData:applyTamersCostume(ret['tamers_costume'])
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
    
    -- 기억 (갱신)
    RefreshGoods(t_added_items, 'memory')

    -- 열매 갯수 (전체 갱신)
    RefreshGoods(t_added_items, 'fruits')

    -- 알 갯수 (전체 갱신)
    RefreshGoods(t_added_items, 'eggs')

    -- 진화 재료 갱신 (전체 갱신)
    RefreshGoods(t_added_items, 'evolution_stones')

    -- 알파뱃 갱신 (전체 갱신)
    RefreshGoods(t_added_items, 'alphabet')

    -- 외형 변환 갱신 (전체 갱신)
    RefreshGoods(t_added_items, 'transform_materials')

    -- 강화 포인트 (전체 갱신)
    RefreshGoods(t_added_items, 'reinforce_point')

    -- 티켓 갱신 (전체 갱신)
    RefreshGoods(t_added_items, 'tickets')

    -- 스태미나 동기화 (전체 갱신)
    RefreshGoods(t_added_items, 'staminas')

    -- 클랜 코인 동기화 (전체 갱신)
    RefreshGoods(t_added_items, 'clancoin')
	
	-- 캡슐 코인 동기화 (전체 갱신)
    RefreshGoods(t_added_items, 'capsule_coin')

    -- 아모르의 서
    RefreshGoods(t_added_items, 'amor')

    -- 망각의 서
    RefreshGoods(t_added_items, 'oblivion')

     -- 룬 연마석
    RefreshGoods(t_added_items, 'grindstone')

    -- Max확정권
    RefreshGoods(t_added_items, 'max_fixed_ticket')

    -- 옵션 유지권
    RefreshGoods(t_added_items, 'opt_keep_ticket')
    
    -- 룬 축복서
    RefreshGoods(t_added_items, 'rune_bless')

    -- 드래곤의 먹이
    RefreshGoods(t_added_items, 'dragon_food')

    -- 드래곤의 경험치
    RefreshGoods(t_added_items, 'dragon_exp')

    -- 룬 10개 뽑기 상자
    RefreshGoods(t_added_items, 'rune_box')
   
    -- 찬란한 날개
    RefreshGoods(t_added_items, 'st_100')

   -- 특성 재료
    RefreshGoods(t_added_items, 'mastery_materials')

    -- 메달 (차원의 문 보상)
    RefreshGoods(t_added_items, 'medal')

    -- 이벤트 토큰
    RefreshGoods(t_added_items, 'event_token')

    -- 드래곤 소환권
    RefreshGoods(t_added_items, 'summon_dragon_ticket')

    -- 드래곤 스킨
    RefreshGoods(t_added_items, 'dragon_skins')

    -- 스토리던전 소환권
    RefreshGoods(t_added_items, 'ticket_story_dungeon')

    -- 스토리던전 토큰
    RefreshGoods(t_added_items, 'token_story_dungeon')

    -- 용맹 훈장
    RefreshGoods(t_added_items, 'valor')

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

    -- [이벤트 재화]
    -- 소원 구슬
    if (t_added_items['lucky_fortune']) then
        g_eventLFBagData:setLFBagCount(t_added_items['lucky_fortune'])
        t_added_items['lucky_fortune'] = nil
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

-------------------------------------
-- function confirm_reward
-- @brief 보상 정보
-------------------------------------
function ServerData:confirm_reward(ret)
    if ret['item_info'] then
        UI_MailRewardPopup(ret['item_info'])

    elseif ret['mail_item_info'] then
        local toast_msg = Str('보상이 우편함으로 전송되었습니다.')
        UI_ToastPopup(toast_msg)

        g_highlightData:setHighlightMail()
    end
end

-------------------------------------
-- function receiveReward
-- @brief 보상 정보
-------------------------------------
function ServerData:receiveReward(ret)
    -- 우편, 토스트 알림
    if (ret['new_mail']) then
        local toast_msg = Str('보상이 우편함으로 전송되었습니다.')
        UI_ToastPopup(toast_msg)

        g_highlightData:setHighlightMail()

    -- 우편, 보상 리스트 팝업
    elseif (ret['mail_item_info']) then
        UI_MailRewardPopup(ret['mail_item_info'])
        
    -- 즉시 수령, 보상 리스트 팝업
    elseif (ret['added_items']) then
        g_serverData:networkCommonRespone_addedItems(ret)
        local l_item = ret['added_items']['items_list']
        UI_ObtainPopup(l_item)

    end
end

--[[

	-- 통신 형식 예시

	1. 통신 요청 함수 이름 request_XXXX
	2. 함수 변수 선언 후 함수 정의(권장/실행 순서대로 코드 짜기 위해)
	3. UI_Network()의 모든 Set함수 사용 권장
		a. 매개변수 Default값이 변경되었을 때 발생하는 오류 방지
		b. 다른 request함수 만들 때 참고할 수 있도록

	local func_request
	local fail_cb
	local response_status_cb
	local success_cb
    local finish_cb = finish_cb or function() end

	 -- 네트워크 통신
	func_request = function()
        local uid = g_userData:get('uid')

		local ui_network = UI_Network()				
		ui_network:setUrl('/shop/spot_sale')
		ui_network:setParam('uid', uid)
		ui_network:setParam('id', id)
		ui_network:setMethod('POST')			
		ui_network:setSuccessCB(success_cb)					-- 통신 성공 콜백
		ui_network:setFailCB(fail_cb)						-- 통신 실패 콜백
		ui_network:setResponseStatusCB(response_status_cb)	-- 통신 에러 리턴 콜백 (true를 리턴하면 자체적으로 처리를 완료했다는 뜻)/ ret['status']에 따른 처리 가능
		ui_network:setRevocable(false)						-- 통신 실패 팝업이 떴을 때 = true의 경우 통신 취소 가능/ false의 경우 통신 재시도만 가능
		ui_network:setReuse(false)							-- 통신 이후 UI 개폐 여부 =  false의 경우 통신 후 UI 닫힘 
		ui_network:request()
	end

	func_request()

	success_cb = function(ret)
		
    end


	fail_cb = function(ret)
       
	end

    response_status_cb = function(ret)
        return true
    end

--]]