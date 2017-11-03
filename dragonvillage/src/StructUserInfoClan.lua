local PARENT = StructUserInfo

-------------------------------------
-- class StructUserInfoClan
-- @instance
-------------------------------------
StructUserInfoClan = class(PARENT, {
        m_bTodayAttendance = 'boolean', -- 오늘 출석 여부
        m_memberType = 'string',

        m_lastActiveTime = 'number', -- 최종 활동 시간
        m_lastAcitvePastTime = 'number', -- 현재 시간 - 최종 활동 시간
    })

-------------------------------------
-- function init
-------------------------------------
function StructUserInfoClan:init()
    self.m_bTodayAttendance = false

    self.m_lastActiveTime = 0
    self.m_lastAcitvePastTime = 0
end

-------------------------------------
-- function create
-- @breif
-------------------------------------
function StructUserInfoClan:create(t_data)
    local user_info = StructUserInfoClan()

    user_info.m_uid = t_data['uid']
    user_info.m_nickname = t_data['nick']
    user_info.m_lv = t_data['lv']
    user_info.m_tamerID = t_data['tamer']
    user_info.m_lastActiveTime = t_data['last_active']
    user_info.m_leaderDragonObject = StructDragonObject(t_data['leader'])

    -- 친구 드래곤 룬 세팅
    user_info.m_leaderDragonObject:setRuneObjects(t_data['runes'])

    -- 최초 생성시 시간 관련 update 해줌
    user_info:setUpdate()

    local t_info = t_data['info']
    if t_info then
        user_info.m_bTodayAttendance = t_info['attendance']
        user_info.m_memberType = t_info['clan_auth']
    end

    return user_info
end

-------------------------------------
-- function applyTableData
-- @breif 단순 데이터 table에서 struct로 맴버 변수를 설정하는 함수
-------------------------------------
function StructUserInfoClan:applyTableData(data)
end

-------------------------------------
-- function updateActiveTime
-- @brief 최종 접속 시간 정보 갱신
-------------------------------------
function StructUserInfoClan:updateActiveTime()
    local server_time = Timer:getServerTime()

    -- 최종 활동 시간을 millisecond에서 second로 변경
    local last_active = (self.m_lastActiveTime / 1000)

    -- 마지막 활동에서 지난 시간
    self.m_lastAcitvePastTime = (server_time - last_active)
end

-------------------------------------
-- function setUpdate
-- @brief
-------------------------------------
function StructUserInfoClan:setUpdate()
    self:getPastActiveTimeText()
end

-------------------------------------
-- function getPastActiveTimeText
-- @brief 최종 접속 시간 텍스트
-------------------------------------
function StructUserInfoClan:getPastActiveTimeText()
    -- 추후에 클랜 채팅서버가 붙으면 "접속 중" 추가할 것

    local last_active_time = self.m_lastAcitvePastTime
    if (last_active_time == -1) then
        return Str('접속정보 없음')
    else
        local showSeconds = true
        local firstOnly = true
        return Str('최종접속 : {1} 전', datetime.makeTimeDesc(last_active_time, showSeconds, firstOnly))
    end
end

-------------------------------------
-- function getMemberType
-- @brief 맴버 타입
-------------------------------------
function StructUserInfoClan:getMemberType()
    return self.m_memberType
end

-------------------------------------
-- function getMemberTypeText
-- @brief 맴버 타입 텍스트
-------------------------------------
function StructUserInfoClan:getMemberTypeText()
    local member_type = self.m_memberType

    -- 마스터
    if (member_type == 'master') then
        return Str('마스터')

    -- 부마스터
    elseif (member_type == 'manager') then
        return Str('부마스터')

    -- 맴버
    elseif (member_type == 'member') then
        return Str('클랜원')

    else
        return Str('클랜원')
    end
end

-------------------------------------
-- function isTodayAttendance
-- @brief 오늘 출석 여부
-------------------------------------
function StructUserInfoClan:isTodayAttendance()
    return self.m_bTodayAttendance
end
