local PARENT = StructUserInfo

-------------------------------------
-- class StructUserInfoFriend
-- @instance
-------------------------------------
StructUserInfoFriend = class(PARENT, {

        --------------------------------------
        --------------------------------------
        -- StructUserInfo의 변수들 참고용 (2017-06-30)
        m_bStruct = 'boolean',

        m_uid = 'number',
        m_lv = 'number',
        m_nickname = 'string',
        m_leaderDragonObject = '',

        m_lastActiveTime = 'number', -- 최종 활동 시간
        m_lastAcitvePastTime = 'number', -- 현재 시간 - 최종 활동 시간

        m_isOnline = 'boolean', -- 현재 접속 상태

        m_usedTime = 'number', -- 친구 드래곤 최종 사용 시간
        m_enableUse = 'boolean', -- 친구 드래곤 사용 가능 상태

        m_arenaTier = 'string', -- 콜로세움 티어
    })

-------------------------------------
-- function create
-- @brief 랭킹 유저 정보
-------------------------------------
function StructUserInfoFriend:create(t_data)
    local user_info = StructUserInfoFriend()
    user_info.m_uid = t_data['uid']
    user_info.m_nickname = t_data['nick']
    user_info.m_lv = t_data['lv']
    user_info.m_lastActiveTime = t_data['last_active']
    user_info.m_usedTime = t_data['used_time']
    user_info.m_leaderDragonObject = StructDragonObject(t_data['leader'])
    user_info.m_arenaTier = t_data['debris']['tier'] and t_data['debris']['tier'] or 'beginner'
    user_info.m_lairStats = t_data['lair_stats']

    -- 친구 드래곤 룬 세팅
    user_info.m_leaderDragonObject:setRuneObjects(t_data['runes'])

    -- 최초 생성시 시간 관련 update 해줌
    user_info:setUpdate()

    return user_info
end

-------------------------------------
-- function init
-------------------------------------
function StructUserInfoFriend:init()
    self.m_isOnline = false
    self.m_enableUse = false

    self.m_lastActiveTime = 0
    self.m_lastAcitvePastTime = 0
    self.m_usedTime = 0
end

-------------------------------------
-- function applyTableData
-- @breif 단순 데이터 table에서 struct로 맴버 변수를 설정하는 함수
-------------------------------------
function StructUserInfoFriend:applyTableData(data)
end

-------------------------------------
-- function getLvText
-- @brief
-------------------------------------
function StructUserInfoFriend:getLvText()
    local str = Str('레벨 {1}', self.m_lv)
    return str
end

-------------------------------------
-- function getNickText
-- @brief
-------------------------------------
function StructUserInfoFriend:getNickText()
    local str = Str('{1}', self.m_nickname)
    return str
end

-------------------------------------
-- function setUpdate
-- @brief 친구 접속시간과 드래곤 사용시간 갱신
-------------------------------------
function StructUserInfoFriend:setUpdate()
    self:updateFriendUser_activeTime()
    self:updateFriendUser_usedTime()
end

-------------------------------------
-- function updateFriendUser_activeTime
-- @brief 친구 접속 시간
-------------------------------------
function StructUserInfoFriend:updateFriendUser_activeTime()
    local server_time = ServerTime:getInstance():getCurrentTimestampSeconds()

    -- 최종 활동 시간을 millisecond에서 second로 변경
    local last_active = (self.m_lastActiveTime / 1000)

    -- 마지막 활동에서 지난 시간
    self.m_lastAcitvePastTime = (server_time - last_active)

    -- 30분 이내에 활동이 있었을 경우 접속 상태로 처리
    if self.m_lastAcitvePastTime <= (60 * 30) then
        self.m_isOnline = true
    else
        self.m_isOnline = false
    end
end

-------------------------------------
-- function getPastActiveTimeText
-- @brief 최종 접속 시간 텍스트
-------------------------------------
function StructUserInfoFriend:getPastActiveTimeText()
    if (self.m_isOnline) then
        return Str('접속 중')
    end

    local last_active_time = self.m_lastAcitvePastTime
    if (last_active_time == -1) then
        return Str('접속정보 없음')
    else
        local showSeconds = false
        local firstOnly = true
        return Str('최종접속 : {1} 전', ServerTime:getInstance():makeTimeDescToSec(last_active_time, showSeconds, firstOnly))
    end
end

-------------------------------------
-- function updateFriendUser_usedTime
-- @brief 친구 드래곤 사용 시간 업데이트
-------------------------------------
function StructUserInfoFriend:updateFriendUser_usedTime()
    local server_time = ServerTime:getInstance():getCurrentTimestampSeconds()

    -- 쿨타임 체크 후 사용 가능 여부표시
    local used_time = (self.m_usedTime / 1000)
    if (used_time == 0) or (used_time <= server_time) then
        self.m_enableUse = true
    else
        self.m_enableUse = false
    end
end

-------------------------------------
-- function getDragonUseCoolText
-- @brief 드래곤 사용 시간 텍스트
-------------------------------------
function StructUserInfoFriend:getDragonUseCoolText()
    local used_time = (self.m_usedTime / 1000)
    local server_time = ServerTime:getInstance():getCurrentTimestampSeconds()
        
    if (used_time == 0) then
        return '미사용'
    elseif (server_time < used_time) then
        local gap = (used_time - server_time)
        local showSeconds = true
        local firstOnly = false
        local text = ServerTime:getInstance():makeTimeDescToSec(gap, showSeconds, firstOnly)
        local str = Str('{1} 후 \n사용 가능', text)
        return str
    else
        local gap = (server_time - used_time)
        local showSeconds = true
        local firstOnly = false
        local text = ServerTime:getInstance():makeTimeDescToSec(gap, showSeconds, firstOnly)
        local str = Str('{1} 전에 \n사용함', text)
        return str
    end
end

-------------------------------------
-- function getDragonCard
-------------------------------------
function StructUserInfoFriend:getDragonCard()
    local t_dragon_data = self.m_leaderDragonObject
    local card = UI_DragonCard(t_dragon_data)
    card.root:setSwallowTouch(false)

	-- 버튼 콜백 등록
    card.vars['clickBtn']:registerScriptTapHandler(function() 
		local is_visit = true
		UI_UserInfoDetailPopup:open(self, is_visit, nil)
	end)

    return card.root
end


-------------------------------------
-- function getArenaTier
-------------------------------------
function StructUserInfoFriend:getArenaTier()
    if (not self.m_arenaTier) then return 'beginner' end

    return self.m_arenaTier
end





