-------------------------------------
-- class ServerData_Colosseum
-------------------------------------
ServerData_Colosseum = class({
        m_serverData = 'ServerData',

        -- 내 정보
        m_playerUserInfo = '',

        -- 상대방 정보
        m_vsUserInfo = '',

        -- 매칭된 게임의 고유 키
        m_colosseumGameKey = '',

		-- Colosseum status
        m_week = '', -- 현재 주차 정보
        m_startTime = '',
        m_endTime = '',
		m_hasWeeklyReward = 'bool',
		m_lastWeekInfo = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Colosseum:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function goToColosseumScene
-------------------------------------
function ServerData_Colosseum:goToColosseumScene()
    local function cb()
		if (self:getIsOpenColosseum()) then
			local scene = SceneColosseum()
			scene:runScene()
		else
			UIManager:toastNotificationGreen('콜로세움 오픈 전입니다.\n오픈까지 ' .. self:getWeekTimeText())
		end
    end

    g_colosseumData:request_colosseumInfo(cb)
end

-------------------------------------
-- function request_colosseumInfo
-------------------------------------
function ServerData_Colosseum:request_colosseumInfo(cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        self:response_colosseumInfo(ret, cb)
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/game/pvp/info')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function response_colosseumInfo
-------------------------------------
function ServerData_Colosseum:response_colosseumInfo(ret, cb)    

    self:initPlayerColosseumInfo()
    self.m_playerUserInfo:setRP(ret['rp'])
    self.m_playerUserInfo:setRank(ret['myrank'])
    self.m_playerUserInfo:setRankPercent(ret['rank_percent'])
    self.m_playerUserInfo:setTier(ret['tier'])
    self.m_playerUserInfo:setStraight(ret['straight'])

    -- 승, 패 횟수
    self.m_playerUserInfo.m_winCnt = ret['win']
    self.m_playerUserInfo.m_loseCnt = ret['lose'] 
  
    self:setColosseumStatus(ret['week'], ret['start_time'], ret['end_time'], ret['has_weekly_reward'])
	self:setLastWeekInfo(ret['last_week_tier'], ret['last_week_rank'], ret['last_week_win'], ret['last_week_lose'])

    if cb then
        cb(ret)
    end
end

-------------------------------------
-- function setColosseumStatus
-------------------------------------
function ServerData_Colosseum:setColosseumStatus(week, start_time, end_time, has_weekly_reward)
    self.m_week = week
    self.m_startTime = start_time
    self.m_endTime = end_time
	self.m_hasWeeklyReward = has_weekly_reward
end

-------------------------------------
-- function setLastWeekInfo
-------------------------------------
function ServerData_Colosseum:setLastWeekInfo(last_week_tier, last_week_rank, last_week_win, last_week_lose)
	self.m_lastWeekInfo = {}
	self.m_lastWeekInfo['tier'] = last_week_tier
	self.m_lastWeekInfo['rank'] = last_week_rank
	self.m_lastWeekInfo['win'] = last_week_win
	self.m_lastWeekInfo['lose'] = last_week_lose
end

-------------------------------------
-- function initPlayerColosseumInfo
-------------------------------------
function ServerData_Colosseum:initPlayerColosseumInfo() 
    if (self.m_playerUserInfo) then
        return
    end

    self.m_playerUserInfo = ColosseumUserInfo()

    self.m_playerUserInfo.m_bPlayerUser = true
    self.m_playerUserInfo:setUid(g_userData:get('uid'))
    self.m_playerUserInfo:setNickname(g_userData:get('nick'))
end

-------------------------------------
-- function request_colosseumStart
-------------------------------------
function ServerData_Colosseum:request_colosseumStart(is_cash, cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        self:response_colosseumStart(ret, cb)
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/game/pvp/ladder/start')
    ui_network:setParam('uid', uid)
    ui_network:setParam('is_cash', is_cash)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function response_colosseumStart
-------------------------------------
function ServerData_Colosseum:response_colosseumStart(ret, cb)

    self.m_colosseumGameKey = ret['pvp_id']

    -- 상대방 유저 정보 설정
    self.m_vsUserInfo = ColosseumUserInfo()
    self.m_vsUserInfo:setRP(ret['vs_info']['rp']) -- 랭킹 포인트
    self.m_vsUserInfo:setTier(ret['vs_info']['tier']) -- 티어
    self.m_vsUserInfo:setNickname(ret['vs_info']['nickname']) -- 닉네임
    self.m_vsUserInfo:setUid(ret['vs_info']['uid']) -- UID
    self.m_vsUserInfo:setTamer(ret['vs_info']['tamer']) -- 테이머

    self.m_vsUserInfo:setDragons(ret['vs_dragons'])
    self.m_vsUserInfo:setRunes(ret['vs_runes'])
    self.m_vsUserInfo:setDeckInfo(ret['vs_deck'])

    -- 테스트용 상대방 덱 설정
    if COLOSSEUM__USE_TEST_ENEMY_DECK then
        g_colosseumData:setTestColosseumDeck()
    end
    
    if cb then
        cb(ret)
    end
end

-------------------------------------
-- function request_colosseumFinish
-------------------------------------
function ServerData_Colosseum:request_colosseumFinish(cb, is_win)
    -- 파라미터
    local uid = g_userData:get('uid')
    local vs_uid = self.m_vsUserInfo.m_uid
    local is_win = is_win and 1 or 0
    local pvp_id = self.m_colosseumGameKey

    -- 콜백 함수
    local function success_cb(ret)
        self:response_colosseumFinish(ret, cb)

        g_colosseumRankData.m_bDirtyGlobalRank = true
        g_colosseumRankData.m_bDirtyTopRank = true
        g_colosseumRankData.m_bDirtyFriendRank = true
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/game/pvp/ladder/finish')
    ui_network:setParam('uid', uid)
    ui_network:setParam('vs_uid', vs_uid)
    ui_network:setParam('is_win', is_win)
    ui_network:setParam('pvp_id', pvp_id)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function response_colosseumFinish
-------------------------------------
function ServerData_Colosseum:response_colosseumFinish(ret, cb)

    -- 결과 정 데이터
    local t_user_info = self.m_playerUserInfo   
    local prev_rp = t_user_info.m_rp or 0
    local prev_honor = g_userData:get('honor')

    g_serverData:networkCommonRespone_addedItems(ret)

    -- 플레이어 유저 정보 갱신
    local t_user_info = self.m_playerUserInfo
    t_user_info.m_loseCnt = ret['lose']
    t_user_info.m_winCnt = ret['win']
    t_user_info:setTier(ret['tier'])
    t_user_info:setStraight(ret['straight'])
    t_user_info:setRP(ret['rp'])

    -- tier_reward -- 티어 보상 여부

    -- 결과 후 데이터
    local after_rp = t_user_info.m_rp
    local after_honor = g_userData:get('honor')

    ret['added_rp'] = (after_rp - prev_rp)
    ret['added_honor'] = (after_honor - prev_honor)

    if cb then
        cb(ret)
    end
end

-------------------------------------
-- function setTestColosseumDeck
-- @breif 'data/colosseum_test_deck.txt'파일에 테스트용 상대방 덱 설정 기능
-------------------------------------
function ServerData_Colosseum:setTestColosseumDeck()
    local script = TABLE:loadJsonTable('colosseum_test_deck')
    
    local ret = script

    -- 상대방 유저 정보 설정
    self.m_vsUserInfo = ColosseumUserInfo()
    self.m_vsUserInfo:setRP(1000) -- 랭킹 포인트
    self.m_vsUserInfo:setTier('') -- 티어
    self.m_vsUserInfo:setNickname('perplelab') -- 닉네임
    self.m_vsUserInfo:setUid(100) -- UID

    self.m_vsUserInfo:setDragons(ret['vs_dragons'])
    self.m_vsUserInfo:setRunes(ret['vs_runes'])
    self.m_vsUserInfo:setDeckInfo(ret['vs_deck'])
end

-------------------------------------
-- function getLastWeekInfo
-- @breif 지난 주 콜로세움 정보 리턴
-------------------------------------
function ServerData_Colosseum:getLastWeekInfo()
    return self.m_lastWeekInfo
end

-------------------------------------
-- function getPlayerInfo
-- @breif 플레이어 유저의 데이터 리턴
-------------------------------------
function ServerData_Colosseum:getPlayerInfo()
    return self.m_playerUserInfo
end

-------------------------------------
-- function getVsUserInfo
-- @breif 콜로세움 상대방 유저의 데이터 리턴
-------------------------------------
function ServerData_Colosseum:getVsUserInfo()
    return self.m_vsUserInfo
end

-------------------------------------
-- function getWeekTimeText
-- @breif 주차의 남은 시간
-------------------------------------
function ServerData_Colosseum:getWeekTimeText()
    local server_time = Timer:getServerTime()
    local start_time = (self.m_startTime / 1000)
    local end_time = (self.m_endTime / 1000)

    -- 콜로세움 오픈 전
    if (start_time < server_time) then
        local showSeconds = true
        local time_text = datetime.makeTimeDesc((server_time - start_time), showSeconds)
        local text = Str('{1} 후 열림', time_text)
        return text
    -- 콜로세움 오픈 후
    else
        local showSeconds = true
        local time_text = datetime.makeTimeDesc((start_time - server_time), showSeconds)
        local text = Str('{1} 남음', time_text)
        return text
    end
end

-------------------------------------
-- function getWeekTimePercent
-- @breif 주차의 남은 시간
-------------------------------------
function ServerData_Colosseum:getWeekTimePercent()
    local server_time = Timer:getServerTime()
    local start_time = (self.m_startTime / 1000)
    local end_time = (self.m_endTime / 1000)

    -- 콜로세움 오픈 전
    if (start_time < server_time) then
        return 100
    -- 콜로세움 오픈 후
    else
        local duration = (end_time - start_time)
        local curr = (end_time - server_time)
        local percentage = math_floor((curr / duration) * 100)
        return percentage
    end
end

-------------------------------------
-- function getIsOpenColosseum
-- @breif 콜로세움 오픈 여부
-------------------------------------
function ServerData_Colosseum:getIsOpenColosseum()
    local server_time = Timer:getServerTime()
    local start_time = (self.m_startTime / 1000)
	
	return (start_time > server_time)
end