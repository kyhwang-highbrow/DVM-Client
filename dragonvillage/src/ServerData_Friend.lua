-------------------------------------
-- class ServerData_Friend
-------------------------------------
ServerData_Friend = class({
        m_serverData = 'ServerData',

        m_friendSystemStatus = '',

        m_lRecommendUserList = 'list',
        m_lFriendUserList = 'list',
        m_lFriendInviteList = 'list',

        m_mInvitedUerList = 'map', -- 클라이언트가 켜져있는 동안 친구초대를 한 유저의 uid 저장
        m_mSentFpUserList = 'map', -- 오늘 우정포인트를 보낸 유저 리스트

        m_myDragonSupportRequestInfo = '', -- 플레이어의 드래곤 지원 요청 정보

        -- 선택된 공유 친구 데이터
        m_selectedShareFriendData = '',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Friend:init(server_data)
    self.m_serverData = server_data
    self.m_mInvitedUerList = {}
    self.m_mSentFpUserList = {}
    self.m_lRecommendUserList = {}
end

-------------------------------------
-- function request_recommend
-- @brief 친구 추천 유저 리스트 서버에 요청
-------------------------------------
function ServerData_Friend:request_recommend(finish_cb, force)
    if self.m_lRecommendUserList and (not force) then
        if finish_cb then
            finish_cb()
        end
        return
    end

    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        self.m_lRecommendUserList = {}

        for i,v in pairs(ret['users_list']) do
            local uid = v['uid']
            if (not self.m_mInvitedUerList[uid]) then
                self.m_lRecommendUserList[uid] = v
            end
        end
        
        if finish_cb then
            finish_cb()
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/socials/recommend')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function getRecommendUserList
-- @brief 친구 추천 유저 리스트
-------------------------------------
function ServerData_Friend:getRecommendUserList()
    return self.m_lRecommendUserList
end

-------------------------------------
-- function request_invite
-- @brief 친구 초대
-------------------------------------
function ServerData_Friend:request_invite(friend_uid, finish_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        self.m_mInvitedUerList[friend_uid] = true
        self.m_lRecommendUserList[friend_uid] = nil

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/socials/invite')
    ui_network:setParam('uid', uid)
    ui_network:setParam('friends', friend_uid)
    ui_network:setParam('type', 1) -- 1친구, 2베스트 프렌드, 3소울메이트
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_find
-- @brief 친구 검색
-------------------------------------
function ServerData_Friend:request_find(friend_nick, finish_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/socials/find')
    ui_network:setParam('uid', uid)
    ui_network:setParam('nick', friend_nick)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_friendList
-- @brief 친구 리스트 받아옴
-------------------------------------
function ServerData_Friend:request_friendList(finish_cb, force)
    if self.m_lFriendUserList and (not force) then
        if finish_cb then
            finish_cb()
        end
        return
    end

    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        self:response_friendCommon(ret)

        self.m_lFriendUserList = {}
        for i,v in pairs(ret['friends_list']) do
            local uid = v['uid']
            self.m_lFriendUserList[uid] = v
        end

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/socials/friend_list')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function getFriendInfo
-- @brief 친구 데이터를 받아옴
-------------------------------------
function ServerData_Friend:getFriendInfo(friend_uid)
    return self.m_lFriendUserList[friend_uid]
end

-------------------------------------
-- function getFriendList
-- @brief 친구 리스트 받아옴
-------------------------------------
function ServerData_Friend:getFriendList()

    -- 친구 드래곤 사용 시간 값 갱신
    self:updateFriendUserList_time()

    return self.m_lFriendUserList
end

-------------------------------------
-- function getFriendCount
-- @brief 친구 갯수 받아옴
-------------------------------------
function ServerData_Friend:getFriendCount(type)
    type = type or 'all'
    local count = 0

    for i,v in pairs(self.m_lFriendUserList) do
        count = (count + 1)
    end

    return count
end

-------------------------------------
-- function setSelectedShareFriendData
-- @brief
-------------------------------------
function ServerData_Friend:setSelectedShareFriendData(t_friend_info)
    self.m_selectedShareFriendData = t_friend_info

    if (self.m_selectedShareFriendData) then
        local t_dragon_data = self.m_selectedShareFriendData['leader']
        g_friendBuff:setParticipationFriendDragon(t_dragon_data)

        for _, t_rune_data in pairs(self.m_selectedShareFriendData['runes']) do
            t_rune_data['information'] = g_runesData:makeRuneInfomation(t_rune_data)
        end
    end
end

-------------------------------------
-- function getSelectedShareFriendData
-- @brief
-------------------------------------
function ServerData_Friend:getSelectedShareFriendData()
    return self.m_selectedShareFriendData
end

-------------------------------------
-- function getParticipationFriendDragon
-- @brief
-------------------------------------
function ServerData_Friend:getParticipationFriendDragon()
    local t_friend_info = self.m_selectedShareFriendData
    
    if (not t_friend_info) then
        return nil
    end

    self.m_selectedShareFriendData = nil

    return t_friend_info['leader'], t_friend_info['runes']
end

-------------------------------------
-- function makeFriendDragonStatusCalculator
-- @brief
-------------------------------------
function ServerData_Friend:makeFriendDragonStatusCalculator(t_dragon_data, l_runes_data)
    -- 드래곤 룬 정보
    local l_runes = t_dragon_data['runes']
    local l_rune_obj_map = {}
    local l_runes_for_set = {}
    for _, roid in pairs(l_runes) do

        local t_rune_data
        
        for _, v in pairs(l_runes_data) do
            if (v['id'] == roid) then
                t_rune_data = v
                break
            end
        end

        if (t_rune_data) then
            l_rune_obj_map[roid] = t_rune_data
            table.insert(l_runes_for_set, t_rune_data)
        end
    end

    -- @delete_rune
    --[[
    -- 룬 세트 효과 지정
    t_dragon_data['rune_set'] = g_runesData:makeRuneSetData(l_runes_for_set[1], l_runes_for_set[2], l_runes_for_set[3])

    -- 룬은 친밀도, 수련과 달리 Rune Object가 별도로 존재하여
    -- 외부의 함수를 통해 룬 보너스 리스트를 얻어옴
    local l_rune_bonus = ServerData_Dragons:makeRuneBonusList(t_dragon_data, l_rune_obj_map)
    --]]
    local l_rune_bonus = {}

    local status_calc = MakeDragonStatusCalculator_fromDragonDataTable(t_dragon_data, l_rune_bonus)
end

-------------------------------------
-- function request_inviteList
-- @brief 친구 요청 리스트
-------------------------------------
function ServerData_Friend:request_inviteList(finish_cb, force)
    if self.m_lFriendInviteList and (not force) then
        if finish_cb then
            finish_cb()
        end
        return
    end

    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        self.m_lFriendInviteList = {}

        for i,v in ipairs(ret['invites_list']) do
            local uid = v['uid']
            self.m_lFriendInviteList[uid] = v
        end

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/socials/invite_list')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function getFriendInviteList
-- @brief 친구 요청 리스트
-------------------------------------
function ServerData_Friend:getFriendInviteList()
    return self.m_lFriendInviteList
end

-------------------------------------
-- function request_inviteAccept
-- @brief 친구 요청 수락
-------------------------------------
function ServerData_Friend:request_inviteAccept(friend_uid, finish_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        
        self.m_lFriendInviteList[friend_uid] = nil

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/socials/invite_accept')
    ui_network:setParam('uid', uid)
    ui_network:setParam('friends', friend_uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_inviteReject
-- @brief 친구 요청 거절
-------------------------------------
function ServerData_Friend:request_inviteReject(friend_uid, finish_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        
        self.m_lFriendInviteList[friend_uid] = nil

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/socials/invite_reject')
    ui_network:setParam('uid', uid)
    ui_network:setParam('friends', friend_uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function updateFriendUserList_time
-- @brief 친구 드래곤 시간 관련 업데이트
-------------------------------------
function ServerData_Friend:updateFriendUserList_time()
    for i, v in pairs(self.m_lFriendUserList) do
        local t_friend_info = v

        -- 친구 유저 마지막 활동 시간
        self:updateFriendUser_activeTime(t_friend_info)

        -- 친구 드래곤 사용 시간
        self:updateFriendUser_usedTime(t_friend_info)
    end
end

-------------------------------------
-- function updateFriendUser_usedTime
-- @brief 친구 드래곤 사용 시간 업데이트
-- t_friend_info['cool_time'] 친구 드래곤을 사용 가능한 시점 (타임스템프)
-------------------------------------
function ServerData_Friend:updateFriendUser_usedTime(t_friend_info)
    local server_time = Timer:getServerTime()

    -- 소울메이트가 접속 중이면 사용 가능
    if (t_friend_info['friendtype'] == 3) then
        if (t_friend_info['is_online'] == true) then
            t_friend_info['enable_use'] = true
        else
            t_friend_info['enable_use'] = false
        end        
        return
    end

    -- 쿨타임 체크 후 사용 가능 여부표시
    local cool_time = (t_friend_info['cool_time'] / 1000)
    if (cool_time == 0) or (cool_time <= server_time) then
        t_friend_info['enable_use'] = true
    else
        t_friend_info['enable_use'] = false
    end
end

-------------------------------------
-- function updateFriendUser_activeTime
-- @brief 친구 유저 접속 시간
-------------------------------------
function ServerData_Friend:updateFriendUser_activeTime(t_friend_info)
    local server_time = Timer:getServerTime()

    -- 최종 활동 시간을 millisecond에서 second로 변경
    local last_active = (t_friend_info['last_active'] / 1000)

    -- 마지막 활동 시간이 없을 경우
    if (last_active == 0) then
        t_friend_info['last_active_past_time'] = -1
        return
    end

    -- 마지막 활동에서 지난 시간
    t_friend_info['last_active_past_time'] = (server_time - last_active)

    -- 30분 이내에 활동이 있었을 경우 접속 상태로 처리
    if t_friend_info['last_active_past_time'] <= (60 * 30) then
        t_friend_info['is_online'] = true
    else
        t_friend_info['is_online'] = false
    end
end

-------------------------------------
-- function getPastActiveTimeStr
-- @brief 최종 접속 시간(지나간 시간 출력)
-------------------------------------
function ServerData_Friend:getPastActiveTimeStr(t_friend_info)
    if t_friend_info['is_online'] then
        return Str('접속 중')
    end

    local last_active_past_time = t_friend_info['last_active_past_time']
    if (last_active_past_time == -1) then
        return Str('접속정보 없음')
    else
        local showSeconds = true
        return Str('최종접속 : {1} 전', datetime.makeTimeDesc(last_active_past_time, showSeconds))
    end
end

-------------------------------------
-- function getDragonUseCoolStr
-- @brief 드래곤 사용 시간
-------------------------------------
function ServerData_Friend:getDragonUseCoolStr(t_friend_info)
    -- 소울메이트의 경우
    if (t_friend_info['friendtype'] == 3) then
        if t_friend_info['is_online'] then
            return Str('접속 중')
        else
            return Str('비접속 (접속 유지 시 사용 가능)')
        end
    else
        local cool_time = (t_friend_info['cool_time'] / 1000)
        local server_time = Timer:getServerTime()
        
        if (cool_time == 0) then
            return '미사용'
        elseif (server_time < cool_time) then
            local gap = (cool_time - server_time)
            local showSeconds = true
            local firstOnly = false
            local text = datetime.makeTimeDesc(gap, showSeconds, firstOnly)
            local str = Str('{1} 후 사용 가능', text)
            return str
        else
            local gap = (server_time - cool_time)
            local showSeconds = true
            local firstOnly = false
            local text = datetime.makeTimeDesc(gap, showSeconds, firstOnly)
            local str = Str('{1} 전에 사용함', text)
            return str
        end
    end
end

-------------------------------------
-- function sortForFriendDragonSelectList
-- @brief 친구 드래곤 선택 리스트에서 정렬
-------------------------------------
function ServerData_Friend:sortForFriendDragonSelectList(sort_target_list)
    local sort_manager = SortManager()

    -- 드래곤의 레벨로 정렬
    sort_manager:addSortType('level', true, function(a, b, ascending)
            local a_data = a['data']
            local b_data = b['data']

            local a_dragon = a_data['leader']
            local b_dragon = b_data['leader']

            -- 레벨 높은 순서
            if (a_dragon['lv'] ~= b_dragon['lv']) then
                return a_dragon['lv'] > b_dragon['lv']

            -- 등급 높은 순서
            elseif (a_dragon['grade'] ~= b_dragon['grade']) then
                return a_dragon['grade'] > b_dragon['grade']

            -- 진화단계 높은 순서
            else
                return a_dragon['evolution'] > b_dragon['evolution']
            end
        end)

    -- 시간
    sort_manager:addSortType('time', true, function(a, b, ascending)
            local a_data = a['data']
            local b_data = b['data']

            local a_value = a_data['cool_time']
            local b_value = b_data['cool_time']

            if (a_value == b_value) then
                return nil
            end

            return a_value < b_value
        end)

    -- 사용 가능한 드래곤부터 정렬
    sort_manager:addSortType('enable', true, function(a, b, ascending)
            local a_data = a['data']
            local b_data = b['data']

            -- 비교하는 두 대상 중 하나만 사용 가능할 경우
            if (a_data['enable_use'] ~= b_data['enable_use']) then
                if a_data['enable_use'] then
                    return true
                else
                    return false
                end
            else
                return nil
            end
        end)

    -- 친구 타입 정렬
    sort_manager:addSortType('type', true, function(a, b, ascending)
            local a_data = a['data']
            local b_data = b['data']

            local a_value = a_data['friendtype']
            local b_value = b_data['friendtype']

            if (a_value == b_value) then
                return nil
            end
           
            return a_value > b_value
        end)

    sort_manager:sortExecution(sort_target_list)
end

-------------------------------------
-- function sortForFriendList
-- @brief 친구 리스트에서 정렬
-------------------------------------
function ServerData_Friend:sortForFriendList(sort_target_list)
    local sort_manager = SortManager()

    -- 드래곤의 레벨로 정렬
    sort_manager:addSortType('time', true, function(a, b, ascending)
            local a_data = a['data']
            local b_data = b['data']

            return a_data['last_active'] > b_data['last_active']
        end)

    -- 친구 타입 정렬
    sort_manager:addSortType('type', true, function(a, b, ascending)
            local a_data = a['data']
            local b_data = b['data']

            local a_type = a_data['friendtype']
            local b_type = b_data['friendtype']

            if (a_type ~= b_type) then
                return a_type > b_type 
            end

            return nil
        end)

    sort_manager:sortExecution(sort_target_list)
end

-------------------------------------
-- function request_byeFriends
-- @brief 친구 삭제
-------------------------------------
function ServerData_Friend:request_byeFriends(friend_uid, friend_type, is_cash, finish_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        self:response_friendCommon(ret)

        if ret['friends_bye_list'] then
            for i,v in ipairs(ret['friends_bye_list']) do
                local uid = v
                self.m_lFriendUserList[uid] = nil
            end
        end

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/socials/bye_friends')
    ui_network:setParam('uid', uid)
    ui_network:setParam('friends', friend_uid)
    ui_network:setParam('type', friend_type)
    ui_network:setParam('is_cash', is_cash and 1 or 0)

    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function response_friendCommon
-- @brief
-------------------------------------
function ServerData_Friend:response_friendCommon(ret)
    if ret['friend_info'] then
        self.m_friendSystemStatus = ret['friend_info']
    end

    -- 플레이어가 오늘 우정포인트를 보낸 유저 uid 저장
    if ret['fpsend'] then
        self.m_mSentFpUserList = {}
        for i,v in ipairs(ret['fpsend']) do
           self.m_mSentFpUserList[v] = true 
        end
    end

    -- 나의 드래곤 지원 요청 정보
    if ret['my_need_info'] then
        self.m_myDragonSupportRequestInfo = ret['my_need_info']
    end
end


-------------------------------------
-- function getByeDailyCnt
-- @brief
-------------------------------------
function ServerData_Friend:getByeDailyCnt()
    local cnt = self.m_friendSystemStatus['bye_daily_cnt']
    return cnt
end

-------------------------------------
-- function getByeDailyLimit
-- @brief
-------------------------------------
function ServerData_Friend:getByeDailyLimit()
    local cnt = 3
    return cnt
end

-------------------------------------
-- function getDragonSupportRequestList
-- @brief 드래곤 지원 요청 리스트
-------------------------------------
function ServerData_Friend:getDragonSupportRequestList()
    local l_friend_map = self:getFriendList()

    local l_request_list = {}

    for i,v in pairs(l_friend_map) do
        local is_empty = table.isEmpty(v['need_did'])
        if (not is_empty) then
            local value, did = table.getFirst(v['need_did'])

            if did and (value == '') then
                table.insert(l_request_list, v)
            end
        end
    end

    return l_request_list
end


local T_NEED_INFO = {}
T_NEED_INFO['did'] = nil
T_NEED_INFO['support_finish'] = false
T_NEED_INFO['requested_at'] = 0
T_NEED_INFO['fp_reward'] = 0

-------------------------------------
-- function parseDragonSupportRequestInfo
-- @brief 드래곤 지원 정보 분석
-------------------------------------
function ServerData_Friend:parseDragonSupportRequestInfo(l_need_info)
    local t_need_info = clone(T_NEED_INFO)

    if table.isEmpty(l_need_info) then
        return t_need_info
    end

    local value, did = table.getFirst(l_need_info)
    t_need_info['did'] = tonumber(did)

    local rarity = TableDragon():getValue(t_need_info['did'], 'rarity')

    if (rarity == 'common') then
        t_need_info['fp_reward'] = 100

    elseif (rarity == 'rare') then
        t_need_info['fp_reward'] = 500

    elseif (rarity == 'hero') then
        t_need_info['fp_reward'] = 1000

    elseif (rarity == 'legend') then
        t_need_info['fp_reward']= 5000

    end

    if (value == '') then
        t_need_info['support_finish'] = false
    else
        t_need_info['support_finish'] = true
    end
    
    return t_need_info
end

-------------------------------------
-- function getMyDragonSupporRequesttInfo
-- @brief 나의 드래곤 요청 정보 분석
-------------------------------------
function ServerData_Friend:getMyDragonSupporRequesttInfo()
    return self:parseDragonSupportRequestInfo(self.m_myDragonSupportRequestInfo)
end


-------------------------------------
-- function request_sendFp
-- @brief 우정포인트 보내기
-------------------------------------
function ServerData_Friend:request_sendFp(frined_uid_list, finish_cb)
    -- 파라미터
    local uid = g_userData:get('uid')
    local friends = listToCsv(frined_uid_list)

    -- 콜백 함수
    local function success_cb(ret)
        self:response_friendCommon(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/socials/send_fp')
    ui_network:setParam('uid', uid)
    ui_network:setParam('friends', friends)

    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_sendFpAllFriends
-- @brief 우정포인트 보내기
-------------------------------------
function ServerData_Friend:request_sendFpAllFriends(finish_cb)
    local frined_uid_list = {}
    
    for uid,v in pairs(self.m_lFriendUserList) do

        -- 오늘 우정포인트를 보내지 않은 유저에게만
        if (not self:isSentFp(uid)) then
            table.insert(frined_uid_list, uid)
        end
    end

    self:request_sendFp(frined_uid_list, finish_cb)
end

-------------------------------------
-- function isSentFp
-- @brief 해당 uid의 친구에게 오늘 우정포인트를 보냈는지 여부
-------------------------------------
function ServerData_Friend:isSentFp(friend_uid)
    return self.m_mSentFpUserList[friend_uid]
end


-------------------------------------
-- function availabilityOfDragonSupportRequests
-- @brief 드래곤 지원 요청 가능성
-------------------------------------
function ServerData_Friend:availabilityOfDragonSupportRequests(dragon_rarity)
    -- dragon_rarity :'common', 'rare', 'hero', 'legend'
    local time_stamp = self.m_friendSystemStatus['need_dragon_cool_' .. dragon_rarity]

    local server_time = Timer:getServerTime()
    time_stamp = (time_stamp / 1000)

    if (time_stamp == 0) or (time_stamp <= server_time) then
        return true
    else
        return false, time_stamp - server_time
    end
end

-------------------------------------
-- function getDragonSupportRequestCooltimeText
-- @brief 드래곤 요청 희귀도별 문자열
-------------------------------------
function ServerData_Friend:getDragonSupportRequestCooltimeText(dragon_rarity)
    local availability, remain_time = self:availabilityOfDragonSupportRequests(dragon_rarity)

    if availability then
        return Str('지원 요청 가능')
    else
        local showSeconds = true
        return Str('{1} 남음', datetime.makeTimeDesc(remain_time, showSeconds))
    end
end

-------------------------------------
-- function request_setNeedDragon
-- @brief 드래곤 지원 요청
-------------------------------------
function ServerData_Friend:request_setNeedDragon(did, finish_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        self:response_friendCommon(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/socials/set_need_dragon')
    ui_network:setParam('uid', uid)
    ui_network:setParam('did', did)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_sendNeedDragon
-- @brief 드래곤 지원
-------------------------------------
function ServerData_Friend:request_sendNeedDragon(fuid, doid, finish_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        self:response_friendCommon(ret)

        -- 재료로 사용된 드래곤 삭제
        if ret['deleted_dragons_oid'] then
            for _,doid in pairs(ret['deleted_dragons_oid']) do
                g_dragonsData:delDragonData(doid)
            end
        end

        -- 지원 드래곤 정보에 내 uid를 입력
        local t_friend_info = self.m_lFriendUserList[fuid]
        local first, key = table.getFirst(t_friend_info['need_did'])
        t_friend_info['need_did'][key] = uid

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/socials/send_need_dragon')
    ui_network:setParam('uid', uid)
    ui_network:setParam('fuid', fuid)
    ui_network:setParam('doid', doid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end




-------------------------------------
-- function getFriendOnlineBuff
-- @brief 친구 접속 버프
-------------------------------------
function ServerData_Friend:getFriendOnlineBuff()
    local friend_list = self:getFriendList()

    local soulmate_buff = {}
    soulmate_buff['online'] = {}

    local bestfriend_buff = {}
    bestfriend_buff['online'] = {}

    for i,v in pairs(friend_list) do
        -- 소울메이트
        if (v['friendtype'] == 3) and v['is_online'] then
            table.insert(soulmate_buff['online'], v['nick'])

        -- 베스트프랜드
        elseif (v['friendtype'] == 2) and v['is_online'] then
            table.insert(bestfriend_buff['online'], v['nick'])

        end
    end

    -- 소울메이트
    local online_soulmate = #soulmate_buff['online']
    if online_soulmate > 0 then
        soulmate_buff['buff_list'] = {}
        soulmate_buff['buff_list']['exp'] = (online_soulmate * 10)
        soulmate_buff['buff_list']['gold'] = (online_soulmate * 10)
        soulmate_buff['buff_list']['atk'] = (online_soulmate * 5)
        soulmate_buff['buff_list']['def'] = (online_soulmate * 5)

        local nick_str = nil
        for i,v in ipairs(soulmate_buff['online']) do
            if (not nick_str) then
                nick_str = ''
            else
                nick_str = nick_str .. ', '
            end
            nick_str = nick_str .. v
        end
        soulmate_buff['info_title'] = Str('{@SKILL_NAME}[소울메이트 접속 버프]')
        soulmate_buff['info_title'] = soulmate_buff['info_title'] .. ' {@WHITE}(' .. nick_str .. ')'
        soulmate_buff['info_list'] = {}
        table.insert(soulmate_buff['info_list'], Str('{@DEEPSKYBLUE}[소울메이트의 응원] {@WHITE}모든 모드에서 결과로 얻는 {@YELLOW}경험치 +{1}% 증가', soulmate_buff['buff_list']['exp']))
        table.insert(soulmate_buff['info_list'], Str('{@DEEPSKYBLUE}[소울메이트의 행운] {@WHITE}모든 모드에서 결과로 얻는 {@YELLOW}골드 +{1}% 증가', soulmate_buff['buff_list']['gold']))
        table.insert(soulmate_buff['info_list'], Str('{@DEEPSKYBLUE}[소울메이트의 기원] {@WHITE}모든 모드에서 {@YELLOW}공격력, 방어력 +{1}% 증가', soulmate_buff['buff_list']['atk']))
    end

    -- 베스트프랜드
    local online_bestfriend = #bestfriend_buff['online']
    if online_bestfriend > 0 then
        bestfriend_buff['buff_list'] = {}
        bestfriend_buff['buff_list']['exp'] = (online_bestfriend * 3)
        bestfriend_buff['buff_list']['gold'] = (online_bestfriend * 3)

        local nick_str = nil
        for i,v in ipairs(bestfriend_buff['online']) do
            if (not nick_str) then
                nick_str = ''
            else
                nick_str = nick_str .. ', '
            end
            nick_str = nick_str .. v
        end
        bestfriend_buff['info_title'] = Str('{@SKILL_NAME}[베스트프랜드 접속 버프]')
        bestfriend_buff['info_title'] = bestfriend_buff['info_title'] .. ' {@WHITE}(' .. nick_str .. ')'
        bestfriend_buff['info_list'] = {}
        table.insert(bestfriend_buff['info_list'], Str('{@DEEPSKYBLUE}[베스트프랜드의 응원] {@WHITE}모든 모드에서 결과로 얻는 {@YELLOW}경험치 +{1}% 증가', bestfriend_buff['buff_list']['exp']))
        table.insert(bestfriend_buff['info_list'], Str('{@DEEPSKYBLUE}[베스트프랜드의 행운] {@WHITE}모든 모드에서 결과로 얻는 {@YELLOW}골드 +{1}% 증가', bestfriend_buff['buff_list']['gold']))
    end


    -- 실제 적용될 버프 내용만 key, value로 저장하는 테이블
    local total_buff_list = {}
    do 
        -- 소울메이트 버프 합산
        if soulmate_buff['buff_list'] then
            for i,v in pairs(soulmate_buff['buff_list']) do
                if (not total_buff_list[i]) then
                    total_buff_list[i] = 0
                end
                total_buff_list[i] = total_buff_list[i] + v
            end
        end

        -- 베스트프랜드 버프 합산
        if bestfriend_buff['buff_list'] then
            for i,v in pairs(bestfriend_buff['buff_list']) do
                if (not total_buff_list[i]) then
                    total_buff_list[i] = 0
                end
                total_buff_list[i] = total_buff_list[i] + v
            end
        end
    end

    return bestfriend_buff, soulmate_buff, total_buff_list
end