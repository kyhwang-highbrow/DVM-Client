
-------------------------------------
-- class StructClanWarMatch
-------------------------------------
StructClanWarMatch = class({
    m_tMyMatch = 'table',
    m_tEnemyMatch = 'table',
})

StructClanWarMatch.STATE_COLOR = {
    ['WIN'] = cc.c3b(0, 255, 0),
    ['LOSE'] = cc.c3b(255, 34, 34)
}

-------------------------------------
-- function init
-------------------------------------
function StructClanWarMatch:init(ret)
    self.m_tMyMatch = {}
    self.m_tEnemyMatch = {}

    if (ret['clanwar_match_info']) then
        for i, data in ipairs(ret['clanwar_match_info']) do
            local uid = data['uid']
            self.m_tMyMatch[uid] = StructClanWarMatchItem(data)
        end
    end

    if (ret['clanwar_match_info_enemy']) then
        for i, data in ipairs(ret['clanwar_match_info_enemy']) do
            local uid = data['uid']
            self.m_tEnemyMatch[uid] = StructClanWarMatchItem(data)
        end
    end

    self:makeDefendInfo(self.m_tMyMatch, self.m_tEnemyMatch)
    self:makeDefendInfo(self.m_tEnemyMatch, self.m_tMyMatch)
end

-------------------------------------
-- function getMyMatchData
-------------------------------------
function StructClanWarMatch:getMyMatchData()
    return self.m_tMyMatch
end

-------------------------------------
-- function getEnemyMatchData
-------------------------------------
function StructClanWarMatch:getEnemyMatchData()
    return self.m_tEnemyMatch
end

-------------------------------------
-- function getMatchMemberDataByUid
-------------------------------------
function StructClanWarMatch:getMatchMemberDataByUid(uid)
    if (self.m_tMyMatch[uid]) then
        return self.m_tMyMatch[uid]
    end

    if (self.m_tEnemyMatch[uid]) then
        return self.m_tEnemyMatch[uid]
    end
end

-------------------------------------
-- function makeDefendInfo
-- @breif 공격 정보 추적하여 방어 정보 세팅
-------------------------------------
function StructClanWarMatch:makeDefendInfo(t_my_struct_match, t_enemy_struct_match)  
    for uid, struct_match_item in pairs(t_my_struct_match) do
        local enemy_uid = struct_match_item:getAttackingUid() -- 공격중인 상대방
        if (enemy_uid) then
            local enemy_struct_match_item = t_enemy_struct_match[enemy_uid]
            if (enemy_struct_match_item) then
                local attacked_by_uid_state = enemy_struct_match_item:getAttackState() -- 공격정보 반대로 하면 방어 정보가 됨
                enemy_struct_match_item:setDefendInfo(uid, attacked_by_uid_state)
            end
        end
    end
end

-------------------------------------
-- function getNickNameWithAttackingEnemy
-------------------------------------
function StructClanWarMatch:getNickNameWithAttackingEnemy(struct_match_item)
    local my_nick = struct_match_item:getMyNickName() or ''
    local attcking_uid = struct_match_item:getAttackingUid()
    if (not attcking_uid) then
        return my_nick
    end

    local struct_enemy_match_item = self:getMatchMemberDataByUid(attcking_uid)
    local enemy_nick = struct_enemy_match_item:getMyNickName() or ''

     return my_nick .. ' VS ' .. enemy_nick
end

-------------------------------------
-- function getDefendEnemyNickName
-------------------------------------
function StructClanWarMatch:getDefendEnemyNickName(struct_match_item)
    local defend_enemy_uid = struct_match_item:getDefendEnemyUid()
    if (not defend_enemy_uid) then
        return ''
    end

    local struct_enemy_match_item = self:getMatchMemberDataByUid(defend_enemy_uid)
    local enemy_nick = struct_enemy_match_item:getMyNickName() or ''

    return 'VS' .. enemy_nick or ''
end
