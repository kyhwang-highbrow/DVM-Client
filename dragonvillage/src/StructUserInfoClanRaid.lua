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

        m_score = 'number',      -- score
        m_rank = 'number',       -- 월드 랭킹
        m_rankPercent = 'float', -- 월드 랭킹 퍼센트
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
-- function getUserText
-- @brief
-------------------------------------
function StructUserInfoClanRaid:getUserText()
    local str = Str('Lv.{1} : {2}', self.m_lv, self.m_nickname)
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