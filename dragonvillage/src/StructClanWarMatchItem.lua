
-------------------------------------
-- class StructClanWarMatchItem
-------------------------------------
StructClanWarMatchItem = class({
    clan_id = 'string',
    uid = 'string',
    is_defense = 'boolean',          --: 1 or 0 방어덱 배치 여부
    attack_win = 'boolean',          --: 1 or 0 공격 승리 여부
    user_info = 'table',
    is_end = 'boolean',

    -- 공격하면 생기는 값들
    attack_uid = 'string',          --: 공격한 상대방 uid, attack_uid 값이 있으면 공격 시작한 것으로 판단
    attack_startdate = 'number',    --: 공격 시작 시간
    attack_enddate = 'number',      --: 공격 종료 시간, 3판 다 치거나, 승리하거나, 시간 초과 되었을 때 기록
    attack_game_history = 'string', --: 110 등으로 기록(1:승리, 0:패배)

    -- 방어하면 생기는 값들
    m_lDefendHistory = 'list - StructClanWarMatchItem',
})

-- 나의 공격 상태
StructClanWarMatchItem.ATTACK_STATE = {
	['ATTACKING'] = 1,
	['ATTACK_POSSIBLE'] = 2,
    ['ATTACK_SUCCESS'] = 3,
    ['ATTACK_FAIL'] = 4,
}


-- 나의 방어 상태
StructClanWarMatchItem.DEFEND_STATE = {
	['DEFEND_POSSIBLE'] = 1,
	['DEFEND_FAIL'] = 2,
    ['DEFENDING'] = 3,
    ['NO_DEFEND'] = 4, -- 방어인원이 아님
}

-------------------------------------
-- function init
-------------------------------------
function StructClanWarMatchItem:init(data)
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
        self['user_info'] = StructUserInfoClanWar:createUserInfo(data['user_info'])
		if (data['user_info']['info']) then
			if (data['user_info']['info']['last_tier']) then
				self['user_info']:setLastTier(data['user_info']['info']['last_tier'])
			end

            if (data['user_info']['info']['last_rank']) then
				self['user_info']:setLastRank(data['user_info']['info']['last_rank'])
			end
		end 
    end

    if (data['end']) then
        self['is_end'] = data['end']
    end
    
    self.m_lDefendHistory = {}
end

-------------------------------------
-- function getAttackingUid
-------------------------------------
function StructClanWarMatchItem:getAttackingUid()
    return self['attack_uid']
end

-------------------------------------
-- function getEndDate
-------------------------------------
function StructClanWarMatchItem:getEndDate() -- milisecond
    return self['attack_enddate']
end

-------------------------------------
-- function getStartDate
-------------------------------------
function StructClanWarMatchItem:getStartDate()
    return self['attack_startdate']
end

-------------------------------------
-- function isDefenseUser
-------------------------------------
function StructClanWarMatchItem:isDefenseUser()
    return self['is_defense']
end

-------------------------------------
-- function getClanId
-------------------------------------
function StructClanWarMatchItem:getClanId()
    return self['clan_id']
end

-------------------------------------
-- function getUserInfo
-------------------------------------
function StructClanWarMatchItem:getUserInfo()
    return self['user_info']
end

-------------------------------------
-- function Test
-------------------------------------
function StructClanWarMatchItem:Test(history_number)
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
function StructClanWarMatchItem:getPlayState(history_number, end_date)
    local _history_number = history_number or self['attack_game_history'] or ''
    local cur_time =  ServerTime:getInstance():getCurrentTimestampMilliseconds()
    local end_time = end_date or self:getEndDate() or 0
    local l_number = {}
    
    local l_result = pl.stringx.split(_history_number, ';')
    -- ex) 101 - 승패승
    local result = 0
    for i, res in ipairs(l_result) do
        if (res) then
            result = result + tonumber(res)
        end
    end

    if (result >= 2) then
        return StructClanWarMatchItem.ATTACK_STATE['ATTACK_SUCCESS']
    elseif (result == 1) then
        
        -- 01 
        if (cur_time < end_time) then
            return StructClanWarMatchItem.ATTACK_STATE['ATTACKING']
        end

        return StructClanWarMatchItem.ATTACK_STATE['ATTACK_FAIL']
    else
        
        -- 00 인 경우, 게임 끝나서 end_date가 내려옴 - 패배처리
        if (cur_time > end_time) then
            return StructClanWarMatchItem.ATTACK_STATE['ATTACK_FAIL']
        end

        -- 0 승/패 판정이 나지 않았다면 공격중으로 처리
        return StructClanWarMatchItem.ATTACK_STATE['ATTACKING']       
    end
end

-------------------------------------
-- function getGameResult
-------------------------------------
function StructClanWarMatchItem:getGameResult(history_number)
    local _history_number = history_number or self['attack_game_history'] or ''
    local l_number = {}

    -- ex) 101 - 승패승
    local l_result = pl.stringx.split(_history_number, ';')
    -- 경기 결과가 나왔을 경우, 남은 공격 기회는 공격 불가 처리 = -1
    -- ex) 1,1,-1 (승리했고 마지막은 공격 불가)
    if (self:isDoAllGame()) then
        for i = 1, 3 do 
            if (not l_result[i]) then
                l_result[i] = '-1'
            end
        end    
    end

    return l_result or {}
end

-------------------------------------
-- function isDoAllGame
-------------------------------------
function StructClanWarMatchItem:isDoAllGame()
    return self['is_end']
end

-------------------------------------
-- function setIsEnd
-------------------------------------
function StructClanWarMatchItem:setIsEnd(is_end)
    self['is_end'] = is_end
end

-------------------------------------
-- function setAttackHistory
-------------------------------------
function StructClanWarMatchItem:setAttackHistory(history)
    self['attack_game_history'] = history
end

-------------------------------------
-- function setEndDate
-------------------------------------
function StructClanWarMatchItem:setEndDate(attack_enddate)
    self['attack_enddate'] = attack_enddate
end

-------------------------------------
-- function getAttackState
-------------------------------------
function StructClanWarMatchItem:getAttackState()
    if (not self:getAttackingUid()) then
        return StructClanWarMatchItem.ATTACK_STATE['ATTACK_POSSIBLE']
    end

    return self:getPlayState()
end

-------------------------------------
-- function getDefendStateText
-------------------------------------
function StructClanWarMatchItem:getDefendStateText(defend_state)
    local _defend_state = defend_state or self:getDefendState()
    if (_defend_state == StructClanWarMatchItem.DEFEND_STATE['DEFEND_POSSIBLE']) then
        return ''
    elseif (_defend_state == StructClanWarMatchItem.DEFEND_STATE['DEFEND_FAIL']) then
        return '패배'
    elseif (_defend_state == StructClanWarMatchItem.DEFEND_STATE['DEFENDING']) then
        return '전투 중'
    elseif (_defend_state == StructClanWarMatchItem.DEFEND_STATE['NO_DEFEND']) then
        return '열외'
    end

    return ''
end

-------------------------------------
-- function getDefendStateNotiText
-------------------------------------
function StructClanWarMatchItem:getDefendStateNotiText(defend_state)
    local _defend_state = defend_state or self:getDefendState()
    if (_defend_state == StructClanWarMatchItem.DEFEND_STATE['DEFEND_POSSIBLE']) then
        return ''
    elseif (_defend_state == StructClanWarMatchItem.DEFEND_STATE['DEFEND_FAIL']) then
        return '이미 패배한 클랜원입니다.'
    elseif (_defend_state == StructClanWarMatchItem.DEFEND_STATE['DEFENDING']) then
        return '전투 중인 클랜원입니다.'
    elseif (_defend_state == StructClanWarMatchItem.DEFEND_STATE['NO_DEFEND']) then
        return '열외 클랜원은 공격할 수 없습니다.'
    end

    return ''
end

-------------------------------------
-- function getAttackStateText
-------------------------------------
function StructClanWarMatchItem:getAttackStateText(attack_state)
    local _attack_state = attack_state or self:getAttackState()
    if (_attack_state == StructClanWarMatchItem.ATTACK_STATE['ATTACK_POSSIBLE']) then
        return '공격 안함'
    elseif (_attack_state == StructClanWarMatchItem.ATTACK_STATE['ATTACKING']) then
        return '전투 중'
    elseif (_attack_state == StructClanWarMatchItem.ATTACK_STATE['ATTACK_SUCCESS']) then
        return '승리'
    elseif (_attack_state == StructClanWarMatchItem.ATTACK_STATE['ATTACK_FAIL']) then
        return '패배'
    end

    return '공격 안함'
end

-------------------------------------
-- function getDefendState
-------------------------------------
function StructClanWarMatchItem:getDefendState(enemy_attack_state)
    if (not self:isDefenseUser()) then
        return StructClanWarMatchItem.DEFEND_STATE['NO_DEFEND']
    end

    if (not enemy_attack_state) then
        local struct_match_item = self:getLastDefender()
        if (struct_match_item) then
            enemy_attack_state = struct_match_item:getAttackState()
        else
            return StructClanWarMatchItem.DEFEND_STATE['DEFEND_POSSIBLE']
        end
    end

    if (enemy_attack_state) then
        if (enemy_attack_state == StructClanWarMatchItem.ATTACK_STATE['ATTACKING']) then
            return StructClanWarMatchItem.DEFEND_STATE['DEFENDING']
        elseif (enemy_attack_state == StructClanWarMatchItem.ATTACK_STATE['ATTACK_SUCCESS']) then
            return StructClanWarMatchItem.DEFEND_STATE['DEFEND_FAIL']
        end
    end

    return StructClanWarMatchItem.DEFEND_STATE['DEFEND_POSSIBLE']
end

-------------------------------------
-- function getMyNickName
-------------------------------------
function StructClanWarMatchItem:getMyNickName()
    local struct_user_info_clan = self:getUserInfo()
    if (not struct_user_info_clan) then
        return
    end

    local user_nick_name = struct_user_info_clan:getNickname() or ''
    return user_nick_name
end

-------------------------------------
-- function setGameResult
-------------------------------------
function StructClanWarMatchItem:setGameResult(is_win)
    local game_result = ''
    if (self['attack_game_history']) then
        game_result = self['attack_game_history'] .. ';'
    end

	if (is_win) then
		game_result = game_result .. '1'
	else
		game_result = game_result .. '0'
	end

	self['attack_game_history'] = game_result
end

-------------------------------------
-- function getDefendCount
-------------------------------------
function StructClanWarMatchItem:getDefendCount()
    local l_defend = self:getDefendHistoryList()
    local defend_cnt = 0
    for _, struct_match_item in ipairs(l_defend) do
        local attack_state = struct_match_item:getAttackState()
        if (attack_state == StructClanWarMatchItem.ATTACK_STATE['ATTACK_FAIL']) then
            defend_cnt = defend_cnt + 1
        end
    end
    return defend_cnt
end


-------------------------------------
-- function setDefendHistory
-------------------------------------
function StructClanWarMatchItem:setDefendHistory(l_defend_enemy_struct_match_item)
    local sort_func = function(a, b)
        local a_end_date = a['attack_enddate'] or 0
        local b_end_date = b['attack_enddate'] or 0
        return a_end_date < b_end_date
    end

    table.sort(l_defend_enemy_struct_match_item, sort_func)
    self.m_lDefendHistory = l_defend_enemy_struct_match_item
end

-------------------------------------
-- function getDefendHistoryList
-------------------------------------
function StructClanWarMatchItem:getDefendHistoryList()
     return self.m_lDefendHistory
end

-------------------------------------
-- function getLastDefender
-------------------------------------
function StructClanWarMatchItem:getLastDefender()
    local last_idx = #self.m_lDefendHistory
    return self.m_lDefendHistory[last_idx]
end

-------------------------------------
-- function getRemainEndTimeText
-------------------------------------
function StructClanWarMatchItem:getRemainEndTimeText()
    local cur_time = ServerTime:getInstance():getCurrentTimestampMilliseconds()
    local end_time = self:getEndDate()
    if (not end_time) then
        return ''
    end
    
    local remain_time = (end_time - cur_time)
    if (remain_time > 0) then
        return datetime.makeTimeDesc_timer_filledByZero(remain_time)
    end 

    return ''
end

