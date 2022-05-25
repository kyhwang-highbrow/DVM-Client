-------------------------------------
-- class ServerData_GrandArena
-- @instance g_grandArena
-------------------------------------
ServerData_GrandArena = class({
        m_serverData = 'ServerData',

        m_matchUserInfo = 'StructUserInfoArena',
		m_playerUserInfo = 'StructUserInfoArena',
        m_nGlobalOffset = 'number',
        m_lGlobalRank = 'list',
        m_matchListStructUserInfo = 'table',
        m_grandArenaRewardTable = 'table',
        
        -- Ranking tier 정보 필요해서 서버에서 받음, table_grand_arena
        m_grandArenaRankingInfoTable = 'table',

        -- 시즌 보상 획득 상태
        -- 0 -> 이번 시즌 보상 받을게 있음
        -- 1 -> 이번 시즌 보상 받음
        -- 2 -> 이번 시즌 보상 받을게 없음
        m_seasonRewardStatus = 'number',
        m_tSeasonRewardInfo = 'talbe', -- 시즌 보상을 받았을 경우

        -- 서버 로그를 위해 임시 저장
        m_tempLogData = 'table',
        m_grandArenaVersion = 'version', -- 히스토리 요청할 때 필요한 파라매터
        m_matchHistory = 'table',
    })


ServerData_GrandArena.STATE = {
	['INACTIVE'] = 1,	-- 이벤트 던전 비활성화
	['LOCK'] = 2,		-- 레벨 제한
    ['PRESEASON'] = 3,	-- 프리시즌
	['OPEN'] = 4,		-- 이벤트 던전 입장 가능
	['REWARD'] = 5,		-- 보상 수령 가능
	['DONE'] = 6,		-- 보상 수령 후 
}

-------------------------------------
-- function init
-------------------------------------
function ServerData_GrandArena:init(server_data)
    self.m_tempLogData = {}
    self.m_matchHistory = {['atk']={}, ['def']= {}}
end


-------------------------------------
-- function isActive_grandArena
-- @brief 그랜드 콜로세움 이벤트가 진행 중인지 여부 true or false
-------------------------------------
function ServerData_GrandArena:isActive_grandArena()
    return (self:getGrandArenaState() ~= ServerData_GrandArena.STATE['INACTIVE'])
end

-------------------------------------
-- function isPreseason
-- @brief 연습전 기간인지
-------------------------------------
function ServerData_GrandArena:isPreseason()
    return (self:getGrandArenaState() == ServerData_GrandArena.STATE['PRESEASON'])
end

-------------------------------------
-- function getGrandArenaState
-- @brief 그랜드 콜로세움 상태
-- @use ServerData_GrandArena.STATE
-------------------------------------
function ServerData_GrandArena:getGrandArenaState()
	-- 예외처리
	if (not g_hotTimeData) then
		return ServerData_GrandArena.STATE['INACTIVE']

    -- 연습전
    elseif (g_hotTimeData:isActiveEvent('event_grand_arena_preseason')) then
        return ServerData_GrandArena.STATE['PRESEASON']
        --[[
        -- 레벨 체크
		if (g_contentLockData:isContentLock('grand_arena')) then
			return ServerData_GrandArena.STATE['LOCK']

		else
			return ServerData_GrandArena.STATE['PRESEASON']
		end
        --]]
	-- 이벤트 기간
	elseif (g_hotTimeData:isActiveEvent('event_grand_arena')) then
		return ServerData_GrandArena.STATE['OPEN']
        --[[
		-- 레벨 체크
		if (g_contentLockData:isContentLock('grand_arena')) then
			return ServerData_GrandArena.STATE['LOCK']

		else
			return ServerData_GrandArena.STATE['OPEN']
		end
        -]]
	-- 보상 수령 기간
	elseif (g_hotTimeData:isActiveEvent('event_grand_arena_reward')) then
		if (self.m_seasonRewardStatus == 0) then
			return ServerData_GrandArena.STATE['REWARD']

		-- 보상 수령 후 (1 -> 이번 시즌 보상 받음, 2 -> 이번 시즌 보상 받을게 없음)
		elseif (self.m_seasonRewardStatus == 1) or (self.m_seasonRewardStatus == 2) then
			return ServerData_GrandArena.STATE['DONE']
        end
        
        --[[
		-- 레벨 체크
		if (g_contentLockData:isContentLock('grand_arena')) then
			return ServerData_GrandArena.STATE['LOCK']

		-- 보상 수령 전 (0 -> 이번 시즌 보상 받을게 있음)
		elseif (self.m_seasonRewardStatus == 0) then
			return ServerData_GrandArena.STATE['REWARD']

		-- 보상 수령 후 (1 -> 이번 시즌 보상 받음, 2 -> 이번 시즌 보상 받을게 없음)
		elseif (self.m_seasonRewardStatus == 1) or (self.m_seasonRewardStatus == 2) then
			return ServerData_GrandArena.STATE['DONE']

		end
        --]]
	end

	-- 해당 없으면 비활성화
	return ServerData_GrandArena.STATE['INACTIVE']
end

-------------------------------------
-- function request_grandArenaInfo
-- @brief 그랜드 콜로세움 이벤트 요청
-------------------------------------
function ServerData_GrandArena:request_grandArenaInfo(finish_cb, fail_cb, include_reward)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        -- 동기화
        g_serverData:networkCommonRespone(ret)

        -- 플레이어 랭킹 정보 갱신
        if ret['season'] then
            self:refresh_playerUserInfo(ret['season'], nil)
        end

        -- 보상 수령 여부 저장
		if (ret['reward']) then
			self.m_seasonRewardStatus = ret['reward']
		end

        -- 시즌 보상 정보 저장
        if ret['reward_info'] and (0 < table.count(ret['reward_info'])) then
            self.m_tSeasonRewardInfo = ret['reward_info']
        end

        -- 시즌 보상 정보 저장
        if (ret['table_grand_arena_rank']) then
            self.m_grandArenaRewardTable = ret['table_grand_arena_rank']
        end

		 -- 현재 시즌 버젼 정보 저장
		if (ret['version']) then
			self.m_grandArenaVersion = ret['version']
		end

        -- 랭킹 정보 테이블 저장
        if (ret['table_grand_arena']) then
            if (not self.m_grandArenaRankingInfoTable) then
                local list = ret['table_grand_arena']
                self.m_grandArenaRankingInfoTable = table.listToMap(list, 'tid')
            end
        end

        -- 통신 후에는 삭제
        -- 서버 로그를 위해 임시 저장
        self.m_tempLogData = {}

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- true를 리턴하면 자체적으로 처리를 완료했다는 뜻
    local function response_status_cb(ret)
        -- -1351 invalid time (오픈 시간이 아님)
        if (ret['status'] == -1351) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('시즌이 종료되었습니다.'))
            return true

        -- -1364 invalid season
        elseif (ret['status'] == -1364) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('시즌이 종료되었습니다.'))
            return true
        end

        return false
    end

    -- 서버에서 테이블 정보를 받아옴
    local include_tables = false
    if (self.m_grandArenaRankingInfoTable == nil) or (self.m_grandArenaRewardTable == nil) then
        include_tables = true
    end
    
    -- 시즌 보상을 받을지 여부 (타이틀 화면에서 정보 요청을 위해 호출될때는 제외하기 위함)
    local include_reward = (include_reward or false)

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/game/grand_arena/info')
    ui_network:setParam('uid', uid)
    ui_network:setParam('include_infos', include_infos)
    ui_network:setParam('include_tables', include_tables)
    ui_network:setParam('reward', include_reward) -- true면 시즌 보상을 지금, false면 시즌 보상을 미지급
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

	return ui_network
end

-------------------------------------
-- function request_grandArenaGetMatchList
-- @brief
-------------------------------------
function ServerData_GrandArena:request_grandArenaGetMatchList(is_cash, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        -- 동기화
        g_serverData:networkCommonRespone(ret)

        -- 매치 리스트를 StructUserInfoArena로 생성
        self.m_matchListStructUserInfo = {}
        if ret['matchlist'] then
            for i,t_data in ipairs(ret['matchlist']) do
                self.m_matchListStructUserInfo[i] = StructUserInfoArena:createUserInfo_forGrandArena(t_data)
            end
        end

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- true를 리턴하면 자체적으로 처리를 완료했다는 뜻
    local function response_status_cb(ret)
        -- -1108 not exist match (매칭 상대가 없음)
        if (ret['status'] == -1108) then
            MakeSimplePopup(POPUP_TYPE.OK, Str('현재 점수 구간 내의 대전 가능한 상대가 없습니다.\n다른 상대의 콜로세움 참여를 기다린 후에 다시 시도해 주세요.'), ok_cb)
            if fail_cb then fail_cb() end
            return true

        -- -1278 not enough st_grand_arena
        elseif (ret['status'] == -1278) then
            local msg = Str('입장권이 부족합니다.')
            MakeSimplePopup(POPUP_TYPE.OK, msg)
            if fail_cb then fail_cb() end
            return true
        end

    
        return false
    end

    -- Log를 위해 start/finish에 던질 데이터들 임시 저장
    self.m_tempLogData['is_cash'] = is_cash

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/game/grand_arena/get_match_list')
    ui_network:setParam('uid', uid)
    ui_network:setParam('is_cash', is_cash)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

	return ui_network
end

-------------------------------------
-- function requestGameStart
-------------------------------------
function ServerData_GrandArena:requestGameStart(vs_uid, combat_power, finish_cb, fail_cb)
    local uid = g_userData:get('uid')
    local response_status_cb

    local function success_cb(ret)
        -- server_info, staminas 정보를 갱신
        g_serverData:networkCommonRespone(ret)

        local game_key = ret['gamekey']
        finish_cb(game_key)

        -- match_user를 받고 있지만 사용하지 않음

        -- 스피드핵 방지 실제 플레이 시간 기록
        g_accessTimeData:startCheckTimer()

        -- 온전한 연속 전투 검사
        g_autoPlaySetting:setSequenceAutoPlay()
    end


    local multi_deck_mgr = MultiDeckMgr(MULTI_DECK_MODE.EVENT_ARENA)
    local deck_name1 = multi_deck_mgr:getDeckName('up')
    local deck_name2 = multi_deck_mgr:getDeckName('down')

    local token1 = g_stageData:makeDragonToken(deck_name1)
    local token2 = g_stageData:makeDragonToken(deck_name2)
    local teambonus1 = g_stageData:getTeamBonusIds(deck_name1)
    local teambonus2 = g_stageData:getTeamBonusIds(deck_name2)

    
    local ui_network = UI_Network()
    ui_network:setUrl('/game/grand_arena/start')
    ui_network:setRevocable(true)
    ui_network:setParam('uid', uid)
    ui_network:setParam('vs_uid', vs_uid)
    ui_network:setParam('deck_name1', deck_name1)
    ui_network:setParam('deck_name2', deck_name2)
    ui_network:setParam('token1', token1)
    ui_network:setParam('token2', token2)
    ui_network:setParam('combat_power', combat_power) -- 팀 전투력 log를 위해 전송
    ui_network:setParam('team_bonus1', teambonus1)
    ui_network:setParam('team_bonus2', teambonus2)

    -- 다이아 사용 
    local is_cash = self.m_tempLogData['is_cash'] or false
    ui_network:setParam('is_cash', is_cash)

    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setSuccessCB(success_cb)
	ui_network:setFailCB(fail_cb)
    ui_network:request()
end

-------------------------------------
-- function requestGameFinish
-------------------------------------
function ServerData_GrandArena:requestGameFinish(gamekey, is_win, clear_time, finish_cb, fail_cb)
    local uid = g_userData:get('uid')

    local function success_cb(ret)
        local prev_gold = g_userData:get('gold')

        -- server_info, staminas 정보를 갱신
        g_serverData:networkCommonRespone(ret)
        g_serverData:networkCommonRespone_addedItems(ret)

        -- 플레이어 랭킹 정보 갱신
        if ret['season'] then
            self:refresh_playerUserInfo(ret['season'], nil)
        end

        -- 변경 데이터
        --ret['added_rp'] = (self.m_playerUserInfo.m_rp - prev_rp)
        ret['added_rp'] = ret['point'] -- 실시간으로 변경된 값이 있을 수 있으므로 서버에서 넘어오는 값을 표기
        --ret['added_gold'] = (g_userData:get('gold') - prev_gold)

        -- 골드 증가량
        local added_gold = 0
        if (ret['added_items'] and ret['added_items']['items_list']) then
            for i,v in pairs(ret['added_items']['items_list']) do
                if (v['item_id'] == ITEM_ID_GOLD) then
                    added_gold = (added_gold + (v['count'] or 0))
                end
            end
        end
        ret['added_gold'] = added_gold

        finish_cb(ret)
    end

    -- true를 리턴하면 자체적으로 처리를 완료했다는 뜻
    local function response_status_cb(ret)
        -- -1351 invalid time (오픈 시간이 아님)
        if (ret['status'] == -1351) or (ret['status'] == -1364) then

            MakeSimplePopup(POPUP_TYPE.OK, Str('시즌이 종료되었습니다.'), function() UINavigator:goTo('lobby') end)
            return true
        end

        return false
    end

    -- 승리 여부를 서버에 전달할때 number로 전달
    if (type(is_win) == 'boolean') then
        is_win = conditionalOperator((is_win == true), 1, 0)
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/game/grand_arena/finish')
    ui_network:setRevocable(true)
    ui_network:setParam('uid', uid)
    ui_network:setParam('is_win', is_win)
    ui_network:setParam('gamekey', gamekey)
    ui_network:setParam('clear_time', clear_time)
    ui_network:setParam('check_time', g_accessTimeData:getCheckTime())

    -- 서버 Log를 위해 클라에서 넘기는 값들
    do 
        -- 다이아 사용 
        local is_cash = self.m_tempLogData['is_cash'] or false
        ui_network:setParam('is_cash', is_cash)

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

        -- 통신 후에는 삭제
        self.m_tempLogData = {}
    end

    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setSuccessCB(success_cb)
	ui_network:setFailCB(fail_cb)
    ui_network:request()
end

-------------------------------------
-- function request_grandArenaRanking
-------------------------------------
function ServerData_GrandArena:request_grandArenaRanking(rank_type, offset, finish_cb, fail_cb)
    
--[[  
        -- 데이터 구조
        ['lv']=65;
        ['rate']=0.14285714924335;
        ['rank']=1;
        ['tier']='legend';
        ['tamer']=110001;
        ['un']=130200096;
        ['clan_info']={
                ['mark']='25;34;29;21';
                ['name']='그림자모여라';
                ['id']='5bd679c8e891935dfd79f290';
        };
        ['uid']='IITgW1cBs1Mwyl3gKaOETar6gs23';
        ['total']=7;
        ['leader']={
                ['lv']=60;
                ['mastery_lv']=10;
                ['grade']=6;
                ['rlv']=6;
                ['eclv']=0;
                ['did']=120872;
                ['mastery_skills']={
                        ['410203']=3;
                        ['410101']=3;
                        ['410301']=3;
                        ['410402']=1;
                };
                ['evolution']=3;
                ['mastery_point']=0;
        };
        ['nick']='남작';
        ['rp']=660;
        ['score']=0;
--]]
    local func_request
    local func_success_cb
    local func_response_status_cb

    func_request = function()
        -- 유저 ID
        local uid = g_userData:get('uid')

        -- 네트워크 통신
        local ui_network = UI_Network()
        ui_network:setUrl('/game/grand_arena/ranking')
        ui_network:setParam('uid', uid)
        ui_network:setParam('type', rank_type)
        ui_network:setParam('offset', offset)
        ui_network:setParam('limit', 30)
        ui_network:setMethod('POST')
        ui_network:setSuccessCB(func_success_cb)
        ui_network:setResponseStatusCB(response_status_cb)
        ui_network:setFailCB(fail_cb)
        ui_network:setRevocable(true)
        ui_network:setReuse(false)
        ui_network:request()
    end

    -- true를 리턴하면 자체적으로 처리를 완료했다는 뜻
    func_response_status_cb = function(ret)
        return false
    end

    -- 성공 콜백
    func_success_cb = function(ret)
        self.m_nGlobalOffset = ret['offset']
        -- 유저 리스트 저장
        self.m_lGlobalRank = {}
        for i,v in pairs(ret['list']) do
            local user_info = StructUserInfoArena:create_forRanking(v)
            table.insert(self.m_lGlobalRank, user_info)
        end

        -- 플레이어 랭킹 정보 갱신
        if ret['my_info'] then
            self:refresh_playerUserInfo(ret['my_info'], nil)
        end

        if finish_cb then
            finish_cb(ret)
        end
    end

    func_request()
end

-------------------------------------
-- function setMatchUserInfo
-------------------------------------
function ServerData_GrandArena:setMatchUserInfo(struct_user_info)
    self.m_matchUserInfo = struct_user_info
end

-------------------------------------
-- function getMatchUserInfo
-------------------------------------
function ServerData_GrandArena:getMatchUserInfo()
    if self.m_matchUserInfo then
        return self.m_matchUserInfo
    end

    return self:getPlayerGrandArenaUserInfo()
end

-------------------------------------
-- function getPlayerGrandArenaUserInfo
-------------------------------------
function ServerData_GrandArena:getPlayerGrandArenaUserInfo()
    -- 기본 정보 생성을 위해 호출
    if (not self.m_playerUserInfo) then
        self:refresh_playerUserInfo()
    end

    -- 덱 정보는 항상 갱신
    local t_deck_data = g_deckData:getDeck_lowData('grand_arena_up')
    self.m_playerUserInfo:applyDeckData('grand_arena_up', t_deck_data)

    local t_deck_data = g_deckData:getDeck_lowData('grand_arena_down')
    self.m_playerUserInfo:applyDeckData('grand_arena_down', t_deck_data)

    -- 클랜 정보는 항상 갱신
    self.m_playerUserInfo:setStructClan(g_clanData:getClanStruct())

    -- 기본 정보 갱신
    self.m_playerUserInfo.m_nickname = g_userData:get('nick')
    self.m_playerUserInfo.m_lv = g_userData:get('lv')

    return self.m_playerUserInfo
end

-------------------------------------
-- function refresh_playerUserInfo
-- @brief 플레이어 정보 갱신
-------------------------------------
function ServerData_GrandArena:refresh_playerUserInfo(t_data, l_deck)
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

    -- 클랜 정보는 항상 갱신
    self.m_playerUserInfo:setStructClan(g_clanData:getClanStruct())
end

-------------------------------------
-- function _refresh_playerUserInfo
-------------------------------------
function ServerData_GrandArena:_refresh_playerUserInfo(struct_user_info, t_data)
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
-- function getGrandArenaStatusText
-------------------------------------
function ServerData_GrandArena:getGrandArenaStatusText()
    
    -- 연습전 기간 (프리시즌)
    if (self:getGrandArenaState() == ServerData_GrandArena.STATE['PRESEASON']) then
        local time = g_hotTimeData:getEventRemainTime('event_grand_arena_preseason') or 0
        str = Str('{1} 남음', ServerTime:getInstance():makeTimeDescToSec(time, true)) -- param : sec, showSeconds, firstOnly, timeOnly
        return str
    end

    local time = g_hotTimeData:getEventRemainTime('event_grand_arena') or 0

    local str = ''
    if (not self:isActive_grandArena()) then
        if (time <= 0) then
            str = Str('오픈시간이 아닙니다.')
        end

    elseif (0 < time) then
        str = Str('{1} 남음', ServerTime:getInstance():makeTimeDescToSec(time, true)) -- param : sec, showSeconds, firstOnly, timeOnly

    else
        str = Str('종료되었습니다.')
    end

    return str
end

-------------------------------------
-- function requestUserDeck_grandArena
-------------------------------------
function ServerData_GrandArena:requestUserDeck_grandArena(peer_uid)
    local uid = g_userData:get('uid')

    local function success_cb(ret)
        local struct_user_info = StructUserInfoArena:createUserInfo_forGrandArena(ret['pvpuser_info'])
        UI_UserDeckInfo_GrandArena_Popup(struct_user_info)
    end

    local function fail_cb(ret)
    end

    local ui_network = UI_Network()
    ui_network:setRevocable(true)
    ui_network:setUrl('/game/grand_arena/user_info')
    ui_network:setParam('deck_name1', 'grand_arena_up')
    ui_network:setParam('deck_name2', 'grand_arena_down')
    ui_network:setParam('uid', uid)
    ui_network:setParam('peer', peer_uid)
    if (history_id) then
        ui_network:setParam('oid', history_id)
    end
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:request()
end

-------------------------------------
-- function getTierGroupByTierId
-------------------------------------
function ServerData_GrandArena:getTierGroupByTierId(tier_id)
    if (not self.m_grandArenaRankingInfoTable[tier_id]) then
        return nil
    end

    return self.m_grandArenaRankingInfoTable[tier_id]['group']
end

-------------------------------------
-- function getTierNameByTierId
-------------------------------------
function ServerData_GrandArena:getTierNameByTierId(tier_id)
    if (not self.m_grandArenaRankingInfoTable[tier_id]) then
        return nil
    end

    return self.m_grandArenaRankingInfoTable[tier_id]['tier']
end

-------------------------------------
-- function request_grandArenaHistory
-------------------------------------
function ServerData_GrandArena:request_grandArenaHistory(type, finish_cb, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        self.m_matchHistory[type] = {}
        for i,v in pairs(ret['history']) do
            local user_info = StructUserInfoArena:createUserInfo_forGrandArena(v)
            table.insert(self.m_matchHistory[type], user_info)   
        end
        finish_cb()
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/game/grand_arena/history')
    ui_network:setParam('uid', uid)
    ui_network:setParam('version', self.m_grandArenaVersion) -- 현재 시즌 버젼
    ui_network:setParam('type', type) -- atk 공격 기록 , def 방어 기록
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

	return ui_network
end

-------------------------------------
-- function setPreseasonData
-------------------------------------
function ServerData_GrandArena:setPreseasonData()
    -- 매치 리스트를 StructUserInfoArena로 생성
    self.m_matchListStructUserInfo = {}

    self.m_matchListStructUserInfo[1] = StructUserInfoArena:createUserInfo_forGrandArena(TABLE:loadJsonTable('grand_arena_bot1', '.txt'))
    self.m_matchListStructUserInfo[2] = StructUserInfoArena:createUserInfo_forGrandArena(TABLE:loadJsonTable('grand_arena_bot2', '.txt'))
    self.m_matchListStructUserInfo[3] = StructUserInfoArena:createUserInfo_forGrandArena(TABLE:loadJsonTable('grand_arena_bot3', '.txt'))
    self.m_matchListStructUserInfo[4] = StructUserInfoArena:createUserInfo_forGrandArena(TABLE:loadJsonTable('grand_arena_bot4', '.txt'))
    self.m_matchListStructUserInfo[5] = StructUserInfoArena:createUserInfo_forGrandArena(TABLE:loadJsonTable('grand_arena_bot5', '.txt'))
end
