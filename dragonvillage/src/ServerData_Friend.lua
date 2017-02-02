-------------------------------------
-- class ServerData_Friend
-------------------------------------
ServerData_Friend = class({
        m_serverData = 'ServerData',

        m_lRecommendUserList = 'list',
        m_lFriendUserList = 'list',
        m_lFriendInviteList = 'list',

        -- 선택된 공유 친구 데이터
        m_selectedShareFriendData = '',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Friend:init(server_data)
    self.m_serverData = server_data
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
        self.m_lRecommendUserList = ret['users_list']
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
        self:applyInvitedRecommendUser(friend_uid)

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
-- function applyInvitedRecommendUser
-- @brief 친구 초대가 완료된 항목 처리
-------------------------------------
function ServerData_Friend:applyInvitedRecommendUser(friend_uid)
    local l_user_list = self:getRecommendUserList()

    if (not l_user_list) then
        return
    end

    for i,v in ipairs(l_user_list) do
        if (v['uid'] == friend_uid ) then
            v['invited'] = true
        end
    end
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
    end
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
function ServerData_Friend:makeFriendDragonStatusCalculator(t_dragon_data, t_runes_data)
    
    -- 드래곤 룬 정보
    local l_runes = t_dragon_data['runes']
    local l_rune_obj_map = {}
    local l_runes_for_set = {}
    for _,roid in pairs(l_runes) do
        local t_rune_data = t_runes_data[roid]
        l_rune_obj_map[roid] = t_rune_data
        table.insert(l_runes_for_set, t_rune_data)
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

