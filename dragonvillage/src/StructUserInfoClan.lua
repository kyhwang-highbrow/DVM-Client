local PARENT = StructUserInfo

-------------------------------------
-- class StructUserInfoClan
-- @instance
-------------------------------------
StructUserInfoClan = class(PARENT, {
        m_bTodayAttendance = 'boolean', -- 오늘 출석 여부
        m_memberType = 'string',
        m_dungeonInfo = '',

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
    user_info.m_profileFrame = t_data['profile_frame']
    user_info.m_profileFrameExpiredAt = t_data['profile_frame_expired_at']

    if (t_data['info'] and t_data['info']['arena_new_last_tier']) then
        user_info.m_lastArenaTier = t_data['info']['arena_new_last_tier']
    else
        user_info.m_lastArenaTier = 'beginner'
    end

    -- 친구 드래곤 룬 세팅
    user_info.m_leaderDragonObject:setRuneObjects(t_data['runes'])

    -- 최초 생성시 시간 관련 update 해줌
    user_info:setUpdate()

    local t_info = t_data['info']
    if t_info then
        user_info.m_bTodayAttendance = t_info['attendance']
        user_info.m_memberType = t_info['clan_auth']
        user_info.m_dungeonInfo = self:makeDungeonInfo(t_info)
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
    local server_time = ServerTime:getInstance():getCurrentTimestampSeconds()

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
        local showSeconds = false
        local firstOnly = true
        return Str('최종접속 : {1} 전', ServerTime:getInstance():makeTimeDescToSec(last_active_time, showSeconds, firstOnly))
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
-- function getMemberTypeColor
-- @brief 맴버 타입 색상
-------------------------------------
function StructUserInfoClan:getMemberTypeColor()
    local member_type = self.m_memberType

    -- 마스터
    if (member_type == 'master') then
        return COLOR['clan_master']

    -- 부마스터
    elseif (member_type == 'manager') then
        return COLOR['clan_manager']

    -- 맴버
    elseif (member_type == 'member') then
        return COLOR['clan_member']

    else
        return COLOR['clan_member']
    end
end

-------------------------------------
-- function isTodayAttendance
-- @brief 오늘 출석 여부
-------------------------------------
function StructUserInfoClan:isTodayAttendance()
    return self.m_bTodayAttendance
end


-------------------------------------
-- function getLastActiveTime
-- @brief 마지막 활동 시간(timestamp)
-------------------------------------
function StructUserInfoClan:getLastActiveTime()
    return self.m_lastActiveTime
end

-------------------------------------
-- function makeDungeonInfo
-- @breif 클랜원의 던전 플레이 정보
-------------------------------------
function StructUserInfoClan:makeDungeonInfo(data)
    local t_dungeon = {}
    -- 콜로세움 플레이 정보
    t_dungeon['arena_play'] = data['arena_play'] or 0
    t_dungeon['arena_score'] = data['arena_score'] or 0
    t_dungeon['arena_new_tier'] = data['arena_new_tier'] or 'beginner'
    t_dungeon['arena_rate'] = data['arena_rate'] or 0
    t_dungeon['arena_rank'] = data['arena_rank'] or 0

    -- 고대의탑 플레이 정보
    t_dungeon['ancient_score'] = data['ancient_score'] or 0
    t_dungeon['ancient_stage'] = data['ancient_stage'] or 1

    -- 클랜던전 플레이 정보
    t_dungeon['clandungeon_play'] = data['clandungeon_play'] or 0
    t_dungeon['clandungeon_score'] = data['clandungeon_score'] or 0

	-- 클랜 기여도
	t_dungeon['contribute_exp'] = data['contribute_exp'] or 0

	-- 클랜전 기여도
	t_dungeon['clanwar_play_cnt'] = data['clanwar_play_cnt'] or 0
    t_dungeon['clanwar_win_cnt'] = data['clanwar_win_cnt'] or 0

    return t_dungeon
end

-------------------------------------
-- function getArenaPlayText
-------------------------------------
function StructUserInfoClan:getArenaPlayText()
    local t_dungeon = self.m_dungeonInfo
    if (not t_dungeon) then 
        return ''
    end

    local user_info = StructUserInfoArena()
    user_info.m_tier = t_dungeon['arena_new_tier']
    user_info.m_rank = t_dungeon['arena_rank']
    user_info.m_rp = t_dungeon['arena_score']
    user_info.m_rankPercent = t_dungeon['arena_rate']

    local param_1 = Str('콜로세움')
    local param_2 = user_info:getTierName(t_dungeon['arena_new_tier'])
    local param_3 = user_info:getRankText(true)
    local param_4 = user_info:getRPText()

    -- 번역 추출 안하기 위해 기존 문구 조합으로
    local str = string.format('{@dark_brown}%s : {@apricot}%s / %s / %s', param_1, param_2, param_3, param_4)
    return str
end

-------------------------------------
-- function getClanDungeonPlayText
-------------------------------------
function StructUserInfoClan:getClanDungeonPlayText()
    local t_dungeon = self.m_dungeonInfo
    if (not t_dungeon) then 
        return ''
    end

    local param_1 = Str('고대의 탑')
    local param_2 = Str('{1}점', comma_value(t_dungeon['ancient_score']))
    local param_3 = Str('{1}층', comma_value(t_dungeon['ancient_stage']%100))

    -- 번역 추출 안하기 위해 기존 문구 조합으로
    local str = string.format('{@dark_brown}%s : {@apricot}%s / %s', param_1, param_2, param_3)
    return str
end

-------------------------------------
-- function getAncientPlayText
-------------------------------------
function StructUserInfoClan:getAncientPlayText()
    local t_dungeon = self.m_dungeonInfo
    if (not t_dungeon) then 
        return ''
    end

    local param_1 = Str('클랜던전')
    local param_2 = Str('{1}점', comma_value(t_dungeon['clandungeon_score']))
    local param_3 = Str('{1}회', comma_value(t_dungeon['clandungeon_play']))

    -- 번역 추출 안하기 위해 기존 문구 조합으로
    local str = string.format('{@dark_brown}%s : {@apricot}%s / %s', param_1, param_2, param_3)
    return str
end

-------------------------------------
-- function getClanContributionExp
-------------------------------------
function StructUserInfoClan:getClanContributionExp()
	local t_dungeon = self.m_dungeonInfo
    if (not t_dungeon) then 
        return 0
    end
	return t_dungeon['contribute_exp']
end

-------------------------------------
-- function getClanContribution
-------------------------------------
function StructUserInfoClan:getClanContribution()
    local t_dungeon = self.m_dungeonInfo
    if (not t_dungeon) then 
        return ''
    end

    local param_1 = Str('경험치 기여도')
    local param_2 = Str('{1} xp', comma_value(t_dungeon['contribute_exp']))

    -- 번역 추출 안하기 위해 기존 문구 조합으로
    local str = string.format('{@dark_brown}%s : {@apricot}%s', param_1, param_2)
    return str
end

-------------------------------------
-- function getClanWarText
-------------------------------------
function StructUserInfoClan:getClanWarText()
    local t_dungeon = self.m_dungeonInfo
    if (not t_dungeon) then 
        return ''
    end

    local clanwar_play_cnt = t_dungeon['clanwar_play_cnt'] or 0
    local clanwar_win_cnt = t_dungeon['clanwar_win_cnt'] or 0
    return Str('{@dark_brown}클랜전 : {@apricot}{1}회 참가 / {2} 승리', clanwar_play_cnt, clanwar_win_cnt) 
end

-------------------------------------
-- function getDungeonPlayText
-------------------------------------
function StructUserInfoClan:getDungeonPlayText()
    local param_1 = self:getClanDungeonPlayText()
    local param_2 = self:getAncientPlayText()
    local param_3 = ''
    if (g_arenaData:isStartClanWarContents()) then
        param_3 = self:getClanWarText()
    else
        param_3 = self:getArenaPlayText()
	end
    local param_4 = self:getClanContribution()

    return string.format('%s\n%s\n%s\n%s', param_1, param_2, param_3, param_4)
end

-------------------------------------
-- function getArenaTier
-------------------------------------
function StructUserInfoClan:getArenaTier()
    local t_dungeon = self.m_dungeonInfo
    if (not t_dungeon) then 
        return 'beginner'
    end

    if (t_dungeon['arena_new_tier']) then return t_dungeon['arena_new_tier'] end

    return 'beginner'
end
