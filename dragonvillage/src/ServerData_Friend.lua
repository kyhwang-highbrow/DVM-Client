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

        -- 선택된 공유 친구 데이터
        m_selectedShareFriendData = '',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Friend:init(server_data)
    self.m_serverData = server_data
    self.m_mInvitedUerList = {}
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
            self:makeNextShareTime(v)
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
-- function makeNextShareTime
-- @brief
-------------------------------------
function ServerData_Friend:makeNextShareTime(t_friend_info)
    local used_time = t_friend_info['used_time']
    local server_time = Timer:getServerTime()

    if (used_time == 0) then
        t_friend_info['next_invalid_time'] = server_time
    else
        t_friend_info['next_invalid_time'] = (used_time / 1000) + (60 * 60 * 12)
    end

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

    -- 룬 세트 효과 지정
    t_dragon_data['rune_set'] = g_runesData:makeRuneSetData(l_runes_for_set[1], l_runes_for_set[2], l_runes_for_set[3])

    -- 룬은 친밀도, 수련과 달리 Rune Object가 별도로 존재하여
    -- 외부의 함수를 통해 룬 보너스 리스트를 얻어옴
    local l_rune_bonus = ServerData_Dragons:makeRuneBonusList(t_dragon_data, l_rune_obj_map)
    
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
-- t_friend_info['used_time'] 친구 드래곤을 사용한 시간 타임스탬프
-- t_friend_info['next_invalid_time'] 친구 드래곤을 사용 가능한 다음 시간
-- t_friend_info['next_invalid_remain_time'] 친구 드래곤을 사용 가능한 다음 시간까지 남은 시간
-------------------------------------
function ServerData_Friend:updateFriendUser_usedTime(t_friend_info)
    local server_time = Timer:getServerTime()

    -- 사용 시간을 millisecond에서 second로 변경
    local used_time = (t_friend_info['used_time'] / 1000)

    -- 사용 시간이 0일 경우 사용하지 않음
    if (used_time == 0) then
        t_friend_info['next_invalid_time'] = server_time
        t_friend_info['next_invalid_remain_time'] = 0
        return
    end

    local friendtype = t_friend_info['friendtype']

    -- 쿨타임 (단위 : 시간)
    local cooltime = 0

    -- 일반 친구
    if (friendtype == 1) then
        cooltime = 12 -- 12시간

    -- 베스트 프렌드
    elseif (friendtype == 2) then
        cooltime = 6 -- 6시간

    -- 소울메이트
    elseif (friendtype == 3) then
        if t_friend_info['is_online'] then
            t_friend_info['enable_use'] = true
        else
            t_friend_info['enable_use'] = false
        end
        return
    else
        error('friendtype : ' .. friendtype)
    end

    -- 다음 사용 가능 시간 저장
    t_friend_info['next_invalid_time'] = used_time + (60 * 60 * cooltime)
    t_friend_info['next_invalid_remain_time'] = (t_friend_info['next_invalid_time'] - server_time)
    t_friend_info['enable_use'] = (t_friend_info['next_invalid_remain_time'] <= 0)
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

    -- 친구 타입 정렬
    sort_manager:addSortType('time', true, function(a, b, ascending)
            local a_data = a['data']
            local b_data = b['data']

            if (a_data['next_invalid_remain_time'] ~= b_data['next_invalid_remain_time']) then
                return a_data['next_invalid_remain_time'] < b_data['next_invalid_remain_time']
            end
        end)

    -- 친구 타입 정렬
    sort_manager:addSortType('type', true, function(a, b, ascending)
            local a_data = a['data']
            local b_data = b['data']

            local a_type = a_data['friendtype']
            local b_type = b_data['friendtype']

            -- 소울메이트만 필터링
            if (a_type ~= 3) and (b_type ~= 3) then
                return nil
            end

            if (a_type ~= b_type) then
                return a_type > b_type
            end 

            return nil
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
    return {}
end