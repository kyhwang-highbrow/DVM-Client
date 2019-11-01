
-------------------------------------
-- class StructClanWarMatch
-------------------------------------
StructClanWarMatch = class({
    m_lAttackMembers = 'list', -- 방어하는 클랜원 정보
    m_lDefendMembers = 'list', -- 공격하는 클랜원 정보
    m_tMemberInfo = 'table',

    play_member_cnt = 'number',
    win_cnt = 'number',
    enemy_clan_id = 'number',
    clan_id = 'string',
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
    self.m_tMemberInfo = {}

    self:setAttackMemberMatchInfo(data['a_members'])
    self:setDefendMemberMatchInfo(data['d_members'])

    self:setClanMemberInfo(data['a_member_infos'])
    self:setClanMemberInfo(data['d_member_infos'])  

    self['play_member_cnt'] = data['play_member_cnt']    
    self['win_cnt'] = data['win_cnt']
    self['enemy_clan_id'] = data['enemy_clan_id']
    self['clan_id'] = data['clan_id']        
    self['score'] = data['score']
end

-------------------------------------
-- function setAttackMemberMatchInfo
-------------------------------------
function StructClanWarMatch:setAttackMemberMatchInfo(data)
	for uid, attack_cnt in pairs(data) do
        local t_data = {}
        t_data['uid'] = uid
        t_data['attack_cnt'] = attack_cnt
        table.insert(self.m_lAttackMembers, t_data)
    end
end

-------------------------------------
-- function setDefendMemberMatchInfo
-------------------------------------
function StructClanWarMatch:setDefendMemberMatchInfo(data)
	for uid, is_defeat in pairs(data) do
        local t_data = {}
        t_data['uid'] = uid
        t_data['is_defeat'] = is_defeat
        table.insert(self.m_lDefendMembers, t_data)
    end	
end

-------------------------------------
-- function setClanMemberInfo
-------------------------------------
function StructClanWarMatch:setClanMemberInfo(l_member)
	for idx, t_data in pairs(l_member) do
        local uid = t_data['uid']
        self.m_tMemberInfo[uid] = StructUserInfoClan:create(t_data)
    end	
end

-------------------------------------
-- function getDefendMembers
-------------------------------------
function StructClanWarMatch:getDefendMembers()
    return self.m_lDefendMembers or {}
end

-------------------------------------
-- function getClanMembersInfo
-------------------------------------
function StructClanWarMatch:getClanMembersInfo(uid)
    return self.m_tMemberInfo[uid]
end

-------------------------------------
-- function getClanId
-------------------------------------
function StructClanWarMatch:getClanId()
    return self['clan_id']
end

-------------------------------------
-- function getWinCnt
-------------------------------------
function StructClanWarMatch:getWinCnt()
    return self['win_cnt']
end
