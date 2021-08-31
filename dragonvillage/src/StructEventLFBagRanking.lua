local PARENT = StructUserInfo
-- {
--     "lv":10,
--     "tier":"bronze_3",
--     "clan_info":{
--       "mark":"4;4;1;25",
--       "name":"하이브로",
--       "id":"5a0b918ee891934ac6127cc2"
--     },
--     "tamer":110002,
--     "costume":730205,
--     "rp":3599620,
--     "challenge_score":0,
--     "clear_time":0,
--     "rate":0.00098135427106172,
--     "last_tier":"beginner",
--     "arena_score":0,
--     "ancient_score":0,
--     "beginner":false,
--     "un":6284,
--     "score":0,
--     "total":1019,
--     "nick":"dvm100979",
--     "leader":{
--       "lv":60,
--       "mastery_lv":0,
--       "grade":6,
--       "rlv":6,
--       "eclv":0,
--       "did":120102,
--       "transform":3,
--       "mastery_skills":{
--       },
--       "evolution":3,
--       "mastery_point":0
--     },
--     "uid":"ochoi1",
--     "rank":1
--   }
-------------------------------------
-- class StructEventLFBagRanking
-- @brief 소원 구슬
-------------------------------------
StructEventLFBagRanking = class(PARENT, {
        m_rp = 'number',         -- ranking point
        m_rank = 'number',       -- 월드 랭킹
        m_rankPercent = 'float',-- 월드 랭킹 퍼센트
    })


-------------------------------------
-- function init
-------------------------------------
function StructEventLFBagRanking:init()
    self.m_rp = 0
    self.m_rank = 0
    self.m_rankPercent = 0
end

-------------------------------------
-- function apply
-- @brief 
-------------------------------------
function StructEventLFBagRanking:apply(t_data)
    self.m_uid = t_data['uid']
    self.m_nickname = t_data['nick']
    self.m_lv = t_data['lv']
    self.m_rank = t_data['rank']
    self.m_rankPercent = t_data['rate']
    self.m_rp = t_data['rp']

    self.m_leaderDragonObject = StructDragonObject(t_data['leader'])

    if (t_data['clan_info']) then
        local struct_clan = StructClan({})
        struct_clan:applySimple(t_data['clan_info'])
        self:setStructClan(struct_clan)
    end

    return self
end

-------------------------------------
-- function getUserText
-------------------------------------
function StructEventLFBagRanking:getUserText()
        local str
    if self.m_lv and (0 < self.m_lv) then
        str = Str('Lv.{1} {2}', self.m_lv, self.m_nickname)
    else
        str = self.m_nickname
    end
    return str
end

-------------------------------------
-- function getRankStr
-------------------------------------
function StructEventLFBagRanking:getRankStr()
    if (self.m_rank == 0) then
        return '-'
    else
        return Str('{1}위', comma_value(self.m_rank))
    end
end

-------------------------------------
-- function getScoreStr
-------------------------------------
function StructEventLFBagRanking:getScoreStr()
    local rp = self.m_rp
    if (rp <= 0) then
        rp = 0
    end
    return Str('{1}점', comma_value(rp))
end