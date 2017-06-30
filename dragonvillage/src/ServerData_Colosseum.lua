-------------------------------------
-- class ServerData_Colosseum
-------------------------------------
ServerData_Colosseum = class({
        m_serverData = 'ServerData',

        m_playerUserInfo = 'StructUserInfoColosseum',
        m_playerUserInfoHighRecord = 'StructUserInfoColosseum',

        m_startTime = 'timestamp', -- 콜로세움 오픈 시간
        m_endTime = 'timestamp', -- 콜로세움 종료 시간

        -- 공격전 대상 리스트 갱신 시간
        m_refreshFreeTime = 'timestamp',

        m_matchList = '',

        m_matchUserID = '',
        m_gameKey = 'number',
        m_nGlobalOffset = 'number', -- 랭킹
        m_lGlobalRank = 'list',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Colosseum:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function goToColosseum
-------------------------------------
function ServerData_Colosseum:goToColosseum()
    local function cb()
		if (self:isOpenColosseum()) then
            UI_Colosseum()
		else
			UIManager:toastNotificationGreen('콜로세움 오픈 전입니다.\n오픈까지 ' .. self:getColosseumStatusText())
		end
    end

    self:request_colosseumInfo(cb)
end

-------------------------------------
-- function request_colosseumInfo
-------------------------------------
function ServerData_Colosseum:request_colosseumInfo(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        self:response_colosseumInfo(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/game/pvp/info')
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
-- function response_colosseumInfo
-------------------------------------
function ServerData_Colosseum:response_colosseumInfo(ret)
    self:refresh_matchList(ret['matchlist'])

    self.m_startTime = ret['start_time']
    self.m_endTime = ret['endtime']

    self:refresh_playerUserInfo(ret['season'], ret['deck'])
    self:refresh_playerUserInfo_highRecord(ret['hiseason'])

    -- 공격전 대상 리스트 갱신 시간
    self.m_refreshFreeTime = ret['refresh']
end

-------------------------------------
-- function refresh_matchList
-------------------------------------
function ServerData_Colosseum:refresh_matchList(l_match_list)
    self.m_matchList = {}

    for i, v in pairs(l_match_list) do
        local struct_user_info = StructUserInfoColosseum()

        -- 기본 유저 정보
        struct_user_info.m_uid = v['uid']
        struct_user_info.m_nickname = v['nick']
        struct_user_info.m_lv = v['lv']
        struct_user_info.m_tamerID = v['tamer']
        struct_user_info.m_leaderDragonObject = StructDragonObject(v['leader'])

        -- 콜로세움 유저 정보
        struct_user_info.m_rp = v['rp']

        struct_user_info:applyRunesDataList(v['runes']) --반드시 드래곤 설정 전에 룬을 설정해야함
        struct_user_info:applyDragonsDataList(v['dragons'])
        --v['match']

        -- 덱 정보 (매치리스트에 넘어오는 덱은 해당 유저의 방어덱)
        struct_user_info:applyPvpDefDeckData(v['deck'])

        local uid = v['uid']
        self.m_matchList[uid] = struct_user_info
    end
end

-------------------------------------
-- function isOpenColosseum
-- @breif 콜로세움 오픈 여부
-------------------------------------
function ServerData_Colosseum:isOpenColosseum()
    local curr_time = Timer:getServerTime()
    local start_time = (self.m_startTime / 1000)
    local end_time = (self.m_endTime / 1000)
	
	return (start_time <= curr_time) and (curr_time <= end_time)
end

-------------------------------------
-- function refresh_playerUserInfo
-- @brief 플레이어 정보 갱신
-------------------------------------
function ServerData_Colosseum:refresh_playerUserInfo(t_data, l_deck)
    if (not self.m_playerUserInfo) then
        -- 플레이어 유저 정보 생성
        local struct_user_info = StructUserInfoColosseum()
        struct_user_info.m_uid = g_userData:get('uid')
        self.m_playerUserInfo = struct_user_info
    end

    if t_data then
        self:_refresh_playerUserInfo(self.m_playerUserInfo, t_data)
    end

    -- 덱 설정
    if l_deck then
        for i,v in pairs(l_deck) do
            local deck_name = v['deckName']
            -- 공격 덱
            if (deck_name == 'atk') then
                self.m_playerUserInfo:applyPvpAtkDeckData(v)

            -- 방어 덱
            elseif (deck_name == 'def') then
                self.m_playerUserInfo:applyPvpDefDeckData(v)

            end
        end
    end
end

-------------------------------------
-- function refresh_playerUserInfo_highRecord
-- @brief 최고 기록 당시 데이터
-------------------------------------
function ServerData_Colosseum:refresh_playerUserInfo_highRecord(t_data)
    if (not self.m_playerUserInfoHighRecord) then
        -- 플레이어 유저 정보 생성
        local struct_user_info = StructUserInfoColosseum()
        struct_user_info.m_uid = g_userData:get('uid')
        self.m_playerUserInfoHighRecord = struct_user_info
    end

    self:_refresh_playerUserInfo(self.m_playerUserInfoHighRecord, t_data)
end

-------------------------------------
-- function _refresh_playerUserInfo
-------------------------------------
function ServerData_Colosseum:_refresh_playerUserInfo(struct_user_info, t_data)
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
-- function getPlayerColosseumUserInfo
-------------------------------------
function ServerData_Colosseum:getPlayerColosseumUserInfo()
    return self.m_playerUserInfo
end

-------------------------------------
-- function getPlayerColosseumUserInfoHighRecord
-------------------------------------
function ServerData_Colosseum:getPlayerColosseumUserInfoHighRecord()
    return self.m_playerUserInfoHighRecord
end

-------------------------------------
-- function getColosseumStatusText
-------------------------------------
function ServerData_Colosseum:getColosseumStatusText()
    local curr_time = Timer:getServerTime()

    local start_time = (self.m_startTime / 1000)
    local end_time = (self.m_endTime / 1000)

    local str = ''
    if (curr_time < start_time) then
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
-- function isFreeRefresh
-- @breif
-------------------------------------
function ServerData_Colosseum:isFreeRefresh()
    local curr_time = Timer:getServerTime()
    local refresh_free_time = (self.m_refreshFreeTime / 1000)
	
	return (refresh_free_time < curr_time)
end

-------------------------------------
-- function getRefreshStatusText
-------------------------------------
function ServerData_Colosseum:getRefreshStatusText()
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
-- function request_atkListRefresh
-------------------------------------
function ServerData_Colosseum:request_atkListRefresh(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        -- 매치 리스트 갱신
        self:refresh_matchList(ret['matchlist'])

        -- 다음 무료 새로고침 가능한 시간
        if ret['refresh'] then
            self.m_refreshFreeTime = ret['refresh']
        end

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/game/pvp/refresh')
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
-- function getMatchUserInfo
-------------------------------------
function ServerData_Colosseum:getMatchUserInfo()
    if (not self.m_matchUserID) then
        return nil
    end

    local uid = self.m_matchUserID
    return self.m_matchList[uid]
end

-------------------------------------
-- function request_setDeck
-------------------------------------
function ServerData_Colosseum:request_setDeck(deckname, formation, leader, l_edoid, tamer, finish_cb, fail_cb)
    local _deckname = deckname
    if (deckname == 'pvp_atk') then
        _deckname = 'atk'
    elseif (deckname == 'pvp_def') then
        _deckname = 'def'
    end

    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        local t_data = nil
        local l_deck = {ret['deck']} -- 변경한 덱 하나의 정보만 오기때문에 감싸준다
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
-- function request_colosseumStart
-------------------------------------
function ServerData_Colosseum:request_colosseumStart(is_cash, vsuid, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
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
    ui_network:setUrl('/game/pvp/ladder/start')
    ui_network:setParam('uid', uid)
    ui_network:setParam('is_cash', is_cash)
    ui_network:setParam('vsuid', vsuid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_colosseumFinish
-------------------------------------
function ServerData_Colosseum:request_colosseumFinish(is_win, finish_cb, fail_cb)
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
        self:refresh_playerUserInfo(ret['season'])

        -- 변경 데이터
        ret['added_rp'] = (self.m_playerUserInfo.m_rp - prev_rp)
        ret['added_honor'] = (g_userData:get('honor') - prev_honor)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/game/pvp/ladder/finish')
    ui_network:setParam('uid', uid)
    ui_network:setParam('is_win', is_win and 1 or 0)
    ui_network:setParam('vs_uid', self.m_matchUserID)
    ui_network:setParam('gamekey', self.m_gameKey)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_colosseumRank
-------------------------------------
function ServerData_Colosseum:request_colosseumRank(offset, finish_cb, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')
    local offset = offset or 0

    -- 콜백 함수
    local function success_cb(ret)
        --[[
        g_serverData:networkCommonRespone(ret)
        self.m_myRank = ret['my_info']
        --]]

        self.m_nGlobalOffset = ret['offset']

        -- 유저 리스트 저장
        self.m_lGlobalRank = {}
        for i,v in pairs(ret['list']) do
            local user_info = StructUserInfoColosseum:create_forRanking(v)
            table.insert(self.m_lGlobalRank, user_info)
        end
        
        if finish_cb then
            return finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/game/pvp/ranking')
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