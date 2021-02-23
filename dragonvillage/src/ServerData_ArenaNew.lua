-------------------------------------
-- class ServerData_ArenaNew
-------------------------------------
ServerData_ArenaNew = class({
        m_serverData = 'ServerData',

        m_playerUserInfo = 'StructUserInfoArenaNew',
        m_playerUserInfoHighRecord = 'StructUserInfoArenaNew',

        m_matchUserInfo = 'StructUserInfoArenaNew',
        m_matchUserList = 'table',

        m_startTime = 'timestamp', -- 콜로세움 오픈 시간
        m_endTime = 'timestamp', -- 콜로세움 종료 시간
        m_rewardInfo = 'table',

        m_gameKey = 'number',
        m_nGlobalOffset = 'number', -- 랭킹
        m_lGlobalRank = 'list',

        -- 전투 히스토리 데이터
        m_matchAtkHistory = 'list',
        m_matchDefHistory = 'list',
        
        m_tSeasonRewardInfo = 'table',
        m_tClanRewardInfo = 'table',

        m_bOpen = 'boolean',

        m_bLastPvpReward = 'boolean',

        m_firstArchivedInfo = 'table',

        m_tempLogData = 'table',
        m_costInfo = 'table',

        m_nextScore = 'number',
        m_tierRewardInfo = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_ArenaNew:init(server_data)
    self.m_serverData = server_data
    self.m_bOpen = true
	self.m_startTime = 0
	self.m_endTime = 0
    self.m_matchAtkHistory = {}
    self.m_matchDefHistory = {}
    self.m_tempLogData = {}

    -- 기존 콜로세움 보상 정보 FLAG (후에 삭제)
    self.m_bLastPvpReward = false
end

-------------------------------------
-- function request_arenaInfo
-------------------------------------
function ServerData_ArenaNew:request_arenaInfo(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        self:response_arenaInfo(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/game/arena_new/info')
    ui_network:setParam('uid', uid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function response_arenaInfo
-------------------------------------
function ServerData_ArenaNew:response_arenaInfo(ret)    
    -- 주간 보상이 넘어왔을 경우
    g_serverData:networkCommonRespone_addedItems(ret)

	self.m_bOpen = ret['open']
    self.m_startTime = ret['start_time']
    self.m_endTime = ret['end_time'] or ret['endtime']
    self.m_tierRewardInfo = ret['tier_reward_info']
    self.m_firstArchivedInfo = ret['first_archived_info']
    self.m_costInfo = ret['refresh_cost_info']

    self:refresh_playerUserInfo(ret['season'], ret['deck'], nil, ret['my_info'])
    self:refresh_playerUserInfo_highRecord(ret['hiseason'])

    local combat_power = self.m_playerUserInfo:getDeckCombatPowerByDeckname('arena_new_a', false)
    self.m_playerUserInfo.m_power = combat_power

    self.m_matchUserList = {}
    for i = 1, #ret['list'] do
        local userInfo = self:makeMatchUserInfo(ret['list'][i])
        table.insert(self.m_matchUserList, userInfo)
    end

    table.sort(self.m_matchUserList, function(a, b) return tonumber(a:getDeckCombatPower(true)) < tonumber(b:getDeckCombatPower(true)) end)

    -- 주간 보상
    self:setRewardInfo(ret)
end

-------------------------------------
-- function getCost
-- @breif 행위에 대한 대가 지불
-- 서버데이터의 키워드를 참조하여 가져올것
-------------------------------------
function ServerData_ArenaNew:getCostInfo(key)
    if (not self.m_costInfo or not self.m_costInfo[tostring(key)]) then return 0 end

    local cost = 0

    cost = self.m_costInfo[tostring(key)]

    return cost
end

-------------------------------------
-- function isAchieveRewarded
-- @breif 최초달성보상을 받았나?
-------------------------------------
function ServerData_ArenaNew:isAchieveRewarded(tier_id)
    if (not self.m_firstArchivedInfo or type(self.m_firstArchivedInfo) ~= 'table') then return false end

    if (self.m_firstArchivedInfo[tostring(tier_id)]) then
        if (self.m_firstArchivedInfo[tostring(tier_id)] == 1) then return true end
    end

    return false
end

-------------------------------------
-- function isOpen
-- @breif 콜로세움 오픈 여부 (시간 체크와 별도로 진입시 검사)
-------------------------------------
function ServerData_ArenaNew:isOpen()
    return self.m_bOpen
end

-------------------------------------
-- function isOpenArena
-- @breif 콜로세움 오픈 여부
-------------------------------------
function ServerData_ArenaNew:isOpenArena()
    local curr_time = Timer:getServerTime()
    local start_time = (self.m_startTime / 1000)
    local end_time = (self.m_endTime / 1000)
	
	return (start_time <= curr_time) and (curr_time <= end_time)
end

-------------------------------------
-- function setInfoForLobby
-------------------------------------
function ServerData_ArenaNew:setInfoForLobby(t_info)
	self:refresh_playerUserInfo(t_info['season'], nil, t_info['my_info'])
	self.m_bOpen = t_info['open']
	self.m_startTime = t_info['start_time']
	self.m_endTime = t_info['end_time']
end

-------------------------------------
-- function refresh_playerUserInfo
-- @brief 플레이어 정보 갱신
-------------------------------------
function ServerData_ArenaNew:refresh_playerUserInfo(t_data, l_deck, str_deckName, my_info)
    local deckname = str_deckName ~= nil and str_deckName or 'arena_new_a'

    if (not self.m_playerUserInfo) then
        -- 플레이어 유저 정보 생성
        local struct_user_info = StructUserInfoArenaNew()
        struct_user_info.m_uid = g_userData:get('uid')
		struct_user_info:setStructClan(g_clanData:getClanStruct())
        self.m_playerUserInfo = struct_user_info
    end

    if t_data then
        self:_refresh_playerUserInfo(self.m_playerUserInfo, t_data, my_info)
    end

    -- 덱 설정
    if l_deck then
        l_deck['deckName'] = deckname

        if (str_deckName == 'arena_new_a') then
            self.m_playerUserInfo:applyPvpDeckData(l_deck)
        elseif (str_deckName == 'arena_new_d') then
            self.m_playerUserInfo:applyPvpDefenseDeckData(l_deck)
        end
    end

    -- 클랜 정보는 항상 갱신
    self.m_playerUserInfo:setStructClan(g_clanData:getClanStruct())
end

-------------------------------------
-- function refresh_playerUserInfo_highRecord
-- @brief 최고 기록 당시 데이터
-------------------------------------
function ServerData_ArenaNew:refresh_playerUserInfo_highRecord(t_data)
    if (not t_data) then return end

    if (not self.m_playerUserInfoHighRecord) then
        -- 플레이어 유저 정보 생성
        local struct_user_info = StructUserInfoArenaNew()
        struct_user_info.m_uid = g_userData:get('uid')
        self.m_playerUserInfoHighRecord = struct_user_info
    end

    self:_refresh_playerUserInfo(self.m_playerUserInfoHighRecord, t_data)
end

-------------------------------------
-- function _refresh_playerUserInfo
-------------------------------------
function ServerData_ArenaNew:_refresh_playerUserInfo(struct_user_info, t_data, my_info)
    -- 최신 정보로 갱신
    struct_user_info.m_nickname = g_userData:get('nick')
    struct_user_info.m_lv = g_userData:get('lv')

    if (my_info) then
        struct_user_info.m_tier = my_info['tier']
        struct_user_info.m_rp = my_info['rp']
        struct_user_info.m_rank = my_info['rank']
    end

    do -- 콜로세움 정보 갱신
        if t_data['win'] then
            struct_user_info.m_winCnt = t_data['win']
        end

        if t_data['lose'] then
            struct_user_info.m_loseCnt = t_data['lose']
        end

        if t_data['rank'] then
            struct_user_info.m_seasonRank = t_data['rank']
        end

        if t_data['rate'] then
            struct_user_info.m_rankPercent = t_data['rate']
        end

        if t_data['rp'] then
            struct_user_info.m_seasonRp = t_data['rp']
        end

        if t_data['tier'] then
            struct_user_info.m_tier = t_data['tier']
        end

        if t_data['straight'] then
            struct_user_info.m_straight = t_data['straight']
        end
    end
end

-------------------------------------
-- function getPlayerArenaUserInfo
-------------------------------------
function ServerData_ArenaNew:getPlayerArenaUserInfo()
    return self.m_playerUserInfo
end

-------------------------------------
-- function getPlayerArenaUserInfoHighRecord
-------------------------------------
function ServerData_ArenaNew:getPlayerArenaUserInfoHighRecord()
    return self.m_playerUserInfoHighRecord
end

-------------------------------------
-- function getArenaStatusText
-------------------------------------
function ServerData_ArenaNew:getArenaStatusText()
    local curr_time = Timer:getServerTime()

    local start_time = (self.m_startTime / 1000)
    local end_time = (self.m_endTime / 1000)

    local str = ''
    if (not self:isOpenArena()) then
        local time = (start_time - curr_time)
        if (time < 0) then
            str = Str('오픈시간이 아닙니다.')
        else
            str = Str('{1} 남았습니다.', datetime.makeTimeDesc(time, true))
        end

    elseif (curr_time < start_time) then
        --str = Str('시즌이 종료되었습니다.')
        local time = (start_time - curr_time)
        str = Str('{1} 후 열림', datetime.makeTimeDesc(time, true))

    elseif (start_time <= curr_time) and (curr_time <= end_time) then
        local time = (end_time - curr_time)
        str = Str('{1} 남음', datetime.makeTimeDesc(time, true))

    else
        str = Str('시즌이 종료되었습니다.')
    end

    return str
end

-------------------------------------
-- function getRefreshStatusText
-------------------------------------
function ServerData_ArenaNew:getRefreshStatusText()
    local curr_time = Timer:getServerTime()

    local refresh_free_time = (self.m_refreshFreeTime / 1000)
    local str = ''

    if (refresh_free_time <= curr_time) then
        str = Str('무료 가능')

    else
        local time = (refresh_free_time - curr_time)
        str = Str('{1} 후 무료', datetime.makeTimeDesc(time, true))
    end

    return str
end

-------------------------------------
-- function makeMatchUserInfo
-------------------------------------
function ServerData_ArenaNew:makeMatchUserInfo(data)
    local struct_user_info = StructUserInfoArenaNew()
    local userLevel = 1

    if (data['infos'] and data['infos']['uinfo']) then
        l_str = plSplit(data['infos']['uinfo'], '|')

        if (l_str and #l_str > 0 and l_str[1]) then
            userLevel = l_str[1]
        end
    end

    -- 기본 유저 정보
    struct_user_info.m_no = data['no']
    struct_user_info.m_uid = data['uid']
    struct_user_info.m_nickname = data['nick']
    struct_user_info.m_lv = data['lv'] and data['lv'] or userLevel
    struct_user_info.m_tamerID = data['tamer']
    struct_user_info.m_leaderDragonObject = StructDragonObject(data['leader'])
    struct_user_info.m_tier = data['tier']
    struct_user_info.m_rank = data['rank']
    struct_user_info.m_rankPercent = data['rate']
    struct_user_info.m_state = data['state']
    struct_user_info.m_power = data['power']
    
    -- 콜로세움 유저 정보
    struct_user_info.m_rp = data['rp']

    struct_user_info.m_matchResult = data['match']

    struct_user_info:applyRunesDataList(data['runes']) --반드시 드래곤 설정 전에 룬을 설정해야함
    struct_user_info:applyDragonsDataList(data['dragons'])

    -- 덱 정보 (매치리스트에 넘어오는 덱은 해당 유저의 방어덱)
    struct_user_info:applyPvpDeckData(data['info']['deck'])

    -- 클랜
    if (data['clan_info']) then
        local struct_clan = StructClan({})
        struct_clan:applySimple(data['clan_info'])
        struct_user_info:setStructClan(struct_clan)
    end

    local uid = data['uid']
    --self.m_matchUserInfo = struct_user_info

    return struct_user_info
end

-------------------------------------
-- function getMatchUserInfo
-------------------------------------
function ServerData_ArenaNew:getMatchUserInfo()
    if (not self.m_matchUserInfo) then
        return nil
    end

    return self.m_matchUserInfo
end


-------------------------------------
-- function request_rivalRefresh
-- @brief 게임 중도 포기
-------------------------------------
function ServerData_ArenaNew:request_rivalRefresh(finish_cb)
    local uid = g_userData:get('uid')

    local function success_cb(ret)
        --if (ret['tier_reward_info']) then
        --    self.m_tierRewardInfo = ret['tier_reward_info']
        --end

        self.m_costInfo = ret['refresh_cost_info']
        self.m_matchUserList = {}
        for i = 1, #ret['list'] do
            local userInfo = self:makeMatchUserInfo(ret['list'][i])
            table.insert(self.m_matchUserList, userInfo)
        end

        table.sort(self.m_matchUserList, function(a, b) return tonumber(a.m_power) < tonumber(b.m_power) end)


        g_serverData:networkCommonRespone(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/game/arena_new/refresh')
    ui_network:setRevocable(true)
    ui_network:setParam('uid', uid)
    ui_network:setParam('stage', 13) -- 콜로세움은 서버에서 stage를 11로 처리 중
    ui_network:setParam('gamekey', gamekey)
    ui_network:setSuccessCB(success_cb)
    ui_network:request()
end

-------------------------------------
-- function request_setDeck
-------------------------------------
function ServerData_ArenaNew:request_setDeck(deckname, formation, leader, l_edoid, tamer, finish_cb, fail_cb ,combat_power)
    local _deckname = deckname

    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        local t_data = nil
        local l_deck = ret['deck']
        self:refresh_playerUserInfo(t_data, l_deck, deckname)

        if (deckname == 'arena_new_a' or deckname == 'arena_new_d') then
            self.m_playerUserInfo:applyPvpDeckData(l_deck)
        elseif (deckname == 'arena_new_d') then
            self.m_playerUserInfo:applyPvpDefenseDeckData(l_deck)
        elseif(deckname == 'arena_new') then
            self.m_playerUserInfo:applyPvpDeckData(l_deck)
            self.m_playerUserInfo:applyPvpDefenseDeckData(l_deck)
        end
        
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 공격자의 콜로세움 전투력 저장
    local combatPower = combat_power and combat_power or g_arenaNewData.m_playerUserInfo:getDeckCombatPower(true)

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/game/pvp/set_deck')
    ui_network:setParam('uid', uid)

    ui_network:setParam('deckname', _deckname)
    ui_network:setParam('formation', formation)
    ui_network:setParam('leader', leader)
    ui_network:setParam('tamer', tamer)

    ui_network:setParam('combat_power', combatPower)

    for i,doid in pairs(l_edoid) do
        ui_network:setParam('edoid' .. i, doid)
    end

    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_arenaStart
-------------------------------------
function ServerData_ArenaNew:request_arenaStart(is_cash, history_id, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 공격자의 콜로세움 전투력 저장
    local combat_power = g_arenaNewData.m_playerUserInfo:getDeckCombatPower(true)
    
    -- 성공 콜백
    local function success_cb(ret)
        -- @analytics
        Analytics:trackEvent(CUS_CATEGORY.PLAY, CUS_EVENT.TRY_COL, 1, '콜로세움')

        -- staminas, cash 동기화
        g_serverData:networkCommonRespone(ret)

        self.m_gameKey = ret['gamekey']
        --vs_dragons
        --vs_runes
        --vs_deck
        --vs_info

        -- 실제 플레이 시간 로그를 위해 체크 타임 보냄
        g_accessTimeData:startCheckTimer()

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- true를 리턴하면 자체적으로 처리를 완료했다는 뜻
    local function response_status_cb(ret)
        if (ret['status'] == -1108) then
            -- 비슷한 티어 매칭 상대가 없는 상태
            -- 콜로세움 UI로 이동
            local function ok_cb()
                UINavigator:goTo('arena_new')
            end 
            MakeSimplePopup(POPUP_TYPE.OK, Str('현재 점수 구간 내의 대전 가능한 상대가 없습니다.\n다른 상대의 콜로세움 참여를 기다린 후에 다시 시도해 주세요.'), ok_cb)
            return true
        end

        return false
    end

    -- Log를 위해 arena_new/finish에 던질 데이터들 임시 저장
    self.m_tempLogData['is_cash'] = is_cash

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/game/arena_new/start')
    ui_network:setParam('uid', uid)
    ui_network:setParam('is_cash', is_cash)
    ui_network:setParam('combat_power', combat_power)
    ui_network:setParam('token', self:makeDragonToken())
    ui_network:setParam('team_bonus', self:getTeamBonusIds())
    ui_network:setParam('target_no', g_arenaNewData.m_matchUserInfo.m_no)

    if (history_id) then -- 복수전, 재도전
        ui_network:setParam('history_id', history_id)
    end
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_arenaCancel
-- @brief 게임 중도 포기
-------------------------------------
function ServerData_ArenaNew:request_arenaCancel(gamekey, finish_cb)
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
    ui_network:setParam('stage', 13) -- 콜로세움은 서버에서 stage를 11로 처리 중
    ui_network:setParam('gamekey', gamekey)
    ui_network:setSuccessCB(success_cb)
    ui_network:request()
end

-------------------------------------
-- function request_arenaFinish
-------------------------------------
function ServerData_ArenaNew:request_arenaFinish(is_win, play_time, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 공격자의 콜로세움 전투력 저장
    local combat_power = g_arenaNewData.m_playerUserInfo:getDeckCombatPower(true)

    -- 성공 콜백
    local function success_cb(ret)
        -- 이전 데이터
        local prev_rp = self.m_playerUserInfo.m_rp
        local prev_honor = g_userData:get('honor')

        -- staminas, cash 동기화
        g_serverData:networkCommonRespone(ret)
        g_serverData:networkCommonRespone_addedItems(ret)

        -- 플레이어 정보 갱신
        local season_data = ret['season']
        self:refresh_playerUserInfo(season_data)

        if (season_data['win'] == 1) then
            -- @analytics
            Analytics:firstTimeExperience('Arena_Win')
        end

        -- 변경 데이터
        ret['added_rp'] = (self.m_playerUserInfo.m_seasonRp - prev_rp)
        --ret['added_rp'] = ret['point'] -- 실시간으로 변경된 값이 있을 수 있으므로 서버에서 넘어오는 값을 표기
        ret['added_honor'] = (g_userData:get('honor') - prev_honor)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- true를 리턴하면 자체적으로 처리를 완료했다는 뜻
    local function response_status_cb(ret)
        -- invalid season
        if (ret['status'] == -1364) then
            -- 전투 UI로 이동
            local function ok_cb()
                UINavigator:goTo('battle_menu', 'competition')
            end 
            MakeSimplePopup(POPUP_TYPE.OK, Str('시즌이 종료되었습니다.'), ok_cb)
            return true
        end

        return false
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/game/arena_new/finish')
    ui_network:setParam('uid', uid)
    ui_network:setParam('is_win', is_win and 1 or 0)
    ui_network:setParam('clear_time', play_time)
    ui_network:setParam('check_time', g_accessTimeData:getCheckTime())
    ui_network:setParam('gamekey', self.m_gameKey)
    ui_network:setParam('combat_power', combat_power)

    -- 서버 Log를 위해 클라에서 넘기는 값들
    do 
        -- 다이아 사용 
        local is_cash = self.m_tempLogData['is_cash'] or false
        ui_network:setParam('is_cash', is_cash)

        -- 전투 타입 (일반 매칭, 복수전, 재도전)
        local match_type = self.m_tempLogData['match_type'] or 'random'
        ui_network:setParam('match_type', fight_type)

        -- 수동/자동
        local is_auto = self.m_tempLogData['is_auto'] or false
        ui_network:setParam('is_auto', is_auto)

        -- 연속 전투
        if (not is_auto) then
            ui_network:setParam('is_continuous', false)
        else
            local is_continuous = g_autoPlaySetting:isAutoPlay() 
            ui_network:setParam('is_continuous', is_continuous)
        end
        
        -- 전투중 종료
        local force_exit = self.m_tempLogData['force_exit'] or false
        ui_network:setParam('force_exit', force_exit)
        
        -- 접속시간 저장
        local save_time = g_accessTimeData:getSaveTime()
        if (save_time) then
            ui_network:setParam('access_time', save_time)
        end

        -- 통신 후에는 삭제
        self.m_tempLogData = {}
    end

    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    
    -- 연속 전투의 경우 네트워크 에러 시 잠시 대기후 재요청보냄
    if (g_autoPlaySetting:isAutoPlay()) then
        ui_network:setRetryCount_forGameFinish()
    end

    ui_network:setRevocable(false) -- 게임 종료 통신은 취소를 하지 못함
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_arenaRank
-------------------------------------
function ServerData_ArenaNew:request_arenaRank(offset, type, finish_cb, fail_cb, _rank_cnt)
    -- 파라미터
    local uid = g_userData:get('uid')
    local offset = offset or 0
	local rank_cnt = _rank_cnt or 30

    -- 콜백 함수
    local function success_cb(ret)
        self.m_nGlobalOffset = ret['offset']

        -- 유저 리스트 저장
        self.m_lGlobalRank = {}
        for i,v in pairs(ret['list']) do
            local user_info = StructUserInfoArenaNew:create_forRanking(v)
            table.insert(self.m_lGlobalRank, user_info)
        end
        
        if finish_cb then
            return finish_cb(ret)
        end
    end
    local _type = type or 'world'

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/game/arena_new/ranking')
    ui_network:setParam('uid', uid)
    ui_network:setParam('offset', offset)
    ui_network:setParam('type', _type)
    ui_network:setParam('limit', rank_cnt)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

	return ui_network
end

-------------------------------------
-- function request_arenaHistory
-------------------------------------
function ServerData_ArenaNew:request_arenaHistory(finish_cb, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function callback_cb(ret)
        self.m_matchDefHistory = {}
        for i,v in pairs(ret['history']) do
            local user_info = StructUserInfoArenaNew:create_forHistory(v)
            table.insert(self.m_matchDefHistory, user_info)
        end
        
        if finish_cb then
            return finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/game/arena_new/history')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(callback_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

	return ui_network
end

-------------------------------------
-- function setRewardInfo
-------------------------------------
function ServerData_ArenaNew:setRewardInfo(ret)
    -- 아레나 첫주차에만 오는 기존 콜로세움 보상 정보
    if (ret['pvp_reward']) then
        self.m_bLastPvpReward = true

        -- 기존 콜로세움 - 개인 (첫주차만 받는다)
        if (ret['pvp_lastinfo']) then
            -- 플레이어 유저 정보 생성
            local struct_user_info = StructUserInfoArenaNew()
            struct_user_info.m_uid = g_userData:get('uid')

            self:_refresh_playerUserInfo(struct_user_info, ret['pvp_lastinfo'])

            self.m_tSeasonRewardInfo = {}
            self.m_tSeasonRewardInfo['rank'] = struct_user_info
            self.m_tSeasonRewardInfo['reward_info'] =ret['pvp_reward_info']

            -- @analytics
            Analytics:trackGetGoodsWithRet(ret, '콜로세움(주간보상)')
        end

        -- 기존 콜로세움 - 클랜 (첫주차만 받는다)
        if (ret['pvp_last_clan_info']) then
            self.m_tClanRewardInfo = {}
            self.m_tClanRewardInfo['rank'] = StructClanRank(ret['pvp_last_clan_info'])
            self.m_tClanRewardInfo['reward_info'] = ret['pvp_reward_clan_info']
        end

        return
    end


    -- 아레나 시즌 보상 정보
    if (not ret['reward']) then
        return
    end
    -- 개인
    if (ret['lastinfo']) then
        -- 플레이어 유저 정보 생성
        local struct_user_info = StructUserInfoArenaNew()
        struct_user_info.m_uid = g_userData:get('uid')
        self:_refresh_playerUserInfo(struct_user_info, ret['lastinfo'])

        -- 클랜
        if (ret['my_info'] and ret['my_info']['clan_info']) then
            local struct_clan = StructClan({})
            struct_clan:applySimple(ret['my_info']['clan_info'])
            struct_user_info:setStructClan(struct_clan)
        end

        self.m_tSeasonRewardInfo = {}
        self.m_tSeasonRewardInfo['rank'] = struct_user_info
        self.m_tSeasonRewardInfo['reward_info'] =ret['reward_info']

        -- @analytics
        Analytics:trackGetGoodsWithRet(ret, '콜로세움(주간보상)')
    end

    -- 클랜
    if (ret['last_clan_info']) then
        self.m_tClanRewardInfo = {}
        self.m_tClanRewardInfo['rank'] = StructClanRank(ret['last_clan_info'])
        self.m_tClanRewardInfo['reward_info'] = ret['reward_clan_info']
    end
end

-------------------------------------
-- function response_playerArenaDeck
-- @comment 이아이는 짝꿍 request method가 없다
-------------------------------------
function ServerData_ArenaNew:response_playerArenaDeck(l_deck)
    local deckType = l_deck['deckName']

    self:refresh_playerUserInfo(nil, l_deck, l_deck['deckName'])
end

-------------------------------------
-- function isStartClanWarContents
-- @brief 2019년 12월 2일 이후에는 true를 리턴
-------------------------------------
function ServerData_ArenaNew:isStartClanWarContents()
    local date = pl.Date()
    date:year(2019)
    date:month(12)
    date:day(1)
    date:hour(23)
    date:min(59)

    local remove_time = date['time'] or 0
    local cur_time =  Timer:getServerTime()
    return cur_time > remove_time
end

-------------------------------------
-- function makeDragonToken
-------------------------------------
function ServerData_ArenaNew:makeDragonToken()
    local token = ''

    local l_deck = self.m_playerUserInfo:getDeck_dragonList(true)

    for i = 1, 5 do
        local t_dragon_data
        local doid = l_deck[i]
        if (doid) then
            t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)

            -- 드래곤 성장일지 : 콜로세움 출전
            local start_dragon_doid = g_userData:get('start_dragon')
            if (start_dragon_doid) and (doid == start_dragon_doid) then
                -- @ DRAGON DIARY
                local t_data = {clear_key = 'ply_clsm', sub_data = t_dragon_data}
                g_dragonDiaryData:updateDragonDiary(t_data)
            end
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

-------------------------------------
-- function getTeamBonusIds
-------------------------------------
function ServerData_ArenaNew:getTeamBonusIds()
    local ids = ''

    local l_deck = self.m_playerUserInfo:getDeck_dragonList(true)
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
-- function setMatchUser
-------------------------------------
function ServerData_ArenaNew:setMatchUser(match_user)    
    if (not match_user) then return end

    self.m_matchUserInfo = match_user
end

-------------------------------------
-- function setMatchUser
-------------------------------------
function ServerData_ArenaNew:hasArchiveReward(tier_id)    
    if (not self.m_firstArchivedInfo or type(self.m_firstArchivedInfo) ~= 'table') then return false end

    if (self.m_firstArchivedInfo[tostring(tier_id)]) then
        return self.m_firstArchivedInfo[tostring(tier_id)] ~= 1
    end

    return true
end