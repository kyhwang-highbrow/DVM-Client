local MAX_FRIEND_CNT    = 20 -- 최대 친구 수
local MAX_REQUEST_CNT   = 30 -- 하루 최대 보낼 수 있는 요청
local MAX_RESPONSE_CNT  = 30 -- 하루 최대 받을 수 있는 요청
local MAX_BYE_CNT       = 3  -- 하루 최대 삭제할 수 있는 친구 수
-------------------------------------
-- class ServerData_Friend
-------------------------------------
ServerData_Friend = class({
        m_serverData = 'ServerData',

        m_friendSystemStatus = '',

        m_lRecommendUserList = 'list',
        m_lFriendUserList = 'list',

        m_lFriendInviteResponseList = 'list', -- 친구 초대 받은 요청
        m_lFriendInviteRequestList = 'list', -- 친구 초대 보낸 요청

        m_lFriendDragonsList = 'list',

        m_mInvitedUserList = 'map', -- 클라이언트가 켜져있는 동안 친구초대를 한 유저의 uid 저장
         
        m_mSentFpUserList = 'map', -- 오늘 우정포인트를 보낸 유저 리스트
        
        -- 선택된 친구 드래곤 
        m_selectedSharedFriendDragon = '',

        -- 선택된 공유 친구 데이터
        m_selectedShareFriendData = '',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Friend:init(server_data)
    self.m_serverData           = server_data
    self.m_mInvitedUserList     = {}

    self.m_lFriendInviteResponseList = {}
    self.m_lFriendInviteRequestList = {}

    self.m_mSentFpUserList      = {}
    self.m_lFriendDragonsList   = {}
    self.m_lRecommendUserList   = {}
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
            if (not self.m_mInvitedUserList[uid]) then
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
    --if (not self:checkInviteCondition(friend_uid)) then return end

    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        self.m_mInvitedUserList[friend_uid] = true
        self.m_lRecommendUserList[friend_uid] = nil

        -- 초대한 친구 보낸 요청 리스트에 추가
        for i,v in ipairs(ret['friends_list']) do
            local uid = v['uid']
            self.m_lFriendInviteRequestList[uid] = v
        end

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/socials/invite')
    ui_network:setParam('uid', uid)
    ui_network:setParam('friends', friend_uid)
    ui_network:setParam('type') 
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

        self:setDragonsList()

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
function ServerData_Friend:getFriendCount()
    local count = 0
    for _, v in pairs(self.m_lFriendUserList) do
        count = (count + 1)
    end

    return count
end

-------------------------------------
-- function getMaxFriendCount
-- @brief 친구 갯수 받아옴
-------------------------------------
function ServerData_Friend:getMaxFriendCount()
    return MAX_FRIEND_CNT
end

-------------------------------------
-- function isFriend
-------------------------------------
function ServerData_Friend:isFriend(friend_uid)
    if self.m_lFriendUserList[friend_uid] then return true end
    return false
end

-------------------------------------
-- function checkInviteCondition
-------------------------------------
function ServerData_Friend:checkInviteCondition(friend_uid)
    if self:isMyFriend(friend_uid) then
        local msg = Str('이미 친구입니다.')
        UIManager:toastNotificationGreen(msg)
        return false
    end

    if (table.count >= MAX_FRIEND_CNT) then
        local msg = Str('친구 목록이 가득 찼습니다.')
        UIManager:toastNotificationGreen(msg)
        return false
    end
    
    return true
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
    return StructDragonObject(t_friend_info['leader']), t_friend_info['runes']
end

-------------------------------------
-- function makeFriendDragonStatusCalculator
-- @brief
-------------------------------------
function ServerData_Friend:makeFriendDragonStatusCalculator(t_dragon_data)
    local status_calc = MakeDragonStatusCalculator_fromDragonDataTable(t_dragon_data)
end

-------------------------------------
-- function request_inviteResponseList
-- @brief 친구 요청 리스트 (받은 요청)
-------------------------------------
function ServerData_Friend:request_inviteResponseList(finish_cb, force)
    if self.m_lFriendInviteResponseList and (not force) then
        if finish_cb then
            finish_cb()
        end
        return
    end

    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        self.m_lFriendInviteResponseList = {}
        for i,v in ipairs(ret['invites_list']) do
            local uid = v['uid']
            self.m_lFriendInviteResponseList[uid] = v
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
-- function request_inviteRequestList
-- @brief 친구 요청 리스트 (보낸 요청)
-------------------------------------
function ServerData_Friend:request_inviteRequestList(finish_cb, force)
    if self.m_lFriendInviteRequestList and (not force) then
        if finish_cb then
            finish_cb()
        end
        return
    end

    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        self.m_lFriendInviteRequestList = {}
        for i,v in ipairs(ret['request_list']) do
            local uid = v['uid']
            self.m_lFriendInviteRequestList[uid] = v
        end

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/socials/request_list')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function getFriendInviteResponseList
-- @brief 친구 요청 리스트 (받은 요청)
-------------------------------------
function ServerData_Friend:getFriendInviteResponseList()
    return self.m_lFriendInviteResponseList
end

-------------------------------------
-- function getFriendInviteRequestList
-- @brief 친구 요청 리스트 (보낸 요청)
-------------------------------------
function ServerData_Friend:getFriendInviteRequestList()
    return self.m_lFriendInviteRequestList
end

-------------------------------------
-- function getFirnedInviteRequestCount
-------------------------------------
function ServerData_Friend:getFirnedInviteRequestCount()
    return table.count(self.m_lFriendInviteRequestList)
end

-------------------------------------
-- function request_inviteResponseAccept
-- @brief 친구 요청 수락 (받은 요청)
-------------------------------------
function ServerData_Friend:request_inviteResponseAccept(friend_uid, finish_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        
        self.m_lFriendInviteResponseList[friend_uid] = nil
        
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
-- function request_inviteResponseReject
-- @brief 친구 요청 거절 (받은 요청)
-------------------------------------
function ServerData_Friend:request_inviteResponseReject(friend_uid, finish_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)

        self.m_lFriendInviteResponseList[friend_uid] = nil

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
-- function request_inviteRequestCancel
-- @brief 친구 요청 취소 (보낸 요청)
-------------------------------------
function ServerData_Friend:request_inviteRequestCancel(friend_uid, finish_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        
        self.m_lFriendInviteRequestList[friend_uid] = nil
        
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/socials/request_cancel')
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
-- t_friend_info['used_time'] 친구 드래곤을 사용 가능한 시점 (타임스템프)
-------------------------------------
function ServerData_Friend:updateFriendUser_usedTime(t_friend_info)
    local server_time = Timer:getServerTime()
    -- 쿨타임 체크 후 사용 가능 여부표시
    local used_time = (t_friend_info['used_time'] / 1000)
    if (used_time == 0) or (used_time <= server_time) then
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
    local used_time = (t_friend_info['used_time'] / 1000)
    local server_time = Timer:getServerTime()
        
    if (used_time == 0) then
        return '미사용'
    elseif (server_time < used_time) then
        local gap = (used_time - server_time)
        local showSeconds = true
        local firstOnly = false
        local text = datetime.makeTimeDesc(gap, showSeconds, firstOnly)
        local str = Str('{1} 후 \n사용 가능', text)
        return str
    else
        local gap = (server_time - used_time)
        local showSeconds = true
        local firstOnly = false
        local text = datetime.makeTimeDesc(gap, showSeconds, firstOnly)
        local str = Str('{1} 전에 \n사용함', text)
        return str
    end
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
end

-------------------------------------
-- function getInviteRequestDailyLimit
-------------------------------------
function ServerData_Friend:getInviteRequestDailyLimit()
    return MAX_REQUEST_CNT
end

-------------------------------------
-- function getInviteResponseDailyLimit
-------------------------------------
function ServerData_Friend:getInviteResponseDailyLimit()
    return MAX_RESPONSE_CNT
end

-------------------------------------
-- function getByeDailyCnt
-------------------------------------
function ServerData_Friend:getByeDailyCnt()
    local cnt = self.m_friendSystemStatus['bye_daily_cnt']
    return cnt
end

-------------------------------------
-- function getByeDailyLimit
-------------------------------------
function ServerData_Friend:getByeDailyLimit()
    return MAX_BYE_CNT
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
-- function setDragonsList
-------------------------------------
function ServerData_Friend:setDragonsList()
    self.m_lFriendDragonsList = {}
            
    for _, v in pairs(self.m_lFriendUserList) do
        local t_friend_info = v
        local doid = t_friend_info['leader']['id']
        self.m_lFriendDragonsList[doid] = StructDragonObject(t_friend_info['leader'])
    end
end

-------------------------------------
-- function getDragonsList
-------------------------------------
function ServerData_Friend:getDragonsList()

    -- 친구 드래곤 사용 시간 값 갱신
    self:updateFriendUserList_time()

    local dragon_list = {}
    for _, v in pairs(self.m_lFriendDragonsList) do
        table.insert(dragon_list, v)
    end

    return dragon_list
end

-------------------------------------
-- function getDragonDataFromDoid
-------------------------------------
function ServerData_Friend:getDragonDataFromDoid(doid)
    if (self.m_lFriendDragonsList[doid]) then
        return self.m_lFriendDragonsList[doid]
    end
    
    return nil
end

-------------------------------------
-- function checkFriendDragonFromDoid
-------------------------------------
function ServerData_Friend:checkFriendDragonFromDoid(doid)
    if (self.m_lFriendDragonsList[doid]) then
        return true
    end
    
    return false
end

-------------------------------------
-- function getDragonCoolTimeFromDoid
-- @brief 드래곤 쿨타임 정보는 드래곤객체가 아닌 친구객체에서 가져와야함
-------------------------------------
function ServerData_Friend:getDragonCoolTimeFromDoid(doid)
    if (doid) and (not self:checkFriendDragonFromDoid(doid)) then return nil end
    local friend_info = self:getFriendInfoFromDoid(doid)
    local use_enable = friend_info['enable_use'] or true
    if (not use_enable) then
        return nil
    end
    return friend_info['used_time']
end

-------------------------------------
-- function checkUseEnableDragon
-- @brief 드래곤 사용가능한 상태
-------------------------------------
function ServerData_Friend:checkUseEnableDragon(doid)
    if (doid) and (not self:checkFriendDragonFromDoid(doid)) then return false end
    local friend_info = self:getFriendInfoFromDoid(doid)
    local use_enable = friend_info['enable_use'] or true
    return use_enable
end

-------------------------------------
-- function delSettedFriendDragonCard
-- @brief 친구 드래곤 슬롯 해제
-------------------------------------
function ServerData_Friend:delSettedFriendDragonCard(doid)
    if (not self:checkFriendDragonFromDoid(doid)) then return end
    if (self.m_selectedSharedFriendDragon) and
       (self.m_selectedSharedFriendDragon == doid) then
        self.m_selectedSharedFriendDragon = nil
        self.m_selectedShareFriendData = nil
    end
end

-------------------------------------
-- function makeSettedFriendDragonCard
-- @brief 친구 드래곤 슬롯 세팅
-------------------------------------
function ServerData_Friend:makeSettedFriendDragonCard(doid)
    if (not self:checkFriendDragonFromDoid(doid)) then return end
    if (not self.m_selectedSharedFriendDragon) then
        self.m_selectedSharedFriendDragon = doid
        self.m_selectedShareFriendData = self:getFriendInfoFromDoid(self.m_selectedSharedFriendDragon)
    end
end

-------------------------------------
-- function checkSetSlotCondition
-- @brief 친구 드래곤 슬롯 세팅 조건 검사
-------------------------------------
function ServerData_Friend:checkSetSlotCondition(doid)
    if (not self:checkFriendDragonFromDoid(doid)) then return true end
        
    -- 이미 선택된 친구가 있음
    if (self.m_selectedSharedFriendDragon) and (self.m_selectedSharedFriendDragon ~= doid) then 
        MakeSimplePopup(POPUP_TYPE.OK, Str('친구 드래곤은 전투에 한 명만 참여할 수 있습니다'))
        return false
    end

    return true
end

-------------------------------------
-- function getSaveDeckParam
-- @brief 친구 드래곤 저장시 친구 드래곤은 param 넘기지 않음
-------------------------------------
function ServerData_Friend:getSaveDeckParam(doid)
    if (doid) and (self:checkFriendDragonFromDoid(doid)) then return nil end
    return doid or nil
end

-------------------------------------
-- function getFriendInfoFromDoid
-- @brief 드래곤 uid로 친구 정보 가져옴
-------------------------------------
function ServerData_Friend:getFriendInfoFromDoid(doid)
    if (not self:checkFriendDragonFromDoid(doid)) then return nil end
     
    local owner_uid = self.m_lFriendDragonsList[doid]['uid']
    return self.m_lFriendUserList[owner_uid]
end

-------------------------------------
-- function getFriendOnlineBuff
-- @brief 친구 접속 버프
-------------------------------------
function ServerData_Friend:getFriendOnlineBuff()
    if true then
        return {}, {}, {}
    end
end