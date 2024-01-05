local PARENT = StructUserInfo

-------------------------------------
-- class StructUserInfoClanRaid
-- @instance
-------------------------------------
StructUserInfoClanRaid = class(PARENT, {
        m_bStruct = 'boolean',

        m_uid = 'number',
        m_lv = 'number',
        m_nickname = 'string',
        m_leaderDragonObject = '',

        m_score = 'number',        -- score
        m_rank = 'number',         -- 월드 랭킹
        m_contribution = 'number', -- 기여도
        m_rankPercent = 'float',   -- 월드 랭킹 퍼센트
    })

-------------------------------------
-- function create_forRanking
-- @brief 랭킹 유저 정보
-------------------------------------
function StructUserInfoClanRaid:create_forRanking(t_data)
    local user_info = StructUserInfoClanRaid()

    user_info.m_uid = t_data['uid']
    user_info.m_nickname = t_data['nick']
    user_info.m_lv = t_data['lv']
    user_info.m_rank = t_data['rank']
    user_info.m_rankPercent = t_data['rate']
    user_info.m_score = t_data['score']
    user_info.m_profileFrame = t_data['profile_frame']
    user_info.m_profileFrameExpiredAt = t_data['profile_frame_expired_at']

    user_info.m_leaderDragonObject = StructDragonObject(t_data['leader'])

    -- 드래곤 룬 세팅
--    user_info.m_leaderDragonObject:setRuneObjects(t_data['runes'])

    return user_info
end

-------------------------------------
-- function init
-------------------------------------
function StructUserInfoClanRaid:init()
    self.m_score = 0
    self.m_rank = 0
    self.m_rankPercent = nil
end

-------------------------------------
-- function applyTableData
-- @breif 단순 데이터 table에서 struct로 맴버 변수를 설정하는 함수
-------------------------------------
function StructUserInfoClanRaid:applyTableData(data)
end

-------------------------------------
-- function setContribution
-- @brief 기여도 계산 (서버에서 주면 좋지만 유저별로 다 계산해서 주기 어렵다며 클라에서 계산하라 함)
-------------------------------------
function StructUserInfoClanRaid:setContribution(total_score)
    -- 누적 점수 0 처리
    self.m_contribution = (total_score == 0) and 0 or (self.m_score/total_score * 100)
end

-------------------------------------
-- function getContribution
-- @brief 기여도 반환
-------------------------------------
function StructUserInfoClanRaid:getContribution()
    return self.m_contribution  or 0
end

-------------------------------------
-- function getLvText
-- @brief
-------------------------------------
function StructUserInfoClanRaid:getLvText()
    local str = Str('Lv.{1}', self.m_lv)
    return str
end

-------------------------------------
-- function getUserText
-- @brief
-------------------------------------
function StructUserInfoClanRaid:getUserText()
    local str = Str('{1}', self.m_nickname)
    return str
end

-------------------------------------
-- function getRankText
-- @brief
-------------------------------------
function StructUserInfoClanRaid:getRankText()
    if (not self.m_rank) or (self.m_rank <= 0) then
        return Str('-')
    end

    return Str('{1}', comma_value(self.m_rank))
end

-------------------------------------
-- function getScoreText
-- @brief
-------------------------------------
function StructUserInfoClanRaid:getScoreText()
    -- 서버에서 스코어 없을때 -1로 옴
    local score = math_max(self.m_score, 0)
    local text = Str('{1}점', comma_value(score))
    return text
end

-------------------------------------
-- function getContributionText
-- @brief
-------------------------------------
function StructUserInfoClanRaid:getContributionText()
    local text = (self.m_contribution == 100) and '100%' or string.format('%.2f%%', self.m_contribution)
    return text
end

-------------------------------------
-- function getRewardContributionText
-- @brief 실제 보상에 적용되는 기여도 (max 8%)
-------------------------------------
function StructUserInfoClanRaid:getRewardContributionText()
    local map_contribution = g_clanRaidData.m_mapRewardContribution
    local t_contribution = map_contribution[self.m_uid]
    if (not t_contribution) then
        return '0'
    end

    local contribution = t_contribution['ratio_cur'] * 100
    local text = (contribution == 100) and '100%' or string.format('%.2f%%', contribution)
    return text
end

-------------------------------------
-- function getRewardText
-- @brief 보상 받을 클랜코인
-------------------------------------
function StructUserInfoClanRaid:getRewardText()
    local map_contribution = g_clanRaidData.m_mapRewardContribution
    local t_contribution = map_contribution[self.m_uid]
    if (not t_contribution) then
        return '0'
    end

    local clan_coin = t_contribution['reward_clan_info_cur']
    return comma_value(clan_coin)
end

