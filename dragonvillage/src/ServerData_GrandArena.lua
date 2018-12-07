-------------------------------------
-- class ServerData_GrandArena
-- @instance g_grandArena
-------------------------------------
ServerData_GrandArena = class({
        m_serverData = 'ServerData',

        m_matchUserInfo = 'StructUserInfoArena',
		m_playerUserInfo = 'StructUserInfoArena',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_GrandArena:init(server_data)
end


-------------------------------------
-- function isActive_grandArena
-- @brief 그랜드 콜로세움 이벤트가 진행 중인지 여부 true or false
-------------------------------------
function ServerData_GrandArena:isActive_grandArena()
    return true
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
        end

        return false
    end

    -- 서버에서 테이블 정보를 받아옴
        --[[
    local include_tables = false
    if (self.m_challengeRewardTable == nil) or (self.m_challengeManageTable == nil) then
        include_tables = true
    end
    --]]
    
    -- 시즌 보상을 받을지 여부 (타이틀 화면에서 정보 요청을 위해 호출될때는 제외하기 위함)
    local include_reward = (include_reward or false)

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/game/grand_arena/info')
    ui_network:setParam('uid', uid)
    ui_network:setParam('include_infos', include_infos)
    --ui_network:setParam('include_tables', include_tables)
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
    local time = g_hotTimeData:getEventRemainTime('event_grand_arena') or 0

    local str = ''
    if (not self:isActive_grandArena()) then
        if (time <= 0) then
            str = Str('오픈시간이 아닙니다.')
        end

    elseif (0 < time) then
        str = Str('{1} 남음', datetime.makeTimeDesc(time, true)) -- param : sec, showSeconds, firstOnly, timeOnly

    else
        str = Str('종료되었습니다.')
    end

    return str
end