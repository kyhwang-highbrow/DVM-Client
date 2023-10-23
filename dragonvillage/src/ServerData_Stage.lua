-------------------------------------
-- class ServerData_Stage
-------------------------------------
ServerData_Stage = class({
        m_serverData = 'ServerData',

        -- 인게임 드랍 아이템 정보 저장
        m_ingameDropItemGameKey = 'number',
        m_ingameDropItemList = 'list',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Stage:init(server_data)
    self.m_serverData = server_data
end


-------------------------------------
-- function getGameMode
-------------------------------------
function ServerData_Stage:getGameMode(stage_id)

    if (stage_id == ARENA_STAGE_ID) then
        return GAME_MODE_ARENA
    elseif (stage_id == ARENA_NEW_STAGE_ID) then
        return GAME_MODE_ARENA_NEW
    elseif (stage_id == CHALLENGE_MODE_STAGE_ID) then
        return GAME_MODE_CHALLENGE_MODE

    -- 그랜드 콜로세움 (이벤트 PvP 10대10)
    elseif (stage_id == GRAND_ARENA_STAGE_ID) then
        return GAME_MODE_EVENT_ARENA
	-- 환상 던전 이벤트
	elseif (math.floor(stage_id/10000) == GAME_MODE_EVENT_ILLUSION_DUNSEON) then
		return GAME_MODE_EVENT_ILLUSION_DUNSEON
    --  레이드 스테이지
	elseif (math.floor(stage_id/10000) == GAME_MODE_LEAGUE_RAID) then
		return GAME_MODE_LEAGUE_RAID
    end

    -- 10만 자리부터 2자리의 숫자를 가져옴
    -- e.g. 1401001-고대의 탑 1층은 14가 리턴됨. 14는 GAME_MODE_ANCIENT_TOWER
    local game_mode = getDigit(stage_id, 100000, 2)
    return game_mode
end

-------------------------------------
-- function checkEventStage
-------------------------------------
function ServerData_Stage:checkEventStage(stage_id)
    local drop_table = TABLE:get('drop')
    local stage_data = drop_table[stage_id]
    
    return (stage_data['mode'] == 'event')
end

-------------------------------------
-- function isRuneFestivalStage
-------------------------------------
function ServerData_Stage:isRuneFestivalStage(stage_id)
    local difficulty, chapter, stage = parseAdventureID(stage_id)
    
    if (chapter == SPECIAL_CHAPTER.RUNE_FESTIVAL) then
        return true
    else
        return false
    end
end

-------------------------------------
-- function getStageName
-------------------------------------
function ServerData_Stage:getStageName(stage_id)
    local game_mode = self:getGameMode(stage_id)

    local name = ''

    -- 모험 모드
    if (game_mode == GAME_MODE_ADVENTURE) then
        local difficulty, chapter, stage = parseAdventureID(stage_id)
        if (chapter == SPECIAL_CHAPTER.ADVENT) then
            local chapter_name = g_eventAdventData:getAdventTitle()
            name = string.format('%s - %d', chapter_name, stage)  
        --룬 축제 이벤트
        elseif (chapter == SPECIAL_CHAPTER.RUNE_FESTIVAL) then
            local chapter_name = chapterName(chapter)
            name = string.format('%s %d', chapter_name, difficulty) -- 난이도 4개로 구성 (보통, 어려움, 지옥, 불지옥)
        else
            local chapter_name = chapterName(chapter)
            name = string.format('%s %d-%d', chapter_name, chapter, stage)
        end

    -- 네스트 던전 모드
    elseif (game_mode == GAME_MODE_NEST_DUNGEON) then
        name = g_nestDungeonData:getStageName(stage_id)

    -- 비밀 던전 모드
    elseif (game_mode == GAME_MODE_SECRET_DUNGEON) then
        local t_dungeon_info = g_secretDungeonData:getSelectedSecretDungeonInfo()
        if (t_dungeon_info) then
            local id = t_dungeon_info['id']
            name = g_secretDungeonData:getStageName(id)
        else
            name = Str('비밀 던전')
        end

    -- 고대의 탑 / 시험의 탑
    elseif (game_mode == GAME_MODE_ANCIENT_TOWER) then
        local attr = g_attrTowerData:getSelAttr()
        if (attr) then
            name = g_attrTowerData:getStageName(stage_id)
        else
            name = g_ancientTowerData:getStageName(stage_id)
        end
        
    -- 클랜던전
    elseif (game_mode == GAME_MODE_CLAN_RAID) then
        local struct_raid = g_clanRaidData:getClanRaidStruct()
        if (struct_raid:isTrainingMode()) then
            name = Str('클랜 던전 연습 전투')
        elseif (struct_raid:isEventIncarnationOfSinsMode()) then
            name = Str('죄악의 화신 토벌작전')
        else
            name = Str('클랜 던전')
        end

    -- 콜로세움 모드
    elseif (game_mode == GAME_MODE_COLOSSEUM) then
        name = Str('콜로세움')

    -- 인트로 전투
    elseif (game_mode == GAME_MODE_INTRO) then
        name = Str('시나리오 전투')

    -- 황금던전
    elseif (game_mode == GAME_MODE_EVENT_GOLD) then
        name = Str('황금 던전')

    -- 고대유적던전
    elseif (game_mode == GAME_MODE_ANCIENT_RUIN) then
        name = g_ancientRuinData:getStageName(stage_id)

    -- 룬 수호자 던전
    elseif (game_mode == GAME_MODE_RUNE_GUARDIAN) then
        name = Str('룬 수호자 던전')

    -- 그랜드 콜로세움
    elseif (game_mode == GAME_MODE_EVENT_ARENA) then
        name = Str('그랜드 콜로세움')
	
    -- 환상 던전 이벤트
    elseif (game_mode == GAME_MODE_EVENT_ILLUSION_DUNSEON) then
		name = g_illusionDungeonData:getIllusionStageTitle()

    -- 차원문
    elseif (game_mode == GAME_MODE_DIMENSION_GATE) then
		--name = TABLE:get('stage_data')[stage_id]['t_name']
        name = g_dmgateData:getStageName(stage_id)

    -- 스테이지
    else
        name = Str(TableStageData():getValue(stage_id, 't_name'))
    end

    return name
end

-------------------------------------
-- function getStageName
-------------------------------------
function ServerData_Stage:getStageDesc(stage_id)
    local table_stage_desc = TableStageDesc()

    return table_stage_desc:getStageDesc(stage_id)
end
-------------------------------------
-- function isOpenStage
-------------------------------------
function ServerData_Stage:isOpenStage(stage_id)
    local game_mode = self:getGameMode(stage_id)

    local ret = false

    -- 모험 모드
    if (game_mode == GAME_MODE_ADVENTURE) then
        ret = g_adventureData:isOpenStage(stage_id)

    -- 네스트 던전 모드
    elseif (game_mode == GAME_MODE_NEST_DUNGEON) then
        ret = g_nestDungeonData:isOpenStage(stage_id)

    -- 비밀 던전 모드
    elseif (game_mode == GAME_MODE_SECRET_DUNGEON) then
        ret = g_secretDungeonData:isOpenStage(stage_id)

    -- 고대의 탑 모드
    elseif (game_mode == GAME_MODE_ANCIENT_TOWER) then
        local attr = g_attrTowerData:getSelAttr()
        -- 시험의 탑
        if (attr) then
            ret = g_attrTowerData:isOpenStage(stage_id)

        -- 고대의 탑
        else
            ret = g_ancientTowerData:isOpenStage(stage_id)
        end

    -- 이벤트 금화 모드
    elseif (game_mode == GAME_MODE_EVENT_GOLD) then
        ret = true

    -- 클랜 던전 모드
    elseif (game_mode == GAME_MODE_CLAN_RAID) then
        ret = g_clanRaidData:isOpenClanRaid()

    -- 고대 유적 던전 모드
    elseif (game_mode == GAME_MODE_ANCIENT_RUIN) then
        ret = g_nestDungeonData:isOpenStage(stage_id)

    -- 룬 수호자 던전 (모든 스테이지가 열린 상태로 시작)
    elseif (game_mode == GAME_MODE_RUNE_GUARDIAN) then
        ret = true

    -- 그랜드 콜로세움 (이벤트 PvP 10대10)
    elseif (game_mode == GAME_MODE_EVENT_ARENA) then
        ret = true

    -- 시련 던전
    elseif (game_mode == GAME_MODE_DIMENSION_GATE) then
        ret = true

    -- 스토리 던전 모드
    elseif (game_mode == GAME_MODE_STORY_DUNGEON) then
        ret = g_eventDragonStoryDungeon:isOpenStage(stage_id)

    -- 딜킹 이벤트
    elseif (game_mode == GAME_MODE_EVENT_DEALKING) then
        ret = g_eventDealkingData:canPlay()
        
    end

    return ret
end

-------------------------------------
-- function getNextStage
-------------------------------------
function ServerData_Stage:getNextStage(stage_id)
    local game_mode = self:getGameMode(stage_id)

    local ret = nil

    -- 모험 모드
    if (game_mode == GAME_MODE_ADVENTURE) then
        ret = g_adventureData:getNextStageID(stage_id)

    -- 네스트 던전 모드
    elseif (game_mode == GAME_MODE_NEST_DUNGEON) then
        ret = g_nestDungeonData:getNextStageID(stage_id)

    -- 비밀 던전 모드
    elseif (game_mode == GAME_MODE_SECRET_DUNGEON) then
        ret = g_secretDungeonData:getNextStageID(stage_id)

    -- 고대의 탑 모드
    elseif (game_mode == GAME_MODE_ANCIENT_TOWER) then
        local attr = g_attrTowerData:getSelAttr()
        if (attr) then
            ret = g_attrTowerData:getNextStageID(stage_id)
        else
            ret = g_ancientTowerData:getNextStageID(stage_id)
        end

    -- 클랜 던전 모드
    elseif (game_mode == GAME_MODE_CLAN_RAID) then
        ret = g_clanRaidData:getNextStageID(stage_id)

    -- 고대 유적 던전 모드
    elseif (game_mode == GAME_MODE_ANCIENT_RUIN) then
        ret = g_ancientRuinData:getNextStageID(stage_id)

    -- 스토리 던전 모드
    elseif (game_mode == GAME_MODE_STORY_DUNGEON) then
        ret = g_eventDragonStoryDungeon:getNextStageID(stage_id)
    
    -- 룬 수호자 던전 (다음 스테이지 개념 없음)
    elseif (game_mode == GAME_MODE_RUNE_GUARDIAN) then

    end

    return ret
end

-------------------------------------
-- function getSimpleNextStage
-- @brief 같은 챕터 안에서 다음 스테이지
-------------------------------------
function ServerData_Stage:getSimpleNextStage(stage_id)
    local game_mode = self:getGameMode(stage_id)

    local ret = nil

    -- 모험 모드
    if (game_mode == GAME_MODE_ADVENTURE) then
        ret = g_adventureData:getSimpleNextStageID(stage_id)

    -- 네스트 던전 모드
    elseif (game_mode == GAME_MODE_NEST_DUNGEON) then
        ret = g_nestDungeonData:getSimpleNextStageID(stage_id)

    -- 비밀 던전 모드
    elseif (game_mode == GAME_MODE_SECRET_DUNGEON) then
        ret = g_secretDungeonData:getSimpleNextStageID(stage_id)

    -- 룬 수호자 던전 (다음 스테이지 개념 없음)
    elseif (game_mode == GAME_MODE_RUNE_GUARDIAN) then

    end

    return ret
end

-------------------------------------
-- function getSimplePrevStage
-- @brief 같은 챕터 안에서 이전 스테이지
-------------------------------------
function ServerData_Stage:getSimplePrevStage(stage_id)
    local game_mode = self:getGameMode(stage_id)

    local ret = nil

    -- 모험 모드
    if (game_mode == GAME_MODE_ADVENTURE) then
        ret = g_adventureData:getSimplePrevStageID(stage_id)

    -- 네스트 던전 모드
    elseif (game_mode == GAME_MODE_NEST_DUNGEON) then
        ret = g_nestDungeonData:getSimplePrevStageID(stage_id)

    -- 비밀 던전 모드
    elseif (game_mode == GAME_MODE_SECRET_DUNGEON) then
        ret = g_secretDungeonData:getSimplePrevStageID(stage_id)

    -- 고대의 탑 모드
    elseif (game_mode == GAME_MODE_ANCIENT_TOWER) then
        local attr = g_attrTowerData:getSelAttr()
        -- 시험의 탑
        if (attr) then
            ret = g_attrTowerData:getSimplePrevStageID(stage_id)

        -- 고대의 탑
        else
            ret = g_ancientTowerData:getSimplePrevStageID(stage_id)
        end

    -- 클랜 던전 모드
    elseif (game_mode == GAME_MODE_CLAN_RAID) then
        ret = g_clanRaidData:getSimplePrevStageID(stage_id)

    -- 고대 유적 던전 모드
    elseif (game_mode == GAME_MODE_ANCIENT_RUIN) then
        ret = g_ancientRuinData:getSimplePrevStageID(stage_id)
    
    -- 룬 수호자 던전 (다음 스테이지 개념 없음)
    elseif (game_mode == GAME_MODE_RUNE_GUARDIAN) then
    
    end


    return ret
end

-------------------------------------
-- function setFocusStage
-------------------------------------
function ServerData_Stage:setFocusStage(stage_id)
    local game_mode = self:getGameMode(stage_id)

    -- 모험 모드
    if (game_mode == GAME_MODE_ADVENTURE) then
        g_adventureData:setFocusStage(stage_id)
    end
end


-------------------------------------
-- function requestGameStart
-------------------------------------
function ServerData_Stage:requestGameStart(stage_id, deck_name, combat_power, finish_cb, fail_cb)
    local uid = g_userData:get('uid')
    local oid
    local response_status_cb

    -- 모드별 API 주소 분기처리
    local api_url = ''
    local game_mode = g_stageData:getGameMode(stage_id)
    local attr
    local teambonus_ids
    local ui_network = UI_Network()

    if (game_mode == GAME_MODE_ADVENTURE) then
        api_url = '/game/stage/start'

        local difficulty, chapter, stage = parseAdventureID(stage_id)
        local save_key = Str('{1}_{2}', chapter, stage)
        local msg

        local save_list = {'1_1','1_2','1_3','1_4'}
        for _, v in ipairs(save_list) do
            if (save_key == v) then
                msg = string.format('Stage_%s_Start', save_key)
            end
        end

        if (msg) then
            -- @analytics
            Analytics:firstTimeExperience(msg)
        end

    elseif (game_mode == GAME_MODE_NEST_DUNGEON) then
        api_url = '/game/nest/start'

        -- true를 리턴하면 자체적으로 처리를 완료했다는 뜻
        response_status_cb = function(ret)
            if (ret['status'] == -1350) then
                -- 전투 UI로 이동
                local function ok_cb()
                    UINavigator:goTo('battle_menu', 'dungeon')
                end 
                MakeSimplePopup(POPUP_TYPE.OK, Str('이미 종료된 던전입니다.'), ok_cb)
                return true
            end

            return false
        end

    elseif (game_mode == GAME_MODE_SECRET_DUNGEON) then
        api_url = '/game/secret/start'

        -- 던전 objectId
        local t_dungeon_info = g_secretDungeonData:getSelectedSecretDungeonInfo()
        oid = t_dungeon_info['id']

        -- true를 리턴하면 자체적으로 처리를 완료했다는 뜻
        response_status_cb = function(ret)
            if (ret['status'] == -1350) then
                -- 전투 UI로 이동
                local function ok_cb()
                    UINavigator:goTo('battle_menu', 'dungeon')
                end 
                MakeSimplePopup(POPUP_TYPE.OK, Str('이미 종료된 던전입니다.'), ok_cb)
                return true
            end

            return false
        end

    elseif (game_mode == GAME_MODE_ANCIENT_TOWER) then
        local _attr = g_attrTowerData:getSelAttr()
        -- 시험의 탑
        if (_attr) then
            attr = _attr
            teambonus_ids = g_stageData:getTeamBonusIds(deck_name)
            api_url = '/game/attr_tower/start'

        -- 고대의 탑
        else
            teambonus_ids = g_stageData:getTeamBonusIds(deck_name)
            api_url = '/game/ancient/start'
        end
    elseif (game_mode == GAME_MODE_EVENT_GOLD) then
        api_url = '/game/event_dungeon/start'

        -- true를 리턴하면 자체적으로 처리를 완료했다는 뜻
        response_status_cb = function(ret)
            if (ret['status'] == -1350) then
                -- 전투 UI로 이동
                local function ok_cb()
                    UINavigator:goTo('battle_menu', 'dungeon')
                end 
                MakeSimplePopup(POPUP_TYPE.OK, Str('이미 종료된 던전입니다.'), ok_cb)
                return true
            end

            return false
        end

    -- 룬 수호자 던전
    elseif (game_mode == GAME_MODE_RUNE_GUARDIAN) then
        api_url = '/game/rune_guardian/start'
        
    -- 차원의 문
    elseif (game_mode == GAME_MODE_DIMENSION_GATE) then 
        api_url = '/dmgate/start'

        response_status_cb = function(ret)
            if(ret['status'] == -1364) then
                g_dmgateData:MakeSeasonEndedPopup()
                return true
            end

            return false
        end

    -- 레이드
    elseif (game_mode == GAME_MODE_LEAGUE_RAID) then 
        api_url = '/raid/start'
        ui_network:setParam('deck_name1', 'league_raid_1')
        ui_network:setParam('deck_name2', 'league_raid_2')
        ui_network:setParam('deck_name3', 'league_raid_3')
        
        -- 덱 검증을 위한 토큰 생성
        ui_network:setParam('token1', self:makeDragonToken('league_raid_1'))
        ui_network:setParam('token2', self:makeDragonToken('league_raid_2'))
        ui_network:setParam('token3', self:makeDragonToken('league_raid_3'))
        
        g_leagueRaidData:resetIngameData()

        response_status_cb = function(ret)
            if(ret['status'] == -1364) then
                MakeSimplePopup(POPUP_TYPE.OK, Str('입장 가능한 시간이 아닙니다.'), ok_cb)
                return true
            end

            return false
        end

    -- 스토리 던전
    elseif (game_mode == GAME_MODE_STORY_DUNGEON) then
        api_url = '/game/story_dungeon/start'

        -- true를 리턴하면 자체적으로 처리를 완료했다는 뜻
        response_status_cb = function(ret)
            if (ret['status'] == -1350) then
                -- 전투 UI로 이동
                local function ok_cb()
                    UINavigator:goTo('battle_menu', 'dungeon')
                end 
                MakeSimplePopup(POPUP_TYPE.OK, Str('이미 종료된 던전입니다.'), ok_cb)
                return true
            end

            if ret['status'] == -2128 then
                MakeSimplePopup(POPUP_TYPE.OK, Str('이벤트가 종료되었습니다.'), function () 
                    UINavigator:goTo('lobby')
                end)
                return true
            end



            return false
        end

    end

    if (not response_status_cb) then
        response_status_cb = function(ret)
        if(ret['status'] == -2150) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('하루 날개 사용 제한을 초과했습니다.'), ok_cb)
            return true
        end

        return false
        end
    end

    local function success_cb(ret)
        -- server_info, staminas 정보를 갱신
        g_serverData:networkCommonRespone(ret)

        local game_key = ret['gamekey']
        finish_cb(game_key)

        -- 인게임 아이템 드랍 정보 설정
        self:response_ingameDropInfo(ret)

        -- 핫타임 정보 저장
        g_hotTimeData:setIngameHotTimeList(game_key, ret['hottime'])

        -- 스피드핵 방지 실제 플레이 시간 기록
        g_accessTimeData:startCheckTimer()

        -- 온전한 연속 전투 검사
        g_autoPlaySetting:setSequenceAutoPlay()
    end
    
    -- 삼뉴체크
    local friend_uid = g_friendData:getSettedFriendUID()

    ui_network:setUrl(api_url)
    ui_network:setRevocable(true)
    ui_network:setParam('uid', uid)
    ui_network:setParam('stage', stage_id)
    ui_network:setParam('deck_name', deck_name)
    ui_network:setParam('combat_power', combat_power)
    ui_network:setParam('friend', friend_uid)
    ui_network:setParam('oid', oid)
    if (attr) then 
        ui_network:setParam('attr', attr) 
    end
    if (teambonus_ids) then
        ui_network:setParam('team_bonus', teambonus_ids) 
    end

    -- 
    if (game_mode ~= GAME_MODE_LEAGUE_RAID) then
        ui_network:setParam('token', self:makeDragonToken())
    end

	if (game_mode == GAME_MODE_ANCIENT_TOWER) then
        local _attr = g_attrTowerData:getSelAttr()
        -- 고대의 탑
        if (not _attr) then
            local l_deck, formation, deck_name, leader, tamer_id = g_deckData:getDeck('ancient')
            ui_network:setParam('token', nil)
            ui_network:setParam('edoid1', l_deck[1])
            ui_network:setParam('edoid2', l_deck[2])
            ui_network:setParam('edoid3', l_deck[3])
            ui_network:setParam('edoid4', l_deck[4])
            ui_network:setParam('edoid5', l_deck[5])
            ui_network:setParam('tamer', tamer_id)
            ui_network:setParam('leader', leader)
            ui_network:setParam('formation', formation)
        end
    end
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setSuccessCB(success_cb)
	ui_network:setFailCB(fail_cb)
    ui_network:request()
end

-------------------------------------
-- function requestGameCancel
-- @brief 게임 중도 포기
--        모험, 네스트, 인연, 고대의 탑 등에서 사용
-------------------------------------
function ServerData_Stage:requestGameCancel(stage_id, gamekey, finish_cb)
    local uid = g_userData:get('uid')

    local function success_cb(ret)
        if finish_cb then
            finish_cb(ret)
        end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/game/stage/cancel')
    ui_network:setRevocable(true)
    ui_network:setParam('uid', uid)
    ui_network:setParam('stage', stage_id)
    ui_network:setParam('gamekey', gamekey)
    ui_network:setSuccessCB(success_cb)
    ui_network:request()
end

-------------------------------------
-- function response_ingameDropInfo
-- @brief 인게임 아이템 드랍 정보 설정
-- 2017-08-22 sgkim
-------------------------------------
function ServerData_Stage:old_response_ingameDropInfo(ret)
    -- 서버에서 관리하는 일일 획득 최대치
    local t_max_info = ret['ingame_drop'] or {}
    --"ingame_drop":{
    --    "cash":298,
    --    "amethyst":494,
    --    "gold":24960
    --  }

    -- 드랍될 아이템 정보
    local l_reward = ret['ingame_reward'] or {}
    --"ingame_reward":[{
    --      "cash":2
    --    },{
    --      "amethyst":1
    --    },{
    --      "amethyst":1
    --    },{
    --      "cash":1
    --    },{
    --      "gold":12
    --    }]
    local l_drop_list = {}
    for _,v in ipairs(l_reward) do
        for type,value in pairs(v) do
            table.insert(l_drop_list, {['type']=type, ['value']=value})
        end
    end

    local t_accumulate = {} -- 드랍량 누적치 저장
    local l_remove_idx = {} -- 최대치가 넘어서 드랍하지 말아야할 list의 idx
    for i,t_data in ipairs(l_drop_list) do
        local type = t_data['type']
        local value = t_data['value']

        -- 최초에 해당 타입이 없을 경우 초기화
        if (not t_accumulate[type]) then
            t_accumulate[type] = 0
        end

        -- 해당 타입의 최대치 확인
        local max_cnt = (t_max_info[type] or 0)
        if ((t_accumulate[type] + value) > max_cnt) then
            t_data['value'] = (max_cnt - t_accumulate[type])
        end

        -- 최대치 확인 후 드랍 여부와 갯수 결정
        if (t_data['value'] > 0) then
            t_accumulate[type] = (t_accumulate[type] + t_data['value'])
        else
            table.insert(l_remove_idx, 1, i)
        end
    end

    ccdump(l_remove_idx)

    -- 최대 갯수가 넘어서 드랍하지 않는 리스트 제거
    for _,remove_idx in ipairs(l_remove_idx) do
        table.remove(l_drop_list, remove_idx)
    end

    ccdump(l_drop_list)

    self.m_ingameDropItemGameKey = ret['gamekey']
    self.m_ingameDropItemList = l_drop_list
end

-------------------------------------
-- function response_ingameDropInfo
-------------------------------------
function ServerData_Stage:response_ingameDropInfo(ret)
    if (ret['ingame_reward'] == nil) then return end
    local drop_reward = {}
    local drop_result = {}
    local daily_drop_info = {}

    for _, data in pairs(ret['ingame_reward']) do
        for key, num in pairs(data) do
            table.insert(drop_reward, {['type'] = key, ['value'] = num})

            if tolua.isnull(daily_drop_info[key]) then
                local daily_item_num = g_userData:getDropInfoItemByType(key)
                local max_daily_item_num = g_userData:getDropInfoMaxItemByType(key)
                if daily_item_num and max_daily_item_num then
                    daily_drop_info[key] = {}
                    daily_drop_info[key]['daily'] = daily_item_num
                    daily_drop_info[key]['max_daily'] = max_daily_item_num
                end
            end
        end
    end

    for _, data in pairs(drop_reward) do
        local item_type = data['type']
        local item_num = data['value']

        local daily_drop = daily_drop_info[item_type]

        if tolua.isnull(daily_drop) then
            local interval = daily_drop['max_daily'] - daily_drop['daily']
            
            -- 일일획득량이 남아있고 해당 아이템 수량이 그것보다 적은 경우
            if (interval > 0) and (item_num <= interval) then

            -- 일일획득량이 남아있지만 해당 아이템 수량이 그것보다 많은 경우
            elseif (interval > 0) and (item_num > interval) then
                item_num = interval
            else -- 일일획득량이 남아 있지 않은 경우
                item_num = 0
            end
            
            if (item_num and (item_num > 0)) then
                table.insert(drop_result, {['type'] = item_type, ['value'] = item_num })
                daily_drop['daily'] = daily_drop['daily'] - item_num
            end
        end
    end

    self.m_ingameDropItemGameKey = ret['gamekey']
    self.m_ingameDropItemList = drop_result
end

-------------------------------------
-- function getIngameDropInfo
-- @brief 인게임 아이템 드랍 정보
-- 2017-08-22 sgkim
-------------------------------------
function ServerData_Stage:getIngameDropInfo(gamekey)
    if (self.m_ingameDropItemGameKey == gamekey) then
        return self.m_ingameDropItemList
    end

    return nil
end

-------------------------------------
-- function requestStageInfo
-------------------------------------
function ServerData_Stage:requestStageInfo(stage_id, finish_cb)
    local uid = g_userData:get('uid')
    
	local api_url = '/game/stage/info'

    local function success_cb(ret)
		if (finish_cb) then
			finish_cb(ret)
		end
    end

    local ui_network = UI_Network()
    ui_network:setUrl(api_url)
    ui_network:setRevocable(true)
    ui_network:setParam('uid', uid)
    ui_network:setParam('stage', stage_id)
    ui_network:setSuccessCB(success_cb)
    ui_network:request()
end

-------------------------------------
-- function getStageCategoryStr
-- @brief
-------------------------------------
function ServerData_Stage:getStageCategoryStr(stage_id)
    local game_mode = self:getGameMode(stage_id)

    local ret = nil

    -- 모험 모드
    if (game_mode == GAME_MODE_ADVENTURE) then
        ret = g_adventureData:getStageCategoryStr(stage_id)

    -- 네스트 던전 모드
    elseif (game_mode == GAME_MODE_NEST_DUNGEON) then
        ret = g_nestDungeonData:getStageCategoryStr(stage_id)

    -- 비밀 던전 모드
    elseif (game_mode == GAME_MODE_SECRET_DUNGEON) then
        ret = g_secretDungeonData:getStageCategoryStr(stage_id)

    -- 고대 유적 던전 모드
    elseif (game_mode == GAME_MODE_ANCIENT_RUIN) then
        ret = g_nestDungeonData:getStageCategoryStr(stage_id)

    end

    return ret
end

-------------------------------------
-- function isBossStage
-- @brief stage_id에 해당하는 스테이지가 보스 스테이지인지 여부
-------------------------------------
function ServerData_Stage:isBossStage(stage_id)
    local game_mode = self:getGameMode(stage_id)

    local is_boss_stage = false
    local boss_monster_id = nil

    -- 비밀 던전 모드
    if (game_mode == GAME_MODE_SECRET_DUNGEON) then
        local t_dungeon_info = g_secretDungeonData:getSelectedSecretDungeonInfo(stage_id)
        local dragon_id = t_dungeon_info['dragon']
        is_boss_stage = true -- 비밀(인연) 던전은 보스 스테이지로 간주
        boss_monster_id = (dragon_id + 20000) -- dragon_id에서 20000을 더하면 monster_id가 됨
        
    -- 다른 모드들
    else
        is_boss_stage, boss_monster_id = TableStageDesc:isBossStage(stage_id)
    end

    return is_boss_stage, boss_monster_id
end

-------------------------------------
-- function getMonsterIDList
-- @brief
-------------------------------------
function ServerData_Stage:getMonsterIDList(stage_id)
    local game_mode = self:getGameMode(stage_id)
    local table_stage_desc = TableStageDesc()
    local ret = nil

    -- 클랜던전의 경우, 현재 StructClanRaid에 attr 값이 있는 지 확인하고 없다면 그 attr을 사용
    if (TableStageData:isClanRaidStage(stage_id)) then
        local clan_raid_struct = g_clanRaidData:getClanRaidStruct()
        if (clan_raid_struct) then
            if (clan_raid_struct['attr']) then
                local ret = table_stage_desc:getMonsterIDList_ClanMonster(clan_raid_struct['attr'])
                return ret
            end
        end
    end


    -- 비밀 던전 모드
    if (game_mode == GAME_MODE_SECRET_DUNGEON) then
        -- 현재는 이전에 선택된 스테이지의 정보를 리턴함
        -- 던전 고유 아이디값이 필요
        ret = g_secretDungeonData:getMonsterIDList(stage_id)

    else
        if (not table_stage_desc:get(stage_id)) then
            return {}
        end

        ret = table_stage_desc:getMonsterIDList(stage_id)
    end

    return ret
end

-------------------------------------
-- function goToStage
-------------------------------------
function ServerData_Stage:goToStage(stage_id)
    local game_mode = self:getGameMode(stage_id)

    if (self:isOpenStage(stage_id) == false) then
        MakeSimplePopup(POPUP_TYPE.OK, Str('아직은 진입할 수 없습니다.'))
        return
    end

    -- 모험 모드
    if (game_mode == GAME_MODE_ADVENTURE) then
        UINavigator:goTo('adventure', stage_id)
        
    -- 네스트 던전 모드
    elseif (game_mode == GAME_MODE_NEST_DUNGEON) then
        UINavigator:goTo('nestdungeon', stage_id)

    -- 비밀 던전 모드
    elseif (game_mode == GAME_MODE_SECRET_DUNGEON) then
        UINavigator:goTo('secret_relation', stage_id)

    -- 고대 유적 던전 모드
    elseif (game_mode == GAME_MODE_ANCIENT_RUIN) then
        UINavigator:goTo('ancient_ruin', stage_id)

    -- 룬 수호자 던전
    elseif (game_mode == GAME_MODE_RUNE_GUARDIAN) then
        UINavigator:goTo('rune_guardian')
    end
end

-------------------------------------
-- function makeDragonToken
-------------------------------------
function ServerData_Stage:makeDragonToken(deckname)
    local token = ''

    local l_deck 
    if (deckname) then
        l_deck = g_deckData:getDeck(deckname)
    else
        l_deck = g_deckData:getDeck()
    end

    for i = 1, 5 do
        local t_dragon_data
        local doid = l_deck[i]
        if (doid) then
            t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
        end

        if (t_dragon_data) then
            token = token .. t_dragon_data:getStringData() 
        else
            token = token .. '0'
        end

        if (i < 5) then
            token = token .. ','
        end
    end

    -- 라테아 
    token = token .. g_lairData:getLairStatsStringData()

    --cclog('token = ' .. token)
    token = HEX(AES_Encrypt(HEX2BIN(CONSTANT['AES_KEY']), token))
    
    return token
end

-------------------------------------
-- function getTeamBonusIds
-------------------------------------
function ServerData_Stage:getTeamBonusIds(deckname)
    local ids = ''

    local l_deck 
    if (deckname) then
        l_deck = g_deckData:getDeck(deckname)
    else
        l_deck = g_deckData:getDeck()
    end

    local l_teambonus = TeamBonusHelper:getTeamBonusDataFromDeck(l_deck)
    for _, struct_teambonus in ipairs(l_teambonus) do
        local id = tostring(struct_teambonus:getID() or '') 
        if (ids == '') then
            ids = id
        else
            ids = ids .. ',' .. id
        end
    end
    
    return ids
end

-------------------------------------
-- function requestGameStart_training
-------------------------------------
function ServerData_Stage:requestGameStart_training(stage_id, attr, finish_cb, fail_cb)
    local uid = g_userData:get('uid')

    local function success_cb(ret)
        -- server_info, staminas 정보를 갱신
        g_serverData:networkCommonRespone(ret)
        finish_cb()
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/clans/dungeon_training_start')
    ui_network:setRevocable(true)
    ui_network:setParam('uid', uid)
    ui_network:setParam('stage', stage_id)
    ui_network:setParam('attr', attr)
    
    ui_network:setSuccessCB(success_cb)
	ui_network:setFailCB(fail_cb)
    ui_network:request()
end

-------------------------------------
-- function request_clearTicket
-------------------------------------
function ServerData_Stage:request_clearTicket(stage_id, clear_count, finish_cb, fail_cb)
    local uid = g_userData:get('uid')

    
    local function success_cb(ret)
        local ref_table = {}
        ref_table['user_levelup_data'] = {}
        ref_table['drop_reward_list'] = {}

        -- server_info, staminas 정보를 갱신
        g_serverData:networkCommonRespone(ret)
        g_serverData:networkCommonRespone_addedItems(ret)

        g_userData:response_userInfo(ret, ref_table)
        self:response_dropItems(ret, ref_table)

        -- 일일 드랍 아이템 획득량 갱신
        g_userData:response_ingameDropInfo(ret)
        
        finish_cb(ref_table)
    end

    local network = UI_Network()
    network:setUrl('/game/stage/use_clear_ticket')

    network:setParam('uid', uid)
    network:setParam('stage', stage_id)
    network:setParam('clear_cnt', clear_count)

    network:setSuccessCB(success_cb)
    network:setFailCB(fail_cb)
    network:request()
end

-------------------------------------
-- function request_etcClearTicket
-------------------------------------
function ServerData_Stage:request_etcClearTicket(api_name, stage_id, clear_count, finish_cb, fail_cb)
    local uid = g_userData:get('uid')
    
    local function success_cb(ret)
        local ref_table = {}
        ref_table['user_levelup_data'] = {}
        ref_table['drop_reward_list'] = {}

        -- server_info, staminas 정보를 갱신
        g_serverData:networkCommonRespone(ret)
        g_serverData:networkCommonRespone_addedItems(ret)

        g_userData:response_userInfo(ret, ref_table)
        self:response_dropItems(ret, ref_table)

        -- 일일 드랍 아이템 획득량 갱신
        g_userData:response_ingameDropInfo(ret)
        
        finish_cb(ref_table)
    end

    local network = UI_Network()
    network:setUrl(api_name)

    network:setParam('uid', uid)
    network:setParam('stage', stage_id)
    network:setParam('clear_cnt', clear_count)

    network:setSuccessCB(success_cb)
    network:setFailCB(fail_cb)
    network:request()
end
-------------------------------------
-- function response_userInfo
-------------------------------------
function ServerData_Stage:response_dropItems(ret, t_result_ref)
    if (not ret['added_items']) then
        return
    end

    local items_list = ret['added_items']['items_list']
    if (not items_list) then
        return
    end

    local drop_reward_list = t_result_ref['drop_reward_list']

    -- 드랍 아이템에 의한 보너스
    local l_bonus_item = {}

    for i,v in ipairs(items_list) do
        local item_id = v['item_id']
        local count = v['count']
        local from = v['from']
        local data = nil

        
        if v['oids'] then
            -- Object는 하나만 리턴한다고 가정 (dragon or rune)
            local oid = v['oids'][1]
            if oid then
                -- 드래곤에서 정보 검색
                for _,obj_data in ipairs(ret['added_items']['dragons']) do
                    if (obj_data['id'] == oid) then
                        data = StructDragonObject(obj_data)
                        break
                    end
                end

                -- 룬에서 정보 검색
                if (not data) then
                    for _,obj_data in ipairs(ret['added_items']['runes']) do
                        if (obj_data['id'] == oid) then
                            data = StructRuneObject(obj_data)
                            break
                        end
                    end
                end
            end
        end

        -- 기본으로 주는 골드도 표기하기로 결정함
        if (from == 'drop') then
            -- 하이브로 캡슐은 한국서버에서만 드랍 처리
            if (item_id == TableItem:getItemIDFromItemType('capsule')) then
                if g_localData:isShowHighbrowShop() then
                    local t_data = {item_id, count, from, data}
                    table.insert(drop_reward_list, t_data)
                end            
            else
                local t_data = {item_id, count, from, data}
                table.insert(drop_reward_list, t_data)
            end

        -- 스테이지에서 기본으로 주는 골드 량
        elseif (from == 'default') then
            local t_data = {item_id, count, from, data}
            table.insert(drop_reward_list, t_data)

        -- 드랍 아이템에 의한 보너스
        elseif (from == 'bonus') then
            if (not l_bonus_item[item_id]) then
                l_bonus_item[item_id] = 0
            end
            l_bonus_item[item_id] = l_bonus_item[item_id] + count

        -- 이벤트 아이템 (ex:송편)
        elseif (from == 'event') or (from == 'event_bingo') then
            local t_data = {item_id, count, from, data}
            table.insert(drop_reward_list, t_data)
        end
    end

    -- 보너스 아이템 추가
    for i,v in pairs(l_bonus_item) do
        local t_data = {i, v, 'bonus'}
        table.insert(drop_reward_list, t_data)
    end

end