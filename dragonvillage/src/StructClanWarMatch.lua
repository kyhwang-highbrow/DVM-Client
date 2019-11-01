
-------------------------------------
-- class StructClanWarMatch
-------------------------------------
StructClanWarMatch = class({
    m_lAttackMembers = 'table', -- 방어하는 클랜원 정보
    m_lDefendMembers = 'table', -- 공격하는 클랜원 정보

    play_member_cnt = 'number',
    win_cnt = 'number',
    enemy_clan_id = 'number',
    clan_id = 'number',
    score = 'number',
})

-------------------------------------
-- function init
-------------------------------------
function StructClanWarMatch:init(data)
    if (not data) then
        return
    end

    self.m_lAttackMembers = {}
    self.m_lDefendMembers = {}

    self:makeAttackMemberList(data['a_members'])
    self:makeDefendMemberList(data['d_members'])   

    self['play_member_cnt'] = data['play_member_cnt']    
    self['win_cnt'] = data['win_cnt']
    self['enemy_clan_id'] = data['enemy_clan_id']
    self['clan_id'] = data['clan_id']        
    self['score'] = data['score']
end

-------------------------------------
-- function makeAttackMemberList
-------------------------------------
function StructClanWarMatch:makeAttackMemberList(data)
    cclog('makeAttackMemberList')
	for uid, attack_cnt in pairs(data) do
        local t_data = {}
        cclog(uid)
        t_data['uid'] = uid
        t_data['attack_cnt'] = attack_cnt
        table.insert(self.m_lAttackMembers, t_data)
    end
end

-------------------------------------
-- function makeDefendMemberList
-------------------------------------
function StructClanWarMatch:makeDefendMemberList(data)
    cclog('makeDefendMemberList')
	for uid, is_defeat in pairs(data) do
        local t_data = {}
        cclog(uid)
        t_data['uid'] = uid
        t_data['is_defeat'] = is_defeat
        table.insert(self.m_lDefendMembers, t_data)
    end	
end

-------------------------------------
-- function getDefendMembers
-------------------------------------
function StructClanWarMatch:getDefendMembers(data)
    return self.m_lDefendMembers or {}
end
