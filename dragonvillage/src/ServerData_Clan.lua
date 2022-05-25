-- g_clanData

-------------------------------------
-- class ServerData_Clan
-------------------------------------
ServerData_Clan = class({
        m_serverData = 'ServerData',
        m_bClanGuest = 'boolean', -- 클랜 미가입 상태 여부

        -- 유저의 클랜
        m_structClan = 'StructClan',
        m_myMemberType = 'string', -- 클랜에 소속된 경우 권한 ('master', 'manager', 'member')

        -- 클랜 창설 비용
        m_createPriceType = 'string',
        m_createPriceValue = 'number',

        m_needClanInfoRefresh = 'boolean',
        m_needClanSetting = 'boolean',

        -- 클랜 리스트(가입 신청 가능한)
        m_lClanList = 'list',

        -- 클랜 가입 신청 리스트
        m_lJoinRequestList = 'map',

        -- 클랜 가입 신청 유저 리스트 (받는 기준)
        m_lJoinRequestUserList = 'map',

        -- 출석 보상 정보
        m_attdRewardInfo = 'table',
        m_bAttdRewardNoti = 'bool',

        m_clanExitTimeStamp = 'timestamp',

        -- 클랜 게시판 정보 (StructClan에 포함시키지 않음)
        m_clanBoardInfo = 'table',

        m_cur_season_boss_attr = 'string',
    })

-- 클랜 필수 참여 카테고리 (서버에서는 string으로 저장함)
CLAN_NECESSARY_CATEGORY = {}
CLAN_NECESSARY_CATEGORY['attendance'] = 1
CLAN_NECESSARY_CATEGORY['clandungeon'] = 2
CLAN_NECESSARY_CATEGORY['ancient'] = 3
CLAN_NECESSARY_CATEGORY['clanwar'] = 4

-------------------------------------
-- function init
-------------------------------------
function ServerData_Clan:init(server_data)
    self.m_serverData = server_data
    self.m_bClanGuest = true

    self.m_structClan = nil

    -- 클랜 창설 비용
    self.m_createPriceType = 'gold'
    self.m_createPriceValue = 1500000

    self.m_needClanInfoRefresh = true
    self.m_needClanSetting = false

    self.m_clanBoardInfo = {}

    self.m_cur_season_boss_attr = 'earth' -- 서버에서 값이 없을 경우를 대비
end

-------------------------------------
-- function isClanGuest
-- @brief 클랜 미가입 상태 여부
-- @return boolean
-------------------------------------
function ServerData_Clan:isClanGuest()
    return self.m_bClanGuest
end

-------------------------------------
-- function update_clanInfo
-- @brief
-- @param auto_join boolean 추천 클랜 리스트에서 자동가입 여부 nil일 경우 서버에서 true로 처리
-------------------------------------
function ServerData_Clan:update_clanInfo(finish_cb, fail_cb, auto_join)
    return self:request_clanInfo(finish_cb, fail_cb, auto_join)
end

-------------------------------------
-- function getClanCreatePriceInfo
-- @brief 클랜 창설 비용 정보
-------------------------------------
function ServerData_Clan:getClanCreatePriceInfo()
    local price_type = self.m_createPriceType
    local price_value = self.m_createPriceValue
    return price_type, price_value
end

-------------------------------------
-- function setNeedClanInfoRefresh
-- @brief
-------------------------------------
function ServerData_Clan:setNeedClanInfoRefresh()
    self.m_needClanInfoRefresh = true
end

-------------------------------------
-- function isNeedClanInfoRefresh
-- @brief
-------------------------------------
function ServerData_Clan:isNeedClanInfoRefresh()
    return self.m_needClanInfoRefresh
end

-------------------------------------
-- function setNeedClanSetting
-- @brief
-------------------------------------
function ServerData_Clan:setNeedClanSetting()
    self.m_needClanSetting = true
end

-------------------------------------
-- function isNeedClanSetting
-- @brief
-------------------------------------
function ServerData_Clan:isNeedClanSetting()
    return self.m_needClanSetting
end

-------------------------------------
-- function applyClanInfo_Title
-- @brief
-------------------------------------
function ServerData_Clan:applyClanInfo_Title(ret)
	if (ret['clan']) then
		self:setClanStruct(ret['clan'])
	else
		return
	end
	
	if (ret['clan_members']) then
		self.m_structClan:setMembersData(ret['clan_members'])
	end
	if (ret['clan_buff']) then
		self.m_structClan:setClanBuffStruct(ret['clan_buff'])
	end
end

-------------------------------------
-- function request_clanInfo
-- @brief
-- @param auto_join boolean 추천 클랜 리스트에서 자동가입 여부 nil일 경우 서버에서 true로 처리
-------------------------------------
function ServerData_Clan:request_clanInfo(finish_cb, fail_cb, auto_join)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)

        local prev_need_clan_info_refresh = self.m_needClanInfoRefresh
        self.m_needClanInfoRefresh = false

        if ret['clan'] then
            self.m_structClan = StructClan(ret['clan'])
            self.m_structClan:setMembersData(ret['clan_members'])
            self.m_structClan:setClanNotice(ret['clan_notice'])
            self.m_structClan:setCurrAttd(ret['clan_attd'])
			self.m_structClan:setClanBuffStruct(ret['clan_buff'])
            self.m_bClanGuest = false
        else
            self.m_structClan = nil
            self.m_bClanGuest = true
            self:response_clanGuestInfo(ret)
        end

        -- 클랜 게시판 정보
        if ret['clan_board'] then
            self.m_clanBoardInfo = {}
            self:makeBoardData(ret['clan_board'])
        end

        -- 클랜던전 오픈시간 정보 (락타임일때 필요함)
        if ret['dungeon_info'] then
            if ret['dungeon_info']['open'] then
                g_clanRaidData.m_bOpen = ret['dungeon_info']['open']
            end

            if ret['dungeon_info']['start_time'] then
                g_clanRaidData.m_startTime = ret['dungeon_info']['start_time']
            end

            if ret['dungeon_info']['endtime'] then
                g_clanRaidData.m_endTime = ret['dungeon_info']['endtime']
            end

            if ret['dungeon_info']['attr'] then
                self.m_cur_season_boss_attr = ret['dungeon_info']['attr']
            end
        end

        -- 클랜에 소속된 경우 권한 ('master', 'manager', 'member')
        self.m_myMemberType = ret['clan_auth']

        -- 클랜 창설 비용
        self.m_createPriceType = (ret['create_price_type'] or self.m_createPriceType)
        self.m_createPriceValue = (ret['create_price_value'] or self.m_createPriceValue)

        do -- 클랜 가입 신청 리스트 초기화
            self.m_lJoinRequestList = {}

            if ret['join_clan_list'] then
                for i,v in pairs(ret['join_clan_list']) do
                    self:addRequestedJoin(v)
                end
            end
        end

        do -- 클랜 마스터, 부마스터일 경우 들어온 요청 유저 리스트
            self.m_lJoinRequestUserList = {}

            if ret['join_user_list'] then
                for i,v in pairs(ret['join_user_list']) do
                    self:addRequestedJoinUser(v)
                end
            end
        end

        do -- 던전 정보 (로비에서 클랜던전 버튼에 보스 상태 표시 추가됨)
            if ret['dungeon'] then
                g_clanRaidData.m_structClanRaid = StructClanRaid(ret['dungeon'])
            end
        end

        -- 출석 보상 정보
		-- 보상 UI 출력 부분 주석 확인해주세요
        self.m_attdRewardInfo = ret['reward_info']
		if (self.m_attdRewardInfo) then
			self.m_attdRewardInfo['clan_exp'] = ret['clan_exp'] or 0
		end

        -- 재가입 제한 시간
        self.m_clanExitTimeStamp = ret['clan_exit']

        if finish_cb then
            finish_cb(ret)
        end

        -- 클랜 채팅 채널 연결 확인 (창설, 가입, 해체, 탈퇴 후 모두 info를 호출하게 됨)
        ChatManagerClan:getInstance():checkClanChannel()

        -- 채팅 서버에 변경사항 적용
        if prev_need_clan_info_refresh and g_chatClientSocket then
            g_lobbyChangeMgr:globalUpdatePlayerUserInfo()
        end
    end

    -- 응답 상태 처리 함수
    local t_error = {
        [-1103] = Str('클랜이 존재하지 않습니다.'), -- 클랜 없음
    }
    local response_status_cb = MakeResponseCB(t_error)

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/clans/info')
    ui_network:setParam('uid', uid)
    ui_network:setParam('auto_join', auto_join) -- nil일 경우 true로 처리
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function response_clanGuestInfo
-- @brief
-------------------------------------
function ServerData_Clan:response_clanGuestInfo(ret)
    -- 가입 신청이 가능한 클랜 리스트
    self.m_lClanList = {}
    for i,v in pairs(ret['clans']) do
        local struct_clan = StructClan(v)
        table.insert(self.m_lClanList, struct_clan)
    end
end

-------------------------------------
-- function getNeedCategryNameWithIdx
-------------------------------------
function ServerData_Clan:getNeedCategryNameWithIdx(idx)
    for name, v in pairs(CLAN_NECESSARY_CATEGORY) do
        if (idx == v) then
            return name
        end
    end

    return nil
end

-------------------------------------
-- function getNeedCategryIdxWithName
-- @return number or nil (경우에 따라 nil이 리턴될 수 있다)
-------------------------------------
function ServerData_Clan:getNeedCategryIdxWithName(name)
    for _name, v in pairs(CLAN_NECESSARY_CATEGORY) do
        if (_name == name) then
            return v
        end
    end

    return nil
end

-------------------------------------
-- function request_clanCreate
-- @brief
-------------------------------------
function ServerData_Clan:request_clanCreate(finish_cb, fail_cb, name, join, intro, flag)
    if (not self:checkClanExitTime()) then
        return
    end

    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)

        self:setNeedClanSetting()
        self:setNeedClanInfoRefresh()
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 응답 상태 처리 함수
    local t_error = {
        [-3003] = Str('클랜을 창설 할 수 없습니다.'), -- 이미 유저의 클랜이 있는 상태
        [-3027] = Str('클랜을 창설 할 수 없습니다.'), -- 클랜명 중복
        [-1190] = Str('클랜을 창설 할 수 없습니다.'), -- 테이블이 없는 경우?
        [-1224] = Str('클랜을 창설 할 수 없습니다.'), -- 레벨 부족
        [-9999] = Str('클랜을 창설 할 수 없습니다.'), -- unknown
    }
    local response_status_cb = MakeResponseCB(t_error)

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/clans/create')
    ui_network:setParam('uid', uid)
    ui_network:setParam('name', name)
    ui_network:setParam('join', join)
    ui_network:setParam('intro', intro)
    ui_network:setParam('flag', flag)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_clanDestroy
-- @brief
-------------------------------------
function ServerData_Clan:request_clanDestroy(finish_cb, fail_cb)
    if (not self.m_structClan) then
        return
    end

    -- 유저 ID
    local uid = g_userData:get('uid')

    local clan_object_id = self.m_structClan:getClanObjectID()

    -- 성공 콜백
    local function success_cb(ret)
        self:setNeedClanInfoRefresh()
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 응답 상태 처리 함수
    local t_error = {
        [-2503] = Str('클랜 해체는 클랜원이 1명이어야 가능합니다.'),
        [-1103] = Str('클랜이 존재하지 않습니다.'),
        [-1301] = Str('클랜 해체는 마스터만이 가능합니다.'), -- 마스터가 아닌 경우
    }
    local response_status_cb = MakeResponseCB(t_error)

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/clans/destroy')
    ui_network:setParam('uid', uid)
    ui_network:setParam('clan_id', clan_object_id)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_clanExit
-- @brief
-------------------------------------
function ServerData_Clan:request_clanExit(finish_cb, fail_cb)
    if (not self.m_structClan) then
        return
    end

    -- 유저 ID
    local uid = g_userData:get('uid')

    local clan_object_id = self.m_structClan:getClanObjectID()

    -- 성공 콜백
    local function success_cb(ret)
        self:setNeedClanInfoRefresh()
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 응답 상태 처리 함수
    local t_error = {
        [-1303] = Str('잘못된 요청입니다.'), -- 자신의 클랜이 아닌 클랜을 탈퇴 시도
        [-2303] = Str('탈퇴가 불가능합니다.') -- 탈퇴가 불가능한 유저
    }
    local response_status_cb = MakeResponseCB(t_error)

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/clans/exit')
    ui_network:setParam('uid', uid)
    ui_network:setParam('clan_id', clan_object_id)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_clanSetting
-- @brief 클랜 관리(설정)
-------------------------------------
function ServerData_Clan:request_clanSetting(finish_cb, fail_cb, intro, notice, join, mark, joinlv, l_category)
    if (not self.m_structClan) then
        return
    end

    -- 유저 ID
    local uid = g_userData:get('uid')

    local clan_object_id = self.m_structClan:getClanObjectID()

    -- 성공 콜백
    local function success_cb(ret)
        if ret['clan'] then
            self.m_structClan:applySetting(ret['clan'])
        end

        if (ret['clan_notice']) then
            self.m_structClan:setClanNotice(ret['clan_notice'])
        end

        if finish_cb then
            finish_cb(ret)
        end

        -- 채팅 서버에 변경사항 적용
        if g_chatClientSocket then
            g_lobbyChangeMgr:globalUpdatePlayerUserInfo()
        end
    end

    -- 응답 상태 처리 함수
    local t_error = {
        [-1103] = Str('클랜이 존재하지 않습니다.'), -- 클랜 없음
        [-1285] = Str('권한이 없습니다.'), -- 권한이 없음
    }
    local response_status_cb = MakeResponseCB(t_error)
    
    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/clans/set')
    ui_network:setParam('uid', uid)
    ui_network:setParam('clan_id', clan_object_id)

    if (intro ~= nil) then
        ui_network:setParam('intro', intro)
    end

    if (notice ~= nil) then
        ui_network:setParam('notice', notice)
    end

    if (join ~= nil) then
        ui_network:setParam('join', join)
    end

    if (mark ~= nil) then
        ui_network:setParam('mark', mark)
    end

    if (joinlv ~= nil) then
        ui_network:setParam('joinlv', joinlv)
    end

    if (l_category ~= nil) then
        ui_network:setParam('category', l_category)
    end
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_join
-- @brief
-------------------------------------
function ServerData_Clan:request_join(finish_cb, fail_cb, clan_object_id)
    if (self.m_structClan) then
        local msg = Str('이미 가입된 클랜이 있습니다.')
        UIManager:toastNotificationRed(msg)
        return
    end

    if (not self:checkClanExitTime()) then
        return
    end

    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)

        -- 즉시 가입이 된 경우
        if ret['clan'] then
            -- 클랜 정보를 다시 받도록 설정
            self:setNeedClanInfoRefresh()
        end

        -- 클랜 가입 신청 리스트가 넘어온 경우
        if ret['join_clan_list'] then
            self.m_lJoinRequestList = {}
            for i,v in pairs(ret['join_clan_list']) do
                self:addRequestedJoin(v)
            end
        end

        if finish_cb then
            finish_cb(ret)
        end
    end
    
    -- 응답 상태 처리 함수
    local t_error = {
        [-1401] = Str('더 이상 가입할 수 없는 클랜입니다.'), -- 클랜원이 가득 찬 경우
        [-1103] = Str('더 이상 가입할 수 없는 클랜입니다.'), -- 클랜이 현시점에 존재하지 않는 경우
        [-3603] = Str('이미 클랜에 가입되어 있습니다.'), -- 이미 가입중인 클랜이 있는 경우
    }
    local response_status_cb = MakeResponseCB(t_error)

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/clans/join')
    ui_network:setParam('uid', uid)
    ui_network:setParam('clan_id', clan_object_id)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_joinCancel
-- @brief
-------------------------------------
function ServerData_Clan:request_joinCancel(finish_cb, fail_cb, clan_object_id)

    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)

        -- 클랜 가입 신청 리스트가 넘어온 경우
        if ret['join_clan_list'] then
            self.m_lJoinRequestList = {}
            for i,v in pairs(ret['join_clan_list']) do
                self:addRequestedJoin(v)
            end
        end

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/clans/cancel_join')
    ui_network:setParam('uid', uid)
    ui_network:setParam('clan_id', clan_object_id)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function getClanStruct
-- @brief
-------------------------------------
function ServerData_Clan:getClanStruct()
    return self.m_structClan
end

-------------------------------------
-- function setClanStruct
-- @brief
-------------------------------------
function ServerData_Clan:setClanStruct(t_clan_data)
    if (not t_clan_data) then
        return
    end

    self.m_structClan = StructClan(t_clan_data)
    self.m_bClanGuest = false
end

-------------------------------------
-- function setClanBuffStruct
-- @brief
-------------------------------------
function ServerData_Clan:setClanBuffStruct(t_clan_buff)
	self.m_structClan:setClanBuffStruct(t_clan_buff)
end

-------------------------------------
-- function requestClanInfoDetailPopup
-- @brief
-------------------------------------
function ServerData_Clan:requestClanInfoDetailPopup(clan_object_id, close_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        local struct_clan = StructClan(ret['clan'])
        struct_clan:setMembersData(ret['clan_members'])
		struct_clan:setClanBuffStruct(ret['clan_buff'])
        local ui = UI_ClanInfoDetailPopup(struct_clan)

        if close_cb then
            ui:setCloseCB(close_cb)
        end
    end

    -- 응답 상태 처리 함수
    local t_error = {
        [-1103] = Str('클랜이 존재하지 않습니다.'), -- 클랜 없음
    }
    local response_status_cb = MakeResponseCB(t_error)

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/clans/detail')
    ui_network:setParam('uid', uid)
    ui_network:setParam('clan_id', clan_object_id)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function requestClanInfoDetailPopup_byClanName
-- @brief
-------------------------------------
function ServerData_Clan:requestClanInfoDetailPopup_byClanName(clan_name)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        local struct_clan = StructClan(ret['clan'])
        struct_clan:setMembersData(ret['clan_members'])
		struct_clan:setClanBuffStruct(ret['clan_buff'])
        UI_ClanInfoDetailPopup(struct_clan)
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/clans/detail')
    ui_network:setParam('uid', uid)
    ui_network:setParam('clan_name', clan_name)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end


-------------------------------------
-- function getMyMemberType
-- @brief
-------------------------------------
function ServerData_Clan:getMyMemberType()
    return self.m_myMemberType
end

-------------------------------------
-- function addRequestedJoin
-- @brief
-------------------------------------
function ServerData_Clan:addRequestedJoin(t_clan_data)
    if (not self.m_lJoinRequestList) then
        self.m_lJoinRequestList = {}
    end

    local struct_clan = StructClan(t_clan_data)
    local clan_object_id = struct_clan:getClanObjectID()
    self.m_lJoinRequestList[clan_object_id] = struct_clan
end

-------------------------------------
-- function removeRequestedJoin
-- @brief
-------------------------------------
function ServerData_Clan:removeRequestedJoin(clan_object_id)
    if (not self.m_lJoinRequestList) then
        return
    end

    self.m_lJoinRequestList[clan_object_id] = nil
end

-------------------------------------
-- function isRequestedJoin
-- @brief
-------------------------------------
function ServerData_Clan:isRequestedJoin(clan_object_id)
    if (not self.m_lJoinRequestList) then
        return false
    end

    if self.m_lJoinRequestList[clan_object_id] then
        return true
    else
        return false
    end
end

-------------------------------------
-- function addRequestedJoinUser
-- @brief 클랜 가입 요청을 한 유저 리스트 (마스터, 부마스터가 가입 승인을 해줄 수 있는 대상)
-------------------------------------
function ServerData_Clan:addRequestedJoinUser(t_user_data)
    if (not self.m_lJoinRequestUserList) then
        self.m_lJoinRequestUserList = {}
    end

    local user_info = StructUserInfoClan:create(t_user_data)
    local uid = user_info:getUid()
    self.m_lJoinRequestUserList[uid] = user_info
end

-------------------------------------
-- function removeRequestedJoinUser
-- @brief 클랜 가입 요청을 한 유저 리스트 (마스터, 부마스터가 가입 승인을 해줄 수 있는 대상)
-------------------------------------
function ServerData_Clan:removeRequestedJoinUser(uid)
    if (not self.m_lJoinRequestUserList) then
        return
    end

    self.m_lJoinRequestUserList[uid] = nil
end

-------------------------------------
-- function getRequestedJoinUserCnt
-- @brief 클랜 가입 요청을 한 유저 리스트 (마스터, 부마스터가 가입 승인을 해줄 수 있는 대상)
-------------------------------------
function ServerData_Clan:getRequestedJoinUserCnt()
    if (self.m_lJoinRequestUserList) then
        return table.count(self.m_lJoinRequestUserList)
    end

    return 0
end

-------------------------------------
-- function isCanJoinRequest
-- @brief clan_object_id클랜에 가입 신청이 가능한 상태인지 리턴
-------------------------------------
function ServerData_Clan:isCanJoinRequest(struct_clan)
    
    -- 클랜 컨텐츠가 열려있는 상태인지
    local is_lock = g_contentLockData:isContentLock('clan')
    if (is_lock) then
        return false
    end

    -- 이미 클랜에 소속되어 있는 경우 x
    if self.m_structClan then
        return false
    end

    -- 이미 가입 신청을 요청한 클랜일 경우 x
    local clan_object_id = struct_clan:getClanObjectID()
    if self:isRequestedJoin(clan_object_id) then
        return false
    end
    
    local user_lv = g_userData:get('lv')
    --[[
    -- 유저가 클랜 가입 레벨이 안된다면?
    
    if (user_lv < 15) then
        return false
    end
    --]]

    -- 유저 가입 조건도 체크
    local join_lv = struct_clan:getJoinLv()
    if (user_lv < join_lv) then
        return false
    end
    
    return true
end

-------------------------------------
-- function request_accept
-- @brief 가입 요청 승인 (마스터, 부마스터 권한)
-------------------------------------
function ServerData_Clan:request_accept(finish_cb, fail_cb, req_uid)
    if (not self.m_structClan) then
        return
    end

    -- 멤버 최대치 이상일 경우
    if (self.m_structClan:getClanMaxMember() <= self.m_structClan:getMemberCnt()) then
        UIManager:toastNotificationRed(Str('클랜원 목록이 가득 찼습니다.'))
        return
    end

    -- 유저 ID
    local uid = g_userData:get('uid')
    local clan_object_id = self.m_structClan:getClanObjectID()

    -- 성공 콜백
    local function success_cb(ret)
        self:setNeedClanInfoRefresh()

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 응답 상태 처리 함수
    local t_error = {
        [-1103] = Str('클랜이 존재하지 않습니다.'), -- 클랜 없음
        [-1285] = Str('권한이 없습니다.'), -- 권한이 없음
        [-1401] = Str('더이상 클랜원을 늘릴 수 없습니다.'), -- 유저 수 꽉 참
        [-3603] = Str('이미 클랜에 가입된 유저입니다.'),
        [-1186] = Str('유저가 클랜 가입 요청을 취소했습니다.'), -- not exist request
    }
    local response_status_cb = MakeResponseCB(t_error)

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/clans/accept')
    ui_network:setParam('uid', uid)
    ui_network:setParam('clan_id', clan_object_id)
    ui_network:setParam('req_uid', req_uid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_reject
-- @brief 가입 요청 거절 (마스터, 부마스터 권한)
-------------------------------------
function ServerData_Clan:request_reject(finish_cb, fail_cb, req_uid)
    if (not self.m_structClan) then
        return
    end

    -- 유저 ID
    local uid = g_userData:get('uid')
    local clan_object_id = self.m_structClan:getClanObjectID()

    -- 성공 콜백
    local function success_cb(ret)
        self:setNeedClanInfoRefresh()

        if finish_cb then
            finish_cb(ret)
        end
    end
    
    -- 응답 상태 처리 함수
    local t_error = {
        [-1103] = Str('클랜이 존재하지 않습니다.'), -- 클랜 없음
        [-1285] = Str('권한이 없습니다.'), -- 권한이 없음
    }
    local response_status_cb = MakeResponseCB(t_error)

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/clans/reject')
    ui_network:setParam('uid', uid)
    ui_network:setParam('clan_id', clan_object_id)
    ui_network:setParam('req_uid', req_uid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function getAttdRewardInfo
-- @brief 출석 보상 정보 리턴
-------------------------------------
function ServerData_Clan:getAttdRewardInfo(clear)
    local reward_info = self.m_attdRewardInfo

    if clear then
        self.m_attdRewardInfo = nil
        self.m_bAttdRewardNoti = false
        g_highlightData:setDirty(true)
    end

    return reward_info
end


-------------------------------------
-- function request_kick
-- @brief 클랜원 추방
-------------------------------------
function ServerData_Clan:request_kick(finish_cb, fail_cb, member_uid)
    if (not self.m_structClan) then
        return
    end

    -- 유저 ID
    local uid = g_userData:get('uid')
    local clan_object_id = self.m_structClan:getClanObjectID()

    -- 성공 콜백
    local function success_cb(ret)
        self:setNeedClanInfoRefresh()

        -- 맴버 제거
        self.m_structClan:removeMember(member_uid)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 응답 상태 처리 함수
    local t_error = {
        [-1303] = Str('잘못된 요청입니다.'), -- 클랜원이 아닌 유저 추방 시도
        [-2303] = Str('탈퇴가 불가능합니다.'), -- 탈퇴가 불가능한 유저
        [-1285] = Str('권한이 없습니다.'), -- 권한이 없음
    }
    local response_status_cb = MakeResponseCB(t_error)

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/clans/kick')
    ui_network:setParam('uid', uid)
    ui_network:setParam('clan_id', clan_object_id)
    ui_network:setParam('member_uid', member_uid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end


-------------------------------------
-- function checkClanExitTime
-- @brief
-------------------------------------
function ServerData_Clan:checkClanExitTime()
    if (not self.m_clanExitTimeStamp) then
        return true
    end

    local server_time = ServerTime:getInstance():getCurrentTimestampSeconds()

    -- 제한 시간을 millisecond에서 second로 변경
    local possible_time = (self.m_clanExitTimeStamp / 1000)

    if (possible_time <= server_time) then
        return true
    else
        local sec = (possible_time - server_time)
        local showSeconds = true
        local time_desc = datetime.makeTimeDesc(sec, showSeconds)
        local msg = Str('클랜 탈퇴로 인해 클랜 활동이 제한되었습니다.')
        local sub_msg = Str('({1} 후 제한 해제)', time_desc)
        MakeSimplePopup2(POPUP_TYPE.OK, msg, sub_msg)
        return false
    end
end

-------------------------------------
-- function makeBoardData
-------------------------------------
function ServerData_Clan:makeBoardData(l_list)
    for i, v in ipairs(l_list) do
        local board_no = v['no']
        self.m_clanBoardInfo[board_no] = v
    end
end

-------------------------------------
-- function request_setAuthority
-- @brief 클랜원 권한 설정
-------------------------------------
function ServerData_Clan:request_setAuthority(finish_cb, fail_cb, member_uid, auth)
    if (not self.m_structClan) then
        return
    end

    if (auth == 'manager') then
        local manager_cnt = self.m_structClan:managerCntCalc()
        if (3 <= manager_cnt) then
            UIManager:toastNotificationRed(Str('부마스터는 3명까지만 지정 가능합니다.'))
            return
        end
    end

    -- 유저 ID
    local uid = g_userData:get('uid')
    local clan_object_id = self.m_structClan:getClanObjectID()

    -- 성공 콜백
    local function success_cb(ret)

        if (auth == 'master') then
            self:setNeedClanInfoRefresh()
        end

        -- 클랜 정보 갱신
        if ret['clan'] then
            self.m_structClan:applySetting(ret['clan'])
        end

        -- 맴버 정보 갱신
        if ret['clan_members'] then
            self.m_structClan:setMembersData(ret['clan_members'])
        end

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 응답 상태 처리 함수
    local t_error = {
        [-1103] = Str('클랜이 존재하지 않습니다.'),
        [-1285] = Str('권한이 없습니다.'),
    }
    local response_status_cb = MakeResponseCB(t_error)

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/clans/set_authority')
    ui_network:setParam('uid', uid)
    ui_network:setParam('clan_id', clan_object_id)
    ui_network:setParam('member_uid', member_uid)
    ui_network:setParam('auth', auth)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_writeBoard
-- @brief 클랜 게시판 작성
-------------------------------------
function ServerData_Clan:request_writeBoard(finish_cb, fail_cb, review_str)
    if (not self.m_structClan) then
        return
    end

    -- 파라미터
    local uid = g_userData:get('uid')
    local clan_object_id = self.m_structClan:getClanObjectID()
	local review_str = review_str

    -- 성공 콜백
    local function success_cb(ret)
        if ret['clan'] then
            self.m_structClan:applySetting(ret['clan'])
        end

        if ret['clan_board'] then
            self:makeBoardData(ret['clan_board'])
        end

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 응답 상태 처리 함수
    local t_error = {
        [-1103] = Str('클랜이 존재하지 않습니다.'), -- 클랜 없음
        [-1285] = Str('권한이 없습니다.'), -- 권한이 없음
    }
    local response_status_cb = MakeResponseCB(t_error)
    
    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/clans/board_write')
    ui_network:setParam('uid', uid)
    ui_network:setParam('clan_id', clan_object_id)
    ui_network:setParam('text', review_str)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_deleteBoard
-- @brief 클랜 게시판 삭제
-------------------------------------
function ServerData_Clan:request_deleteBoard(finish_cb, fail_cb, board_id)
    if (not self.m_structClan) then
        return
    end

    -- 파라미터
    local uid = g_userData:get('uid')
    local clan_object_id = self.m_structClan:getClanObjectID()
	local review_str = review_str

    -- 성공 콜백
    local function success_cb(ret)
        if ret['clan'] then
            self.m_structClan:applySetting(ret['clan'])
        end
        
        for k, v in pairs(self.m_clanBoardInfo) do
            if (v['id'] == board_id) then
                self.m_clanBoardInfo[k] = nil
            end
        end

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 응답 상태 처리 함수
    local t_error = {
        [-1103] = Str('클랜이 존재하지 않습니다.'), -- 클랜 없음
        [-1285] = Str('권한이 없습니다.'), -- 권한이 없음
    }
    local response_status_cb = MakeResponseCB(t_error)
    
    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/clans/board_delete')
    ui_network:setParam('uid', uid)
    ui_network:setParam('clan_id', clan_object_id)
    ui_network:setParam('board_id', board_id)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setResponseStatusCB(response_status_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_boardList
-------------------------------------
function ServerData_Clan:request_boardList(offset, cb_func)
    -- 파라미터
    local uid = g_userData:get('uid')
    local clan_object_id = self.m_structClan:getClanObjectID()
	local offset = offset

    -- 콜백 함수
    local function success_cb(ret)
        if ret['clan_board'] then
            self:makeBoardData(ret['clan_board'])
        end

		-- 콜백 실행
		if (cb_func) then
			cb_func(ret['clan_board'])
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/clans/board_list')
    ui_network:setParam('uid', uid)
	ui_network:setParam('offset', offset)
    ui_network:setParam('clan_id', clan_object_id)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function isHighlightClan
-- @brief
-------------------------------------
function ServerData_Clan:isHighlightClan()
    if self.m_bAttdRewardNoti then
        return true
    end

    return false
end

-------------------------------------
-- function getCurSeasonBossAttr
-- @brief
-------------------------------------
function ServerData_Clan:getCurSeasonBossAttr()
    local struct_clan_raid = g_clanRaidData:getClanRaidStruct()
    
    -- 저장된 속성이 있다면 그 속성을 사용
    if (struct_clan_raid) then
        if (struct_clan_raid['attr']) then
            return struct_clan_raid['attr']
        end
    end
    
    return self.m_cur_season_boss_attr
end

-------------------------------------
-- function getMyClanObjectID
-- @brief 내 클랜의 고유 ID
-- @return string object id
-------------------------------------
function ServerData_Clan:getMyClanObjectID()
    if (self.m_structClan == nil) then
        return nil
    end

    local clan_object_id = self.m_structClan:getClanObjectID()
    return clan_object_id
end