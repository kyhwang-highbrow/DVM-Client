local PARENT = StructUserInfo

-------------------------------------
-- class StructEventLFBagRanking
-- @brief 복주머니
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