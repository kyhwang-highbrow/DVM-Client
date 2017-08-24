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

        -- 전투 히스토리 데이터
        m_matchHistory = 'list',

        m_tSeasonRewardInfo = 'table',
        m_tRet = 'table',
        m_buffTime = 'timestamp', -- 버프 유효 시간 (0일 경우 버프 발동 x, 값이 있을 경우 해당 시간까지 버프 적용)

        m_bOpen = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Colosseum:init(server_data)
    self.m_serverData = server_data
    self.m_bOpen = true
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
        self.m_bOpen = ret['open']

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
    
    -- 주간 보상이 넘어왔을 경우
    g_serverData:networkCommonRespone_addedItems(ret)

    self:refresh_matchList(ret['matchlist'])

    self.m_startTime = ret['start_time']
    self.m_endTime = ret['endtime']

    self:refresh_playerUserInfo(ret['season'], ret['deck'])
    self:refresh_playerUserInfo_highRecord(ret['hiseason'])

    -- 공격전 대상 리스트 갱신 시간
    self.m_refreshFreeTime = ret['refresh']

    -- 주간 보상
    self:setSeasonRewardInfo(ret)

    -- 버프 발동 종료 시간
    self.m_buffTime = ret['bufftime']
end

-------------------------------------
-- function refresh_matchList
-------------------------------------
function ServerData_Colosseum:refresh_matchList(l_match_list)
    self.m_matchList = {}

    for i, v in pairs(l_match_list) do

		-- 서버에서 잘못된 데이터가 넘어오는 경우 클라에서 처리하지 않음
		-- (여러 값들이 null로 오는 경우가 있음)
        if v['uid'] then
            local struct_user_info = StructUserInfoColosseum()

            -- 기본 유저 정보
            struct_user_info.m_uid = v['uid']
            struct_user_info.m_nickname = v['nick']
            struct_user_info.m_lv = v['lv']
            struct_user_info.m_tamerID = v['tamer']
            struct_user_info.m_leaderDragonObject = StructDragonObject(v['leader'])
            struct_user_info.m_tier = v['tier']

            -- 콜로세움 유저 정보
            struct_user_info.m_rp = v['rp']
            struct_user_info.m_matchResult = v['match']

            struct_user_info:applyRunesDataList(v['runes']) --반드시 드래곤 설정 전에 룬을 설정해야함
            struct_user_info:applyDragonsDataList(v['dragons'])
            --v['match']

            -- 덱 정보 (매치리스트에 넘어오는 덱은 해당 유저의 방어덱)
            struct_user_info:applyPvpDefDeckData(v['deck'])

            local uid = v['uid']
            self.m_matchList[uid] = struct_user_info
        end
    end
end

-------------------------------------
-- function isOpen
-- @breif 콜로세움 오픈 여부 (시간 체크와 별도로 진입시 검사)
-------------------------------------
function ServerData_Colosseum:isOpen()
    return self.m_bOpen
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
    if (not self:isOpenColosseum()) then
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
        -- cash 정보를 갱신
        g_serverData:networkCommonRespone(ret)

        -- 매치 리스트 갱신
        self:refresh_matchList(ret['matchlist'])

        -- 다음 무료 새로고침 가능한 시간
        if ret['refresh'] then
            self.m_refreshFreeTime = ret['refresh']
        end

        if finish_cb then
            finish_cb(ret)
        end

        -- 매치 리스트가 갱신이 되지 않았을 경우 안내 팝업
        if ret['nomatch'] then
            local msg = Str('더 이상 대전상대를 찾을 수 없습니다.\n잠시 후에 다시 시도해 주세요.')
            local submsg = Str('(대전상대를 찾지 못하면 무료횟수 및 다이아가 소비되지 않습니다.)')
            MakeSimplePopup2(POPUP_TYPE.OK, msg, submsg)
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

    -- 공격자의 콜로세움 전투력 저장
    local combat_power = g_colosseumData.m_playerUserInfo:getAtkDeckCombatPower(true)
    
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
        local season_data = ret['season']
        self:refresh_playerUserInfo(season_data)

        if (season_data['win'] == 1) then
            -- @analytics
            Analytics:firstTimeExperience('Colosseum_Win')
        end

        -- 변경 데이터
        --ret['added_rp'] = (self.m_playerUserInfo.m_rp - prev_rp)
        ret['added_rp'] = ret['point'] -- 실시간으로 변경된 값이 있을 수 있으므로 서버에서 넘어오는 값을 표기
        ret['added_honor'] = (g_userData:get('honor') - prev_honor)

        -- 버프 발동 종료 시간
        self.m_buffTime = ret['bufftime']

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

-------------------------------------
-- function request_colosseumDefHistory
-------------------------------------
function ServerData_Colosseum:request_colosseumDefHistory(finish_cb, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)

        self.m_matchHistory = {}
        for i,v in pairs(ret['history']) do
            local user_info = StructUserInfoColosseum:create_forHistory(v)
            table.insert(self.m_matchHistory, user_info)
        end
        
        if finish_cb then
            return finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/game/pvp/history')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

	return ui_network
end

-------------------------------------
-- function setSeasonRewardInfo
-------------------------------------
function ServerData_Colosseum:setSeasonRewardInfo(ret)
    if (ret['reward'] == true) and ret['lastseason'] then
        -- 플레이어 유저 정보 생성
        local struct_user_info = StructUserInfoColosseum()
        struct_user_info.m_uid = g_userData:get('uid')

        self:_refresh_playerUserInfo(struct_user_info, ret['lastseason'])
        self.m_tSeasonRewardInfo = struct_user_info
        self.m_tRet = ret

        -- ret['week'] -- 주차
        -- ret['total'] -- 순위를 가진 전체 유저 수

        -- 보상 cash 갯수 저장
        local added_items = {}
        added_items['items_list'] = ret['reward_info'] or {}
        local t_item_id_cnt, t_iten_type_cnt = ServerData_Item:parseAddedItems(added_items)
        struct_user_info.m_userData = t_iten_type_cnt

        -- @analytics
        Analytics:trackGetGoodsWithRet(ret, '콜로세움(주간보상)')
    end
end

-------------------------------------
-- function getStraightBuffText
-- @brief 연승 버프 텍스트
-------------------------------------
function ServerData_Colosseum:getStraightBuffText()
    --[[

    --]]

    -- 연승 정보
    local straight = self.m_playerUserInfo.m_straight
    local t_ret = TableColosseumBuff:getStraightBuffData(straight)

    local text = nil
    for i,v in ipairs(t_ret) do
        local option = v['option']
        local value = v['value']
        local desc = TableOption:getOptionDesc(option, value)

        if (not text) then
            text = desc
        else
            text = text .. ', ' .. desc
        end
    end

    if (not text) then
        return Str('연승 버프 없음')
    end

    return text
end

-------------------------------------
-- function getStraightTimeText
-- @brief 연승 버프 시간 텍스트
-------------------------------------
function ServerData_Colosseum:getStraightTimeText()
    -- 연승 정보
    local straight = self.m_playerUserInfo.m_straight

    if (straight <= 1) then
        return '', false
    end


    local curr_time = Timer:getServerTime()
    local buff_time = (self.m_buffTime / 1000)

    -- 시간 초과
    if (buff_time <= curr_time) then
        return '', false
    end

    
    local time = (buff_time - curr_time)
    return Str('{1} 남음', datetime.makeTimeDesc(time, true)), true
end



-------------------------------------
-- function request_playerColosseumDeck
-- @brief 플레이어 유저의 덱 정보를 저장하기 위한 임시 용도 (sgkim)
-------------------------------------
function ServerData_Colosseum:request_playerColosseumDeck(deckname, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        local l_deck = {ret['pvpuser_info']['deck']}
        self:refresh_playerUserInfo(nil, l_deck) -- param : t_data, l_deck

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 응답 상태 처리 함수
    local function response_status_cb(ret)
        -- 상대방의 덱 정보가 없는 경우 skip 처리
        if (ret['status'] == -1160) then -- not exist deck
            if finish_cb then
                finish_cb(ret)
            end
            return true
        end
        return false
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/game/pvp/user_info')
    ui_network:setParam('uid', uid)
    ui_network:setParam('peer', uid)
    ui_network:setParam('name', deckname)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setRevocable(false)
    ui_network:request()
    
    return ui_network
end


-------------------------------------
-- function makeDragonToken
-------------------------------------
function ServerData_Colosseum:makeDragonToken()
    local token = ''

    local l_deck = g_colosseumData.m_playerUserInfo:getAtkDeck_dragonList(true)

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