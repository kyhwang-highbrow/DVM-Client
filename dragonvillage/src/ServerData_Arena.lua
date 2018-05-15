-------------------------------------
-- class ServerData_Arena
-------------------------------------
ServerData_Arena = class({
        m_serverData = 'ServerData',

        m_playerUserInfo = 'StructUserInfoArena',
        m_playerUserInfoHighRecord = 'StructUserInfoArena',

        m_matchUserInfo = 'StructUserInfoArena',

        m_startTime = 'timestamp', -- 콜로세움 오픈 시간
        m_endTime = 'timestamp', -- 콜로세움 종료 시간

        m_gameKey = 'number',
        m_nGlobalOffset = 'number', -- 랭킹
        m_lGlobalRank = 'list',

        -- 전투 히스토리 데이터
        m_matchAtkHistory = 'list',
        m_matchDefHistory = 'list',
        
        m_tSeasonRewardInfo = 'table',
        m_tClanRewardInfo = 'table',

        m_bOpen = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Arena:init(server_data)
    self.m_serverData = server_data
    self.m_bOpen = true
	self.m_startTime = 0
	self.m_endTime = 0
    self.m_matchAtkHistory = {}
    self.m_matchDefHistory = {}
end

-------------------------------------
-- function request_arenaInfo
-------------------------------------
function ServerData_Arena:request_arenaInfo(finish_cb, fail_cb)
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
    ui_network:setUrl('/game/arena/info')
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
function ServerData_Arena:response_arenaInfo(ret)    
    -- 주간 보상이 넘어왔을 경우
    g_serverData:networkCommonRespone_addedItems(ret)

	self.m_bOpen = ret['open']
    self.m_startTime = ret['start_time']
    self.m_endTime = ret['end_time'] or ret['endtime']

    self:refresh_playerUserInfo(ret['season'], ret['deck'])
    self:refresh_playerUserInfo_highRecord(ret['hiseason'])

    -- 주간 보상
    self:setRewardInfo(ret)
end

-------------------------------------
-- function isOpen
-- @breif 콜로세움 오픈 여부 (시간 체크와 별도로 진입시 검사)
-------------------------------------
function ServerData_Arena:isOpen()
    return self.m_bOpen
end

-------------------------------------
-- function isOpenArena
-- @breif 콜로세움 오픈 여부
-------------------------------------
function ServerData_Arena:isOpenArena()
    local curr_time = Timer:getServerTime()
    local start_time = (self.m_startTime / 1000)
    local end_time = (self.m_endTime / 1000)
	
	return (start_time <= curr_time) and (curr_time <= end_time)
end

-------------------------------------
-- function setInfoForLobby
-------------------------------------
function ServerData_Arena:setInfoForLobby(t_info)
	self:refresh_playerUserInfo(t_info['season'], nil)
	self.m_bOpen = t_info['open']
	self.m_startTime = t_info['start_time']
	self.m_endTime = t_info['end_time']
end

-------------------------------------
-- function refresh_playerUserInfo
-- @brief 플레이어 정보 갱신
-------------------------------------
function ServerData_Arena:refresh_playerUserInfo(t_data, l_deck)
    if (not self.m_playerUserInfo) then
        -- 플레이어 유저 정보 생성
        local struct_user_info = StructUserInfoArena()
        struct_user_info.m_uid = g_userData:get('uid')
		struct_user_info:setStructClan(g_clanData:getClanStruct())
        self.m_playerUserInfo = struct_user_info
    end

    if t_data then
        self:_refresh_playerUserInfo(self.m_playerUserInfo, t_data)
    end

    -- 덱 설정
    if l_deck then
        l_deck['deckName'] = 'arena' -- 서버 작업이 안되서 arena로 일딴 설정
        self.m_playerUserInfo:applyPvpDeckData(l_deck)
    end
end

-------------------------------------
-- function refresh_playerUserInfo_highRecord
-- @brief 최고 기록 당시 데이터
-------------------------------------
function ServerData_Arena:refresh_playerUserInfo_highRecord(t_data)
    if (not self.m_playerUserInfoHighRecord) then
        -- 플레이어 유저 정보 생성
        local struct_user_info = StructUserInfoArena()
        struct_user_info.m_uid = g_userData:get('uid')
        self.m_playerUserInfoHighRecord = struct_user_info
    end

    self:_refresh_playerUserInfo(self.m_playerUserInfoHighRecord, t_data)
end

-------------------------------------
-- function _refresh_playerUserInfo
-------------------------------------
function ServerData_Arena:_refresh_playerUserInfo(struct_user_info, t_data)
    -- 최신 정보로 갱신
    struct_user_info.m_nickname = g_userData:get('nick')
    struct_user_info.m_lv = g_userData:get('lv')

    do -- 콜로세움 정보 갱신
        if t_data['win'] then
            struct_user_info.m_winCnt = t_data['win']
        end

        if t_data['lose'] then
            struct_user_info.m_loseCnt = t_data['lose']
        end

        if t_data['rank'] then
            struct_user_info.m_rank = t_data['rank']
        end

        if t_data['rate'] then
            struct_user_info.m_rankPercent = t_data['rate']
        end

        if t_data['rp'] then
            struct_user_info.m_rp = t_data['rp']
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
function ServerData_Arena:getPlayerArenaUserInfo()
    return self.m_playerUserInfo
end

-------------------------------------
-- function getPlayerArenaUserInfoHighRecord
-------------------------------------
function ServerData_Arena:getPlayerArenaUserInfoHighRecord()
    return self.m_playerUserInfoHighRecord
end

-------------------------------------
-- function getArenaStatusText
-------------------------------------
function ServerData_Arena:getArenaStatusText()
    local curr_time = Timer:getServerTime()

    local start_time = (self.m_startTime / 1000)
    local end_time = (self.m_endTime / 1000)

    local str = ''
    if (not self:isOpenArena()) then
        local time = (start_time - curr_time)
        str = Str('{1} 남았습니다.', datetime.makeTimeDesc(time, true))

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
function ServerData_Arena:getRefreshStatusText()
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
function ServerData_Arena:makeMatchUserInfo(data)
    local struct_user_info = StructUserInfoArena()

    -- 기본 유저 정보
    struct_user_info.m_uid = data['uid']
    struct_user_info.m_nickname = data['nick']
    struct_user_info.m_lv = data['lv']
    struct_user_info.m_tamerID = data['tamer']
    struct_user_info.m_leaderDragonObject = StructDragonObject(data['leader'])
    struct_user_info.m_tier = data['tier']

    -- 콜로세움 유저 정보
    struct_user_info.m_rp = data['rp']
    struct_user_info.m_matchResult = data['match']

    struct_user_info:applyRunesDataList(data['runes']) --반드시 드래곤 설정 전에 룬을 설정해야함
    struct_user_info:applyDragonsDataList(data['dragons'])

    -- 덱 정보 (매치리스트에 넘어오는 덱은 해당 유저의 방어덱)
    struct_user_info:applyPvpDeckData(data['deck'])

    -- 클랜
    if (data['clan_info']) then
        local struct_clan = StructClan({})
        struct_clan:applySimple(data['clan_info'])
        struct_user_info:setStructClan(struct_clan)
    end

    local uid = data['uid']
    self.m_matchUserInfo = struct_user_info
end

-------------------------------------
-- function getMatchUserInfo
-------------------------------------
function ServerData_Arena:getMatchUserInfo()
    if (not self.m_matchUserInfo) then
        return nil
    end

    return self.m_matchUserInfo
end

-------------------------------------
-- function request_setDeck
-------------------------------------
function ServerData_Arena:request_setDeck(deckname, formation, leader, l_edoid, tamer, finish_cb, fail_cb)
    local _deckname = deckname

    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        local t_data = nil
        local l_deck = ret['deck']
        self:refresh_playerUserInfo(t_data, l_deck)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/game/pvp/set_deck')
    ui_network:setParam('uid', uid)

    ui_network:setParam('deckname', _deckname)
    ui_network:setParam('formation', formation)
    ui_network:setParam('leader', leader)
    ui_network:setParam('tamer', tamer)
    

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
function ServerData_Arena:request_arenaStart(is_cash, history_id, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 공격자의 콜로세움 전투력 저장
    local combat_power = g_arenaData.m_playerUserInfo:getDeckCombatPower(true)
    
    -- 성공 콜백
    local function success_cb(ret)
        -- 상대방 정보 여기서 설정
        if (ret['match_user']) then
            self:makeMatchUserInfo(ret['match_user'])
        else
            error('콜로세움 상대방 정보 없음')
        end

        -- @analytics
        Analytics:trackEvent(CUS_CATEGORY.PLAY, CUS_EVENT.TRY_COL, 1, '콜로세움')

        -- staminas, cash 동기화
        g_serverData:networkCommonRespone(ret)

        self.m_gameKey = ret['gamekey']
        --vs_dragons
        --vs_runes
        --vs_deck
        --vs_info

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/game/arena/start')
    ui_network:setParam('uid', uid)
    ui_network:setParam('is_cash', is_cash)
    ui_network:setParam('combat_power', combat_power)
    ui_network:setParam('token', self:makeDragonToken())
    ui_network:setParam('team_bonus', self:getTeamBonusIds())
    if (history_id) then -- 복수전, 재도전
        ui_network:setParam('history_id', history_id)
    end
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_arenaCancel
-- @brief 게임 중도 포기
-------------------------------------
function ServerData_Arena:request_arenaCancel(gamekey, finish_cb)
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
function ServerData_Arena:request_arenaFinish(is_win, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

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
        --ret['added_rp'] = (self.m_playerUserInfo.m_rp - prev_rp)
        ret['added_rp'] = ret['point'] -- 실시간으로 변경된 값이 있을 수 있으므로 서버에서 넘어오는 값을 표기
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
    ui_network:setUrl('/game/arena/finish')
    ui_network:setParam('uid', uid)
    ui_network:setParam('is_win', is_win and 1 or 0)
    ui_network:setParam('gamekey', self.m_gameKey)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_arenaRank
-------------------------------------
function ServerData_Arena:request_arenaRank(offset, finish_cb, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')
    local offset = offset or 0

    -- 콜백 함수
    local function success_cb(ret)
        self.m_nGlobalOffset = ret['offset']

        -- 유저 리스트 저장
        self.m_lGlobalRank = {}
        for i,v in pairs(ret['list']) do
            local user_info = StructUserInfoArena:create_forRanking(v)
            table.insert(self.m_lGlobalRank, user_info)
        end
        
        if finish_cb then
            return finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/game/arena/ranking')
    ui_network:setParam('uid', uid)
    ui_network:setParam('offset', offset)
    ui_network:setParam('limit', 30)
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
function ServerData_Arena:request_arenaHistory(type, finish_cb, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        if (type == 'atk') then
            self.m_matchAtkHistory = {}
            for i,v in pairs(ret['history']) do
                local user_info = StructUserInfoArena:create_forHistory(v)
                table.insert(self.m_matchAtkHistory, user_info)
            end
        else
            self.m_matchDefHistory = {}
            for i,v in pairs(ret['history']) do
                local user_info = StructUserInfoArena:create_forHistory(v)
                table.insert(self.m_matchDefHistory, user_info)
            end
        end
        
        if finish_cb then
            return finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/game/arena/history')
    ui_network:setParam('uid', uid)
    ui_network:setParam('type', type) -- atk 공격 기록 , def 방어 기록
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

	return ui_network
end

-------------------------------------
-- function setRewardInfo
-------------------------------------
function ServerData_Arena:setRewardInfo(ret)
    if (not ret['reward']) then
        return
    end
    
    -- 개인
    if (ret['lastinfo']) then
        -- 플레이어 유저 정보 생성
        local struct_user_info = StructUserInfoArena()
        struct_user_info.m_uid = g_userData:get('uid')

        self:_refresh_playerUserInfo(struct_user_info, ret['lastinfo'])

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
function ServerData_Arena:response_playerArenaDeck(l_deck)
	self:refresh_playerUserInfo(nil, l_deck)
end

-------------------------------------
-- function makeDragonToken
-------------------------------------
function ServerData_Arena:makeDragonToken()
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
function ServerData_Arena:getTeamBonusIds()
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