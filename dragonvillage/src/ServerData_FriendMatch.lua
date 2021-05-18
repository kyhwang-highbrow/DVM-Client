-------------------------------------
-- class ServerData_FriendMatch
-------------------------------------
ServerData_FriendMatch = class({
        m_serverData = 'ServerData',
        m_mode = 'FRIEND_MATCH_MODE',

        m_matchUserID = 'string',
        m_playerUserInfo = 'StructUserInfoColosseum',
        m_matchInfo = 'StructUserInfoColosseum',

        m_gameKey = 'number',
    })

-- 공격덱은 모드 상관없이 동일함 : fpvp_atk
FRIEND_MATCH_MODE = {
    FRIEND = 1, -- 친구 대전 -- 상대 방어덱 : fpvp_atk, arena 순으로 체크
    CLAN = 2, -- 클랜원 대전 -- 상대 방어덱 : fpvp_atk, arena 순으로 체크
    RETRY = 3, -- 재도전 -- 상대 방어덱 : arena (history에 있는 덱)
    REVENGE = 4, -- 복수전 -- 상대 방어덱 : arena (history에 있는 덱)
}

-------------------------------------
-- function init
-------------------------------------
function ServerData_FriendMatch:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function request_colosseumInfo
-- @brief 콜로세움 (기존) 인포
-------------------------------------
function ServerData_FriendMatch:request_colosseumInfo(vsuid, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        self:response_colosseumInfo(ret)
        self.m_matchUserID = vsuid

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/game/pvp/friendly')
    ui_network:setParam('uid', uid)
    ui_network:setParam('vsuid', vsuid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_arenaInfo
-- @brief 콜로세움 (신규) 인포
-------------------------------------
function ServerData_FriendMatch:request_arenaInfo(mode, vsuid, finish_cb, fail_cb, sub_data)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        self:response_arenaInfo(ret)
        self.m_matchUserID = vsuid

        -- 성공시 친선대전 모드별 진입
        UI_FriendMatchReadyArena(mode, vsuid)
    end

    local map_api = {}
    map_api[FRIEND_MATCH_MODE.FRIEND] = '/game/arena/friendly'
    map_api[FRIEND_MATCH_MODE.CLAN] = '/game/arena/friendly_clan'
    map_api[FRIEND_MATCH_MODE.RETRY] = '/game/arena/friendly_history' 
    map_api[FRIEND_MATCH_MODE.REVENGE] = '/game/arena/friendly_history'

    local tar_api = map_api[mode]
    if (not tar_api) then 
        return
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl(tar_api)
    ui_network:setParam('uid', uid)
    if (mode == FRIEND_MATCH_MODE.RETRY or mode == FRIEND_MATCH_MODE.REVENGE) then
        ui_network:setParam('history_id', vsuid)
    else
        ui_network:setParam('vsuid', vsuid)
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
-- function request_setDeck
-------------------------------------
function ServerData_FriendMatch:request_setDeck(deckname, formation, leader, l_edoid, tamer, finish_cb, fail_cb)
    local _deckname = deckname
    if (deckname == 'fpvp_atk') then
        _deckname = 'fatk'
    end
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        local t_data = nil
        local l_deck 

        if IS_ARENA_OPEN() then
            l_deck = ret['deck']
            self.m_playerUserInfo:applyPvpDeckData(l_deck)
        else
            l_deck = {ret['deck']}
            self:refresh_playerUserInfo(l_deck)
        end

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
-- function request_colosseumStart
-------------------------------------
function ServerData_FriendMatch:request_colosseumStart(is_cash, vsuid, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 공격자의 콜로세움 전투력 저장
    local combat_power = g_friendMatchData.m_playerUserInfo:getAtkDeckCombatPower(true)
    
    -- 성공 콜백
    local function success_cb(ret)
        -- @analytics
        Analytics:trackEvent(CUS_CATEGORY.PLAY, CUS_EVENT.TRY_COL, 1, '친구대전')

        -- staminas, cash 동기화
        g_serverData:networkCommonRespone(ret)

        self.m_gameKey = ret['gamekey']

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/game/pvp/friendly/start')
    ui_network:setParam('uid', uid)
    ui_network:setParam('vsuid', vsuid)
    ui_network:setParam('combat_power', combat_power)
    ui_network:setParam('token', self:makeDragonToken())
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_arenaStart
-------------------------------------
function ServerData_FriendMatch:request_arenaStart(mode, vsuid, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 공격자의 콜로세움 전투력 저장
    local combat_power = g_friendMatchData.m_playerUserInfo:getDeckCombatPower(true)
    
    -- 성공 콜백
    local function success_cb(ret)
        self.m_mode = mode

        -- @analytics
        Analytics:trackEvent(CUS_CATEGORY.PLAY, CUS_EVENT.TRY_COL, 1, '친구대전')

        -- staminas, cash 동기화
        g_serverData:networkCommonRespone(ret)

        -- 지급된 아이템 동기화
        g_serverData:networkCommonRespone_addedItems(ret)

        self.m_gameKey = ret['gamekey']

        if finish_cb then
            finish_cb(ret)
        end
    end

    local map_api = {}
    map_api[FRIEND_MATCH_MODE.FRIEND] = '/game/arena/friendly/start'
    map_api[FRIEND_MATCH_MODE.CLAN] = '/game/arena/friendly_clan_start'
    map_api[FRIEND_MATCH_MODE.RETRY] = '/game/arena/friendly_history_start' 
    map_api[FRIEND_MATCH_MODE.REVENGE] = '/game/arena/friendly_history_start'

    local tar_api = map_api[mode]
    if (not tar_api) then 
        return
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl(tar_api)
    ui_network:setParam('uid', uid)
    if (mode == FRIEND_MATCH_MODE.RETRY or mode == FRIEND_MATCH_MODE.REVENGE) then
        ui_network:setParam('history_id', vsuid)
    else
        ui_network:setParam('vsuid', vsuid)
    end
    ui_network:setParam('combat_power', combat_power)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end
-------------------------------------
-- function response_colosseumInfo
-------------------------------------
function ServerData_FriendMatch:response_colosseumInfo(ret)
    self:refresh_playerUserInfo(ret['deck'])
    self:refresh_matchList(ret['match_info'])
end

-------------------------------------
-- function response_arenaInfo
-------------------------------------
function ServerData_FriendMatch:response_arenaInfo(ret)
    self:refresh_playerUserInfo_Arena(ret['deck'], ret['myrank_info'])
    self:refresh_matchList_Arena(ret['match_info'])
end

-------------------------------------
-- function refresh_playerUserInfo
-------------------------------------
function ServerData_FriendMatch:refresh_playerUserInfo(l_deck)
    self.m_playerUserInfo = {}

    local struct_user_info = StructUserInfoColosseum()
    struct_user_info.m_uid = g_userData:get('uid')
    struct_user_info.m_nickname = g_userData:get('nick')
    struct_user_info.m_lv = g_userData:get('lv')

    self.m_playerUserInfo = struct_user_info

    -- 덱 설정
    if (l_deck) then
        for i,v in pairs(l_deck) do
            local deck_name = v['deckName']
            -- 공격 덱
            if (deck_name == 'fatk') then
                self.m_playerUserInfo:applyPvpAtkDeckData(v)
            end
        end
    end
end

-------------------------------------
-- function refresh_playerUserInfo_Arena
-------------------------------------
function ServerData_FriendMatch:refresh_playerUserInfo_Arena(l_deck, my_info)
    self.m_playerUserInfo = {}

    local struct_user_info = StructUserInfoArenaNew()
    struct_user_info.m_uid = g_userData:get('uid')
    struct_user_info.m_nickname = g_userData:get('nick')
    struct_user_info.m_lv = g_userData:get('lv')

    -- 내 랭킹 정보도 세팅
    if (my_info) then
        struct_user_info.m_tamerID = my_info['tamer']
        struct_user_info.m_tier = my_info['tier']
        struct_user_info.m_rank = my_info['rank']
        struct_user_info.m_rankPercent = my_info['rate']
    end

    self.m_playerUserInfo = struct_user_info

    -- 덱 설정
    if (l_deck) then
        self.m_playerUserInfo:applyPvpDeckData(l_deck)
    end
end

-------------------------------------
-- function refresh_matchList
-------------------------------------
function ServerData_FriendMatch:refresh_matchList(match_info)
    self.m_matchInfo = {}
    local struct_user_info = StructUserInfoColosseum()

    -- 기본 유저 정보
    struct_user_info.m_uid = match_info['uid']
    struct_user_info.m_nickname = match_info['nick']
    struct_user_info.m_lv = match_info['lv']
    struct_user_info.m_tamerID = match_info['tamer']
    struct_user_info.m_leaderDragonObject = StructDragonObject(match_info['leader'])
    struct_user_info.m_tier = match_info['tier']

    -- 콜로세움 유저 정보
    struct_user_info.m_rp = match_info['rp']
    struct_user_info.m_matchResult = match_info['match']

    struct_user_info:applyRunesDataList(match_info['runes']) --반드시 드래곤 설정 전에 룬을 설정해야함
    struct_user_info:applyDragonsDataList(match_info['dragons'])

    -- 덱 정보 (매치리스트에 넘어오는 덱은 해당 유저의 방어덱)
    struct_user_info:applyPvpDefDeckData(match_info['deck'])

    self.m_matchInfo = struct_user_info
end

-------------------------------------
-- function refresh_matchList_Arena
-------------------------------------
function ServerData_FriendMatch:refresh_matchList_Arena(match_info)
    self.m_matchInfo = {}
    local struct_user_info = StructUserInfoArenaNew()

    -- 기본 유저 정보
    struct_user_info.m_uid = match_info['uid']
    struct_user_info.m_nickname = match_info['nick']
    struct_user_info.m_lv = match_info['lv']
    struct_user_info.m_tamerID = match_info['tamer']
    struct_user_info.m_leaderDragonObject = StructDragonObject(match_info['leader'])
    struct_user_info.m_tier = match_info['tier']
    struct_user_info.m_rank = match_info['rank']
    struct_user_info.m_rankPercent = match_info['rate']

    -- 콜로세움 유저 정보
    struct_user_info.m_rp = match_info['rp']
    struct_user_info.m_matchResult = match_info['match']

    struct_user_info:applyRunesDataList(match_info['runes']) --반드시 드래곤 설정 전에 룬을 설정해야함
    struct_user_info:applyDragonsDataList(match_info['dragons'])

    -- 덱 정보 (매치리스트에 넘어오는 덱은 해당 유저의 방어덱)
    struct_user_info:applyPvpDeckData(match_info['deck'])

    self.m_matchInfo = struct_user_info
end

-------------------------------------
-- function makeDragonToken
-------------------------------------
function ServerData_FriendMatch:makeDragonToken()
    local token = ''

    local l_deck = g_friendMatchData.m_playerUserInfo:getAtkDeck_dragonList(true)

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