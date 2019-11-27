
-------------------------------------
-- class StructClanWarMatch
-------------------------------------
StructClanWarMatch = class({
    m_tMyMatch = 'table',
    m_tEnemyMatch = 'table',
})

StructClanWarMatch.STATE_COLOR = {
    ['WIN'] = cc.c3b(0, 255, 0),
    ['LOSE'] = cc.c3b(255, 34, 34),
    ['DEFAULT'] = cc.c3b(0, 0, 0),
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
-- function isGhostClan
-------------------------------------
function StructClanWarMatch:isGhostClan(t_clan)
    local struct_match_item
    for _, v in pairs(self:getEnemyMatchData()) do
        struct_match_item = v
        break
    end

    if (not struct_match_item) then
        return true
    end

    local clan_id = struct_match_item:getClanId()
    if (not clan_id) then
        return true
    end

    if (clan_id == 'loser') then
        return true
    end

    return false
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
    local t_defend_history = {}
    for uid, struct_match_item in pairs(t_my_struct_match) do
        local enemy_uid = struct_match_item:getAttackingUid() -- 공격중인 상대방
        if (enemy_uid) then
            local enemy_struct_match_item = t_enemy_struct_match[enemy_uid]
            if (enemy_struct_match_item) then
				local attack_state = struct_match_item:getAttackState()
                if (not t_defend_history[enemy_uid]) then
                    t_defend_history[enemy_uid] = {}
                end 
                table.insert(t_defend_history[enemy_uid], struct_match_item)
            end
        end
    end

    for uid, l_data in pairs(t_defend_history) do
        local struct_match_item = self:getMatchMemberDataByUid(uid)
        struct_match_item:setDefendHistory(l_data)
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

    if (not struct_enemy_match_item) then
        return my_nick
    end

    local enemy_nick = struct_enemy_match_item:getMyNickName() or ''

     return my_nick, enemy_nick
end

-------------------------------------
-- function getDefendEnemyNickName
-------------------------------------
function StructClanWarMatch:getDefendEnemyNickName(struct_match_item)
    local struct_enemy_match_item = struct_match_item:getLastDefender()
    if (not struct_enemy_match_item) then
        return ''
    end

    local enemy_nick = struct_enemy_match_item:getMyNickName() or ''

    return 'VS' .. enemy_nick or ''
end

-------------------------------------
-- function getAttackMemberCnt
-------------------------------------
function StructClanWarMatch:getAttackMemberCnt(t_clanwar)
    if (not t_clanwar) then
        return 0, 0
    end

    local max_cnt = 0
    local attack_cnt = 0
    for i, struct_match_item in pairs(t_clanwar) do
        if (struct_match_item:getAttackingUid()) then
            attack_cnt = attack_cnt + 1
        end
        max_cnt = max_cnt + 1
    end

    return attack_cnt, max_cnt
end

-------------------------------------
-- function getStateMemberCnt
-- @breif 해당 공격타입에 해당하는 맴버가 몇명인지
-------------------------------------
function StructClanWarMatch:getStateMemberCnt(t_clanwar, state)
    if (not t_clanwar) then
        return 0, 0
    end

    local max_cnt = 0
    local attack_cnt = 0
    for i, struct_match_item in pairs(t_clanwar) do
        if (struct_match_item:getAttackState() == state) then
            attack_cnt = attack_cnt + 1
        end
        max_cnt = max_cnt + 1
    end

    return attack_cnt, max_cnt
end

-------------------------------------
-- function getAttackableEnemyData
-- @breif 상대 클랜에 공격 가능한 인원이 없을 경우
-------------------------------------
function StructClanWarMatch:getAttackableEnemyData()
   local t_enemy = self:getEnemyMatchData()
   local l_enemy = {}

   -- 공격 가능한 리스트 추출 (방어덱 없는 유저x, 방어 실패한 유저x)
   for _, struct_match_item in pairs(t_enemy) do       
       local defend_state = struct_match_item:getDefendState()
       if (defend_state ~= StructClanWarMatchItem.DEFEND_STATE['NO_DEFEND']) and (defend_state ~= StructClanWarMatchItem.DEFEND_STATE['DEFEND_FAIL']) then
           table.insert(l_enemy, struct_match_item)
       end
   end

   return l_enemy or {}
end