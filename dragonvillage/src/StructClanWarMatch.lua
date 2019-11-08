
-------------------------------------
-- class StructClanWarMatch
-------------------------------------
StructClanWarMatch = class({
    clan_id = 'string',
    uid = 'string',
    is_defense = 'boolean',          --: 1 or 0 방어덱 배치 여부
    attack_win = 'boolean',          --: 1 or 0 공격 승리 여부
    user_info = 'table',

    -- 공격하면 생기는 값들
    attack_uid = 'string',          --: 공격한 상대방 uid, attack_uid 값이 있으면 공격 시작한 것으로 판단
    attack_startdate = 'number',    --: 공격 시작 시간
    attack_enddate = 'number',      --: 공격 종료 시간, 3판 다 치거나, 승리하거나, 시간 초과 되었을 때 기록
    attack_game_history = 'string', --: 110 등으로 기록(1:승리, 0:패배)

    -- 방어하면 생기는 값들
    enemy_info = 'string', -- 공격한 유저 user_info
    enemy_attack_state = 'StructClanWarMatch.DEFEND_STATE', -- 공격한 유저의 상태
})

-- 나의 공격 상태
StructClanWarMatch.ATTACK_STATE = {
	['ATTACKING'] = 1,
	['ATTACK_POSSIBLE'] = 2,
    ['ATTACK_SUCCESS'] = 3,
    ['ATTACK_FAIL'] = 4,
}


-- 나의 방어 상태
StructClanWarMatch.DEFEND_STATE = {
	['DEFEND_POSSIBLE'] = 1,
	['DEFEND_FAIL'] = 2,
    ['DEFENDING'] = 3,
    ['NO_DEFEND'] = 4, -- 방어인원이 아님
}

-------------------------------------
-- function init
-------------------------------------
function StructClanWarMatch:init(data)
    if (data['clan_id']) then
        self['clan_id'] = data['clan_id']
    end

    if (data['uid']) then
        self['uid'] = data['uid']
    end

    if (data['is_defense']) then
        self['is_defense'] = data['is_defense']
    end

    if (data['attack_win']) then
        self['attack_win'] = data['attack_win']
    end

    if (data['attack_uid']) then
        self['attack_uid'] = data['attack_uid']
    end

    if (data['attack_startdate']) then
        self['attack_startdate'] = data['attack_startdate']
    end

    if (data['attack_enddate']) then
        self['attack_enddate'] = data['attack_enddate']
    end

    if (data['attack_game_history']) then
        self['attack_game_history'] = data['attack_game_history']
    end

    if (data['user_info']) then
        self['user_info'] = StructUserInfoClan:create(data['user_info'])
    end
end

-------------------------------------
-- function getAttackedTargetUid
-------------------------------------
function StructClanWarMatch:getAttackedTargetUid()
    return self['attack_uid']
end

-------------------------------------
-- function getEndDate
-------------------------------------
function StructClanWarMatch:getEndDate()
    return self['attack_enddate']
end

-------------------------------------
-- function isDefenseUser
-------------------------------------
function StructClanWarMatch:isDefenseUser()
    return self['is_defense']
end

-------------------------------------
-- function getClanId
-------------------------------------
function StructClanWarMatch:getClanId()
    return self['clan_id']
end

-------------------------------------
-- function getUserInfo
-------------------------------------
function StructClanWarMatch:getUserInfo()
    return self['user_info']
end

-------------------------------------
-- function Test
-------------------------------------
function StructClanWarMatch:Test(history_number)
    local l_test = {0, 1, 01, 10, 11, 100, 101, 110, 111, 001, 010, 011, 000}
    for _, number in ipairs(l_test) do
        
        cclog('======= nuber : ', number)
        cclog('======= 공격 상태 =======')
        local is_enddate
        if (number == 11 or number == 00 or number == 000 or number == 110 or number == 111) then
            is_enddate = true
        end
        local state = self:getPlayState(number, is_enddate)
        cclog(self:getAttackStateText(state))

        cclog('======= 방어 상태 =======')
        local defend_state = self:getDefendState(state)
        cclog(self:getDefendStateText(defend_state))
    end
end

-------------------------------------
-- function getPlayState
-------------------------------------
function StructClanWarMatch:getPlayState(history_number, end_date)
    local _history_number = history_number or self['attack_game_history'] or 0
    local _end_date = end_date or self:getEndDate()
    local l_number = {}
    

    -- ex) 101 - 승패승
    local result = 0
    for i = 1, 3 do
        result = result + _history_number%10
        _history_number = math.floor(_history_number/10)
    end

    if (result >= 2) then
        return StructClanWarMatch.ATTACK_STATE['ATTACK_SUCCESS']
    elseif (result == 1) then
        
        -- 01 승/패 판정이 나지 않은 상황에서 시간이 초과되어 endDate가 내려올 경우 패배 처리
        if (not _end_date) then
            return StructClanWarMatch.ATTACK_STATE['ATTACKING']
        end

        -- 01 승/패 판정이 나지 않았다면 공격중으로 처리
        return StructClanWarMatch.ATTACK_STATE['ATTACK_FAIL']
    else
        
        -- 00 인 경우, 게임 끝나서 end_date가 내려옴 - 패배처리
        if (_end_date) then
            return StructClanWarMatch.ATTACK_STATE['ATTACK_FAIL']
        end

        -- 0 승/패 판정이 나지 않았다면 공격중으로 처리
        return StructClanWarMatch.ATTACK_STATE['ATTACKING']       
    end
end

-------------------------------------
-- function getAttackState
-------------------------------------
function StructClanWarMatch:getAttackState()
    if (not self:getAttackedTargetUid()) then
        return StructClanWarMatch.ATTACK_STATE['ATTACK_POSSIBLE']
    end

    return self:getPlayState()
end

-------------------------------------
-- function getDefendStateText
-------------------------------------
function StructClanWarMatch:getDefendStateText(defend_state)
    if (defend_state == StructClanWarMatch.DEFEND_STATE['DEFEND_POSSIBLE']) then
        return '보통'
    elseif (defend_state == StructClanWarMatch.DEFEND_STATE['DEFEND_FAIL']) then
        return '패배'
    elseif (defend_state == StructClanWarMatch.DEFEND_STATE['DEFENDING']) then
        return '전투 중'
    elseif (defend_state == StructClanWarMatch.DEFEND_STATE['NO_DEFEND']) then
        return '열외'
    end

    return '보통'
end

-------------------------------------
-- function getAttackStateText
-------------------------------------
function StructClanWarMatch:getAttackStateText(attack_state)
    local _attack_state = attack_state or self:getAttackState()
    if (_attack_state == StructClanWarMatch.ATTACK_STATE['ATTACK_POSSIBLE']) then
        return '공격 안함'
    elseif (_attack_state == StructClanWarMatch.ATTACK_STATE['ATTACKING']) then
        return '전투 중'
    elseif (_attack_state == StructClanWarMatch.ATTACK_STATE['ATTACK_SUCCESS']) then
        return '승리'
    elseif (_attack_state == StructClanWarMatch.ATTACK_STATE['ATTACK_FAIL']) then
        return '패배'
    end

    return '공격 안함'
end

-------------------------------------
-- function getDefendState
-------------------------------------
function StructClanWarMatch:getDefendState(enemy_attack_state)
    local _enemy_attack_state =  enemy_attack_state or self['enemy_attack_state']
    if (not self:isDefenseUser()) then
        return StructClanWarMatch.DEFEND_STATE['NO_DEFEND']
    end
    
    if (enemy_attack_state) then
        if (enemy_attack_state == StructClanWarMatch.ATTACK_STATE['ATTACKING']) then
            return StructClanWarMatch.DEFEND_STATE['DEFENDING']
        elseif (enemy_attack_state == StructClanWarMatch.ATTACK_STATE['ATTACK_SUCCESS']) then
            return StructClanWarMatch.DEFEND_STATE['DEFEND_FAIL']
        end
    end

    return StructClanWarMatch.DEFEND_STATE['DEFEND_POSSIBLE']
end

-------------------------------------
-- function setDefendInfo
-------------------------------------
function StructClanWarMatch:setDefendInfo(enemy_info, enemy_attack_state)
    self['enemy_info'] = enemy_info
    self['enemy_attack_state'] = enemy_attack_state
end

-------------------------------------
-- function getEnemyInfo
-------------------------------------
function StructClanWarMatch:getEnemyInfo()
    return self['enemy_info']
end

-------------------------------------
-- function setVsText
-------------------------------------
function StructClanWarMatch:getNameTextWithEnemy(enemy_uid, enemy_attack_state)
    local struct_user_info_clan = self:getUserInfo()
    if (not struct_user_info_clan) then
        return
    end

    local user_nick_name = struct_user_info_clan:getNickname() or ''
    local enemy_info = self:getEnemyInfo() -- StructUserInfoClan
    if (enemy_info) then
        local enemy_nick_name = enemy_info:getNickname()
        return user_nick_name .. ' VS ' .. enemy_nick_name
    end
    return user_nick_name
end

-------------------------------------
-- function makeDefendInfo
-- @breif 공격 정보 추적하여 방어 정보 리턴
-------------------------------------
function StructClanWarMatch.makeDefendInfo(t_my_struct_match, t_enemy_struct_match)  
    for uid, struct_match in pairs(t_my_struct_match) do
        local enemy_uid = struct_match:getAttackedTargetUid() -- 공격중인 상대방
        if (enemy_uid) then
            local enemy_struct_match = t_enemy_struct_match[enemy_uid]
            if (enemy_struct_match) then
                local enemy_attack_state = enemy_struct_match:getAttackState() -- 공격정보 반대로 하면 방어 정보가 됨
                local enemy_info = enemy_struct_match:getUserInfo()
                struct_match:setDefendInfo(enemy_info, enemy_attack_state)
            end
        end
    end

    return t_my_struct_match
end



