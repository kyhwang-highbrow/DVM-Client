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
    local game_mode = getDigit(stage_id, 100000, 2)
    return game_mode
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
        local chapter_name = chapterName(chapter)
        name = chapter_name .. Str(' {1}-{2}', chapter, stage)

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
        name = Str('클랜던전')

    -- 콜로세움 모드
    elseif (game_mode == GAME_MODE_COLOSSEUM) then
        name = Str('콜로세움')

    -- 인트로 전투
    elseif (game_mode == GAME_MODE_INTRO) then
        name = Str('시나리오 전투')
    end

    return name
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

    -- 클랜 던전 모드
    elseif (game_mode == GAME_MODE_CLAN_RAID) then
        ret = g_clanRaidData:isOpenClanRaid()

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
function ServerData_Stage:requestGameStart(stage_id, deck_name, combat_power, finish_cb)
    local uid = g_userData:get('uid')
    local oid
    local response_status_cb

    -- 모드별 API 주소 분기처리
    local api_url = ''
    local game_mode = g_stageData:getGameMode(stage_id)
    local attr
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
            api_url = '/game/attr_tower/start'

        -- 고대의 탑
        else
            api_url = '/game/ancient/start'
        end

    -- 클랜 던전
    elseif (game_mode == GAME_MODE_CLAN_RAID) then
        api_url = '/clans/dungeon_start'

        -- true를 리턴하면 자체적으로 처리를 완료했다는 뜻
        response_status_cb = function(ret)
           
            -- 클랜던전 UI로 이동
            local function ok_cb()
                UINavigator:goTo('clan_raid')
            end 

            if (ret['status'] == -3871) then
                MakeSimplePopup(POPUP_TYPE.OK, Str('이미 클랜던전에 입장한 유저가 있습니다.'), ok_cb)
                return true

            elseif (ret['status'] == -1671) then
                MakeSimplePopup(POPUP_TYPE.OK, Str('제한시간을 초과하였습니다.'), ok_cb)
                return true

            elseif (ret['status'] == -1371) then
                MakeSimplePopup(POPUP_TYPE.OK, Str('유효하지 않은 던전입니다.'), ok_cb)
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
    end

    local friend_uid = nil
    if g_friendData.m_selectedShareFriendData then
        friend_uid = g_friendData.m_selectedShareFriendData.m_uid
    end

    local ui_network = UI_Network()
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
    ui_network:setParam('token', self:makeDragonToken())
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setSuccessCB(success_cb)
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
function ServerData_Stage:response_ingameDropInfo(ret)
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

    -- 최대 갯수가 넘어서 드랍하지 않는 리스트 제거
    for _,remove_idx in ipairs(l_remove_idx) do
        table.remove(l_drop_list, remove_idx)
    end

    self.m_ingameDropItemGameKey = ret['gamekey']
    self.m_ingameDropItemList = l_drop_list
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

    local ret = nil

    -- 비밀 던전 모드
    if (game_mode == GAME_MODE_SECRET_DUNGEON) then
        -- 현재는 이전에 선택된 스테이지의 정보를 리턴함
        -- 던전 고유 아이디값이 필요
        ret = g_secretDungeonData:getMonsterIDList(stage_id)

    else
        local table_stage_desc = TableStageDesc()
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

    end
end

-------------------------------------
-- function makeDragonToken
-------------------------------------
function ServerData_Stage:makeDragonToken()
    local token = ''

    local l_deck = g_deckData:getDeck()

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

    --cclog('token = ' .. token)

    token = HEX(AES_Encrypt(HEX2BIN(CONSTANT['AES_KEY']), token))
    
    return token
end