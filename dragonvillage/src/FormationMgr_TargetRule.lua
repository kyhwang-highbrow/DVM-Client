-- FormationMgr_TargetRule

-- target_team
-- target_formation
-- target_rule

-------------------------------------
-- function sortAscending
-------------------------------------
local function sortAscending(a, b)
    if (a.m_sortValue == b.m_sortValue) then
        if (not a.m_sortRandomIdx) then
            a.m_sortRandomIdx = math_random(1, 100)
        end

        if (not b.m_sortRandomIdx) then
            b.m_sortRandomIdx = math_random(1, 100)
        end

        return (a.m_sortRandomIdx < b.m_sortRandomIdx)
    else
        return (a.m_sortValue < b.m_sortValue)
    end
end

-------------------------------------
-- function sortDescending
-------------------------------------
local function sortDescending(a, b)
    if (a.m_sortValue == b.m_sortValue) then
        if (not a.m_sortRandomIdx) then
            a.m_sortRandomIdx = math_random(1, 100)
        end

        if (not b.m_sortRandomIdx) then
            b.m_sortRandomIdx = math_random(1, 100)
        end

        return (a.m_sortRandomIdx > b.m_sortRandomIdx)
    else
        return (a.m_sortValue > b.m_sortValue)
    end
end

-------------------------------------
-- function TargetRule_getTargetList
-- @param type : target_rule( ex) 'enemy_status_atk_down' -> 'status_atk_down' )
-------------------------------------
function TargetRule_getTargetList(target_type, org_list, x, y, t_data)
    -- 모든 대상
    if (isNullOrEmpty(target_type) or target_type == 'none' or target_type == 'all') then
        return TargetRule_getTargetList_none(org_list)
    elseif (target_type == 'random') then
        return TargetRule_getTargetList_random(org_list)
    elseif (target_type == 'arena_attack') then
        return TargetRule_getTargetList_arena_attack(org_list, t_data)
    elseif (target_type == 'arena_heal') then
        return TargetRule_getTargetList_arena_heal(org_list, t_data)
    elseif (target_type == 'last_attack') then
        return TargetRule_getTargetList_lastAttack(org_list, t_data)
    elseif (target_type == 'last_under_atk') then
        return TargetRule_getTargetList_lastUnderAtk(org_list, t_data)
    elseif (target_type == 'self') then
        return TargetRule_getTargetList_self(org_list, t_data)
    elseif (pl.stringx.startswith(target_type, 'self')) then
        return TargetRule_getTargetList_selfCustom(target_type, org_list, x, y, t_data)

    elseif (target_type == 'boss') then
        return TargetRule_getTargetList_boss(org_list)
    elseif (target_type == 'dead') then
        return TargetRule_getTargetList_dead(org_list)


        -- 거리 관련
    elseif (target_type == 'distance_line') then
        return TargetRule_getTargetList_distance_line(org_list, x, y)
    elseif (target_type == 'far_line') then
        return TargetRule_getTargetList_far_line(org_list, x, y)
    elseif (target_type == 'distance_x') then
        return TargetRule_getTargetList_distance_x(org_list, x)
    elseif (target_type == 'distance_y') then
        return TargetRule_getTargetList_distance_y(org_list, y)

        -- 상태효과 관련
    elseif pl.stringx.startswith(target_type, 'status') then
        return TargetRule_getTargetList_status_effect(org_list, target_type)

        -- 스탯 관련
    elseif pl.stringx.startswith(target_type, 'def') or pl.stringx.startswith(target_type, 'atk') or pl.stringx.startswith(target_type, 'hp') or
        pl.stringx.startswith(target_type, 'aspd') or pl.stringx.startswith(target_type, 'avoid') or pl.stringx.startswith(target_type, 'cri') or
        pl.stringx.startswith(target_type, 'hit_rate') then
        return TargetRule_getTargetList_stat(org_list, target_type, t_data)

        -- 속성 관련
    elseif pl.stringx.startswith(target_type, 'earth') or pl.stringx.startswith(target_type, 'water') or pl.stringx.startswith(target_type, 'fire') or
        pl.stringx.startswith(target_type, 'light') or pl.stringx.startswith(target_type, 'dark') then
        return TargetRule_getTargetList_attr(org_list, target_type)

        -- 직군 관련
    elseif pl.stringx.startswith(target_type, 'tanker') or pl.stringx.startswith(target_type, 'dealer') or
        pl.stringx.startswith(target_type, 'supporter') or pl.stringx.startswith(target_type, 'healer') then
        return TargetRule_getTargetList_role(org_list, target_type)

        -- @kwkang 21.03.19 추가
        -- 액티브 스킬 코스트 관련
    elseif pl.stringx.startswith(target_type, 'cost1') or pl.stringx.startswith(target_type, 'cost2') or pl.stringx.startswith(target_type, 'cost3') then
        return TargetRule_getTargetList_active_cost(org_list, target_type)

    elseif (target_type == 'buff') then
        return TargetRule_getTargetList_buff(org_list)

    elseif (pl.stringx.startswith(target_type, 'debuff')) then
        local t_debuff, t_not_debuff = TargetRule_getTargetList_debuff(org_list, target_type)
        if (pl.stringx.startswith(target_type, 'debuff_not')) then
            return t_not_debuff
        else
            return t_debuff
        end

    elseif (target_type == 'front') then
        return TargetRule_getTargetList_front(org_list)

    elseif (target_type == 'back') then
        return TargetRule_getTargetList_back(org_list)

    elseif string.find(target_type, 'hero') or string.find(target_type, 'limited') then
        return TargetRule_getTargetList_category(target_type, org_list)

    elseif (pl.stringx.startswith(target_type, 'leader')) then
        return TargetRule_getTargetList_leader(org_list)

    else
        error("미구현 Target Rule!! : " .. target_type)
    end

end





-------------------------------------
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- 리스트 받아오기 구현부
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-------------------------------------
-------------------------------------
-- function TargetRule_getTargetList_none
-- @brief 모든 대상
-------------------------------------
function TargetRule_getTargetList_none(org_list)
    local t_ret = {}

    for i,v in pairs(org_list) do
        table.insert(t_ret, v)
    end

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_selfCustom
-- @brief self 이후에 추가 속성 체크가 있을 경우
-------------------------------------
function TargetRule_getTargetList_selfCustom(target_type, org_list, x, y, t_data)
    local t_ret = {}
	local self_char = t_data['self']
    local l_subType = pl.stringx.split(target_type, '_')

    if (not self_char) or (not l_subType) or (#l_subType < 2) then return t_ret end

    local l_self = TargetRule_getTargetList_self(org_list, t_data)
    local is_attached = false

    -- 서브타겟마다 한번씩 루프를 돌아 타겟을 받아온다.
    for _, subType in ipairs(l_subType) do
        if (subType ~= 'self') then
            local search_type = subType .. '_only'
            local l_target = TargetRule_getTargetList(search_type, l_self, x, y, t_data)

            cclog('타입 :: ' .. subType .. ' 조회 중')

            -- 한마리의 드래곤이 여러개 역할, 속성, 희귀도를 가질 수 없으므로 중복체크 없어도 ㄱㅊ
            for _, target in ipairs(l_target) do
                if (target == self_char) then
                	cclog(target:getName() .. ' :: 조회 성공!')
                    table.insert(t_ret, target)
                    is_attached = true
                    break
                end
            end

            if (is_attached == true) then break end
        end
    end

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_self
-- @brief 자기 자신이 1번인 아군 리스트
-------------------------------------
function TargetRule_getTargetList_self(org_list, t_data)
    local t_ret = {}
	local self_char = t_data['self']
	local t_char = table.sortRandom(table.clone(org_list))
	
	-- 자기 자신을 제일 먼저 넣는다.
	table.insert(t_ret, self_char)

    for i, char in pairs(t_char) do
		if (char ~= self_char) then
			table.insert(t_ret, char)
		end
    end

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_dead
-- @brief 사망
-------------------------------------
function TargetRule_getTargetList_dead(org_list)
    local t_ret = {}
	local t_char = table.sortRandom(table.clone(org_list))

    for i, char in pairs(t_char) do
        -- 죽는 도중이 아닌 확실히 죽은 대상만 선별
        if (char:isDead(true) and char.m_bPossibleRevive) then
            table.insert(t_ret, v)
        end

        t_ret = randomShuffle(t_ret)
    end

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_boss
-- @brief 보스
-------------------------------------
function TargetRule_getTargetList_boss(org_list)
    local t_ret = {}
	local t_char = table.sortRandom(table.clone(org_list))

    for i, char in pairs(t_char) do
		if (char and char:isBoss()) then
			table.insert(t_ret, char)
		end
    end

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_lastAttack
-- @brief 일반 공격의 타겟이 우선인 적군 리스트
-------------------------------------
function TargetRule_getTargetList_lastAttack(org_list, t_data)
    local t_ret = {}
    local last_attack_char = t_data['defender']
    local t_char = table.sortRandom(table.clone(org_list))

    table.insert(t_ret, last_attack_char)

    for i, char in pairs(t_char) do
        if (char ~= last_attack_char) then
            table.insert(t_ret, char)
        end
    end

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_lastUnderAtk
-- @brief 공격자 우선인 적군 리스트
-------------------------------------
function TargetRule_getTargetList_lastUnderAtk(org_list, t_data)
    local t_ret = {}
    local last_under_atk_char = t_data['attacker']
    local t_char = table.sortRandom(table.clone(org_list))

    table.insert(t_ret, last_under_atk_char)

    for i, char in pairs(t_char) do
        if (char ~= last_under_atk_char) then
            table.insert(t_ret, char)
        end
    end

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_distance_line
-- @brief 직선거리 가까운 대상
-------------------------------------
function TargetRule_getTargetList_distance_line(org_list, x, y)
    local t_ret = {}
    local t_sort = {}

    for i,v in pairs(org_list) do
        local v_x, v_y = v:getPosForFormation()
        v.m_sortValue = getDistance(x, y, v_x, v_y)
        v.m_sortRandomIdx = nil
        table.insert(t_sort, v)
    end

    table.sort(t_sort, sortAscending)

    for i,v in ipairs(t_sort) do
        table.insert(t_ret, v)
    end

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_far_line
-- @brief 직선거리 먼 대상
-------------------------------------
function TargetRule_getTargetList_far_line(org_list, x, y)
    local t_ret = {}
    local t_sort = {}

    for i,v in pairs(org_list) do
        local v_x, v_y = v:getPosForFormation()
        v.m_sortValue = getDistance(x, y, v_x, v_y)
        v.m_sortRandomIdx = nil
        table.insert(t_sort, v)
    end

    table.sort(t_sort, sortDescending)

    for i,v in ipairs(t_sort) do
        table.insert(t_ret, v)
    end

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_distance_x
-- @brief x축 가까운 대상
-------------------------------------
function TargetRule_getTargetList_distance_x(org_list, x)
    local t_ret = {}
    local t_sort = {}

    for i,v in pairs(org_list) do
        local v_x, v_y = v:getPosForFormation()
        v.m_sortValue = math_abs(x - v_x)
        v.m_sortRandomIdx = nil
        table.insert(t_sort, v)
    end

    table.sort(t_sort, sortAscending)

    for i,v in ipairs(t_sort) do
        table.insert(t_ret, v)
    end

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_distance_y
-- @brief y축 가까운 대상
-------------------------------------
function TargetRule_getTargetList_distance_y(org_list, y)
    local t_ret = {}
    local t_sort = {}

    for i,v in pairs(org_list) do
        v.m_sortValue = math_abs(y - v.pos.y)
        v.m_sortRandomIdx = nil
        table.insert(t_sort, v)
    end

    table.sort(t_sort, sortAscending)

    for i,v in ipairs(t_sort) do
        table.insert(t_ret, v)
    end

    return t_ret
end


-------------------------------------
-- function TargetRule_getTargetList_random
-- @brief 랜덤
-------------------------------------
function TargetRule_getTargetList_random(org_list)
    local t_ret = {}
    local t_random = {}

    if (not org_list or #org_list == 0) then
        return t_ret
    end

    for i, v in ipairs(org_list) do
        table.insert(t_random, i)
    end

    t_random = randomShuffle(t_random)

    for i, v in ipairs(t_random) do
        table.insert(t_ret, org_list[v])
    end

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_arena_attack
-- @brief 아레나에서 공격 드래그 스킬 사용시 타겟룰
-------------------------------------
function TargetRule_getTargetList_arena_attack(org_list, t_data)
    local t_ret = {}

	local self_char = t_data['self']
    local ai_type = t_data['ai_type']
    local input_type = t_data['input_type']
    local ignore = t_data['ignore'] or {}
    local all_invincibility = true

    -- 유효 생명력이 낮은 순으로 3명을 찾음
    local low_hp_1, low_hp_2, low_hp_3
    do
        local temp = TargetRule_getTargetList_effective_hp(org_list)
        low_hp_1 = temp[1]
        low_hp_2 = temp[2]
        low_hp_3 = temp[3]
    end

    -- 최전방과 최후방 유닛을 찾음
    local front = TargetRule_getTargetList_front(org_list)[1]
    local back = TargetRule_getTargetList_back(org_list)[1]

    -- 특정 직군 우선
    local role
    if (string.find(ai_type, 'role_')) then
        role = string.gsub(ai_type, 'role_', '')
    end

    -- 해제 타입인 경우 모두 무적이라도 무시
    if (ai_type == 'remove') then
        all_invincibility = false
    end
    
    -- 대상별로 우선순위를 계산
    for i, v in ipairs(org_list) do
        v.m_sortValue = 1
        v.m_sortRandomIdx = nil

        local is_invincibility = false

        -- 무적 무시가 있는 경우
        if (not ignore['protect'] and not ignore['all']) then
            is_invincibility = v:isExistStatusEffectName('barrier_protection_time')
        end
                
        -- 유효 생명력이 가장 낮은 적(+4)
        if (v == low_hp_1) then
            v.m_sortValue = v.m_sortValue + 4

        -- 유효 생명력이 두번째로 낮은 적(+2)
        elseif (v == low_hp_2) then
            v.m_sortValue = v.m_sortValue + 2

        -- 유효 생명력이 세번째로 낮은 적(+1)
        elseif (v == low_hp_3) then
            v.m_sortValue = v.m_sortValue + 1
        end

        -- 속성
        do
            local t_attr_effect, attr_synastry = v:checkAttributeCounter(self_char)
            -- 공격자 우세속성(+1)
            if (attr_synastry == 1) then
                -- 속성 공격 타입 : 공격자 우세속성 우선순위가 +3 으로 상승 
                if (ai_type == 'attack_attr') then
                    v.m_sortValue = v.m_sortValue + 3
                else
                    v.m_sortValue = v.m_sortValue + 1
                end

            -- 공격자 열세속성(-1)
            elseif (attr_synastry == -1) then
                v.m_sortValue = v.m_sortValue - 1
            end
        end

        -- 최전방(+1)
        if (v == front) then
            v.m_sortValue = v.m_sortValue + 1

        -- 최후방(-1)
        elseif (v == back) then
            v.m_sortValue = v.m_sortValue - 1
        end

        if (ai_type ~= 'remove') then
            -- 수면, 반사, 보호막(-2)
            if (v:getStatusEffect('sleep') or v:getStatusEffect('reflect') 
                or (v:getStatusEffect('barrier_protection') and not ignore['barrier'])
                ) then
                v.m_sortValue = v.m_sortValue - 2
            end

            if (not is_invincibility and not v.m_isZombie) then
                all_invincibility = false
            end

            -- 무적, 좀비(-5)
            if (is_invincibility or v.m_isZombie) then
                v.m_sortValue = v.m_sortValue - 5
            end
        end

        -- 특정 직군(+1)
        if (role and role == v:getRole()) then
            v.m_sortValue = v.m_sortValue + 1
        end

        -- 디버프 보유(+3)
        if (ai_type == 'debuff' and v:hasHarmfulStatusEffect()) then
            v.m_sortValue = v.m_sortValue + 3
        end

        -- 우선 순위 최소값 처리
        v.m_sortValue = math_max(v.m_sortValue, 1)
        
        -- 좀비나 무적의 경우 강제로 0으로 처리
        if (ai_type ~= 'remove') then
            if (is_invincibility or v.m_isZombie) then
                v.m_sortValue = 0
            end
        end

        -- 수호 상태인 경우 강제로 1로 처리
        if (v.m_guard) then
            v.m_sortValue = 1
        end

        table.insert(t_ret, v)
    end

    -- 모두 무적인 경우
    if (all_invincibility and input_type ~= 'click') then
        t_ret = {}
    else
        table.sort(t_ret, sortDescending)
    end

    -- 로그
    --[[
    if (isWin32()) then
        cclog('-------------------------------------------------------')
        cclog('[ 아레나 공격 대상 선택 우선순위 계산 결과 ]')
        for i, target in ipairs(t_ret) do
            cclog(target:getName() .. ' : ' .. target.m_sortValue)
        end
        cclog('-------------------------------------------------------')
    end
    ]]--

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_arena_heal
-- @brief 아레나에서 회복 드래그 스킬 사용시 타겟룰
-------------------------------------
function TargetRule_getTargetList_arena_heal(org_list, t_data)
    local t_ret = {}

    local self_char = t_data['self']
    local ai_type = t_data['ai_type']

    -- 체력이 낮은 순으로 정렬시킴
    t_ret = TargetRule_getTargetList_stat(org_list, 'hp_low', t_data)

    -- 대상별로 우선순위를 계산
    for i, v in ipairs(t_ret) do
        v.m_sortValue = 0
        v.m_sortRandomIdx = nil

        if (not v:isMaxHp()) then
            -- 남은 생명력이 가장 낮은 1순위(+7)
            if (i == 1) then
                v.m_sortValue = v.m_sortValue + 7
            -- 남은 생명력이 가장 낮은 2순위(+4)
            elseif (i == 2) then
                v.m_sortValue = v.m_sortValue + 4
            -- 남은 생명력이 가장 낮은 3순위(+2)
            elseif (i == 3) then
                v.m_sortValue = v.m_sortValue + 2
            -- 남은 생명력이 가장 낮은 4순위(+1)
            elseif (i == 4) then
                v.m_sortValue = v.m_sortValue + 1
            end

            -- 받는 치유량 감소(-2)
            if (v:isExistStatusEffectName('recovery_dec')) then
                v.m_sortValue = v.m_sortValue - 2
            end

            -- 좀비(-10)
            if (v.m_isZombie) then
                v.m_sortValue = v.m_sortValue - 10
            end

            -- 우선 순위 최소값을 0으로 처리
            if (v.m_sortValue < 0) then
                v.m_sortValue = 0
            end
        end
    end

    table.sort(t_ret, sortDescending)

    -- 로그
    --[[
    if (isWin32()) then
        cclog('-------------------------------------------------------')
        cclog('[ 아레나 회복 대상 선택 우선순위 계산 결과 ]')
        for i, target in ipairs(t_ret) do
            cclog(target:getName() .. ' : ' .. target.m_sortValue)
        end
        cclog('-------------------------------------------------------')
    end
    ]]--

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_effective_hp
-- @brief 유효 생명력이 낮은 순으로 정렬된 리스트를 얻음
-- @param org_list : 전체 타겟 리스트
-------------------------------------
function TargetRule_getTargetList_effective_hp(org_list)
    local t_ret = {}

    for i, v in ipairs(org_list) do
        v.m_sortValue = 0
        v.m_sortRandomIdx = nil

        -- 방어력에 따른 피해 감소율
        local reduction_ratio = CalcReductionRatio(v:getStat('def'))

        -- 생명력 값을 얻음
        local hp = v.m_isZombie and v:getMaxHp() or v:getHp()

        -- 유효 생명력 값을 얻음
        local effective_hp = hp / (1 - reduction_ratio)

        v.m_sortValue = effective_hp

        table.insert(t_ret, v)
    end

    table.sort(t_ret, sortAscending)

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_stat
-- @brief 특정 스탯에 따른 구분
-- @param org_list : 전체 타겟 리스트
-- @param stat_type : stat명_높낮이
-------------------------------------
function TargetRule_getTargetList_stat(org_list, stat_type, t_data)
	local t_ret = org_list or {}

	local temp = seperate(stat_type, '_')
	local target_stat = temp[1]
    for i = 2, (#temp - 1) do
        target_stat = target_stat .. '_' .. temp[i]
    end
	local is_descending = (temp[#temp] == 'high')

	-- 별도 로직이 필요한 정렬
	if (target_stat == 'hp') then
        local team_type = t_data['team_type']
        local is_ally = (team_type == 'ally' or team_type == 'teammate')

		table.sort(t_ret, function(a, b)
			local a_stat = a:getHpRate()
			local b_stat = b:getHpRate()

            -- 아군을 찾을 경우 좀비에 대한 예외처리
            if (is_ally) then
                if (a.m_isZombie) then a_stat = 1 end
                if (b.m_isZombie) then b_stat = 1 end
            end

			if (is_descending) then
				return a_stat > b_stat
			else
				return a_stat < b_stat
			end
		end)

	-- status Calculator를 통해 가져올수 있는 stat
	else
		table.sort(t_ret, function(a, b)
			local a_stat = a:getStat(target_stat)
			local b_stat = b:getStat(target_stat)
			if (is_descending) then
				return a_stat > b_stat
			else
				return a_stat < b_stat
			end
		end)
	end

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_role
-- @brief 해당 직업군의 리스트 반환
-------------------------------------
function TargetRule_getTargetList_role(org_list, str)
	-- 테이블을 복사한 후 무작위로 섞는다
	local t_char = table.sortRandom(table.clone(org_list))
    local t_ret = {}

    local role
    local sub_type
    
    -- 부조건 타입을 가져오기 위한 처리
    if (string.find(str, '_')) then
        role = string.gsub(str, '_.+', '')
        sub_type = string.gsub(str, '%l+_', '', 1)
    else
        role = str
    end

	-- 직업군이 같은 아이들을 추출한다
    for i = #t_char, 1, -1 do
		if (string.find(role, t_char[i]:getRole())) then
			table.insert(t_ret, t_char[i])
			table.remove(t_char, i)
		end
	end
    
    if (sub_type and sub_type ~= '' and sub_type ~= 'only') then
        -- 부조건 타입이 존재하는 경우는 무조건 only로 처리(남은 애들을 다시 담지 않음)
        t_ret = TargetRule_getTargetList(sub_type, t_ret)

    elseif(not pl.stringx.endswith(str, 'only')) then
	    -- 남은 애들도 다시 담는다.
	    for i, char in pairs(t_char) do
		    table.insert(t_ret, char)
	    end
    end

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_active_cost
-- @brief 해당 스킬 코스트를 가진 드래곤 리스트 반환 (스킬 코스트는 테이블 값으로 판단)
-------------------------------------
function TargetRule_getTargetList_active_cost(org_list, str)
	-- 테이블을 복사한 후 무작위로 섞는다
	local t_char = table.sortRandom(table.clone(org_list))
    local t_ret = {}

    -- active_cost = ('active3' OR 'active2')
    local active_cost_type
    local sub_type

    -- 부조건 타입을 가져오기 위한 처리
    if (string.find(str, '_')) then
        active_cost_type = string.gsub(str, '_.+', '')
        sub_type = string.gsub(str, '[%l%d]+_', '', 1)
    else
        active_cost_type = str
    end
    local active_cost = string.gsub(active_cost_type, 'cost', '')
    active_cost = string.gsub(active_cost_type, 'cost', '')
    active_cost = tonumber(active_cost) 

	-- 스킬 코스트가 같은 아이들을 추출한다
    for i = #t_char, 1, -1 do
        local dragon_origin_mana_cost = t_char[i]:getOriginSkillManaCost()
		if (active_cost == dragon_origin_mana_cost) then
			table.insert(t_ret, t_char[i])
			table.remove(t_char, i)
		end
	end
    
    if (sub_type and sub_type ~= '' and sub_type ~= 'only') then
        -- 부조건 타입이 존재하는 경우는 무조건 only로 처리(남은 애들을 다시 담지 않음)
        t_ret = TargetRule_getTargetList(sub_type, t_ret)

    elseif(not pl.stringx.endswith(str, 'only')) then
	    -- 남은 애들도 다시 담는다.
	    for i, char in pairs(t_char) do
		    table.insert(t_ret, char)
	    end
    end

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_attr
-- @brief 해당 속성의 리스트 반환
-------------------------------------
function TargetRule_getTargetList_attr(org_list, str)
	-- 테이블을 복사한 후 무작위로 섞는다
	local t_char = table.sortRandom(table.clone(org_list))
    local t_ret = {}

    local attr
    local sub_type
    
    -- 부조건 타입을 가져오기 위한 처리
    if (string.find(str, '_')) then
        attr = string.gsub(str, '_.+', '')
        sub_type = string.gsub(str, '%l+_', '', 1)
    else
        attr = str
    end

	-- 속성이 같은 아이들을 추출한다.
    -- index를 검사하는 와중에 remove를 하면 table의 전체 index가 바뀌기 때문에, 테이블 index를 역순으로 검사하여 
    -- 모든 구성요소들이 검사될 수 있도록 한다.
    for i = #t_char, 1, -1 do
		if (string.find(attr, t_char[i]:getAttribute())) then
			table.insert(t_ret, t_char[i])
			table.remove(t_char, i)
    	end
	end

    if (sub_type and sub_type ~= '' and sub_type ~= 'only' and sub_type ~= 'not') then
        -- 부조건 타입이 존재하는 경우는 무조건 only로 처리(남은 애들을 다시 담지 않음)
        t_ret = TargetRule_getTargetList(sub_type, t_ret)

    elseif (pl.stringx.endswith(str, 'not')) then
	    -- 남은 애들로 채운다
        t_ret = {}

	    for i, char in pairs(t_char) do
		    table.insert(t_ret, char)
	    end

    elseif (not pl.stringx.endswith(str, 'only')) then
	    -- 남은 애들도 다시 담는다.
	    for i, char in pairs(t_char) do
		    table.insert(t_ret, char)
	    end
    end

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_status_effect
-- @brief 특정 상태효과에 따른 구분
-- @param org_list : 전체 타겟 리스트
-- @param status_effect_type : status_상태효과
-------------------------------------
function TargetRule_getTargetList_status_effect(org_list, raw_str)
	-- 테이블을 복사한 후 무작위로 섞는다
    local t_char = table.sortRandom(table.clone(org_list))
	local t_ret = {}

	local temp = seperate(raw_str, '_')
    local status_effect_name = temp[2]
    if(#temp > 2) then
        for i = 3, (#temp - 1) do
           status_effect_name = status_effect_name .. '_' .. temp[i]
        end
    end
	-- 상태효과가 있다면 새로운 테이블로 옮긴다. 차곡차곡
    for i = #t_char, 1, -1 do
        if (t_char[i]:isExistStatusEffectName(status_effect_name)) then
            table.insert(t_ret, t_char[i])
			table.remove(t_char, i)
        end
    end
    
    if (not pl.stringx.endswith(raw_str, 'only')) then
	-- 남은 애들도 다시 담는다.
        for i, char in pairs(t_char) do
	        table.insert(t_ret, char)
        end
    end
    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_buff
-- @brief 특정 상태효과에 따른 구분
-------------------------------------
function TargetRule_getTargetList_buff(org_list)
	-- 테이블을 복사한 후 무작위로 섞는다
    local t_char = table.sortRandom(table.clone(org_list))
	local t_ret = {}

	-- 버프
    for i = #t_char, 1, -1 do
		if (t_char[i]:hasHelpfulStatusEffect()) then
			table.insert(t_ret, t_char[i])
			table.remove(t_char, i)
		end
	end

	-- 남은 애들도 다시 담는다.
	for i, char in pairs(t_char) do
		table.insert(t_ret, char)
	end

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_debuff
-- @brief 특정 상태효과에 따른 구분
-------------------------------------
function TargetRule_getTargetList_debuff(org_list, keyword)
	-- 테이블을 복사한 후 무작위로 섞는다
    local t_char = table.sortRandom(table.clone(org_list))
	local t_ret = {}
    local t_ret_not_harmful = {}
	-- 버프
    for i = #t_char, 1, -1 do
		if (t_char[i]:hasHarmfulStatusEffect()) then
			table.insert(t_ret, t_char[i])
			table.remove(t_char, i)
		else 
            table.insert(t_ret_not_harmful, t_char[i])
        end
	end

    if (not pl.stringx.endswith(keyword, 'only')) then
        -- 남은 애들도 다시 담는다. (남은 애들 = 디버프 걸린)
        for i, char in pairs(t_ret) do
            table.insert(t_ret_not_harmful, char)
        end

	    -- 남은 애들도 다시 담는다. (남은 애들 = 디버프 안걸린)
	    for i, char in pairs(t_char) do
		    table.insert(t_ret, char)
	    end
    end
    return t_ret, t_ret_not_harmful
end

------------------------------------- 미사용 -------------------------------------

-------------------------------------
-- function TargetRule_getTargetList_row
-- @brief 해당 열의 리스트 반환
-------------------------------------
function TargetRule_getTargetList_row(formation_type)
    local t_ret = {}

    for i,v in pairs(org_list) do
        table.insert(t_ret, v)
    end

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_front
-- @brief 
-------------------------------------
function TargetRule_getTargetList_front(org_list)
    local t_ret = {}
    local t_sort = {}

    for i,v in pairs(org_list) do
        local v_x, v_y = v:getPosForFormation()

        if (v.m_bLeftFormation) then
            v.m_sortValue = -v_x
        else
            v.m_sortValue = v_x
        end
        v.m_sortRandomIdx = nil
        table.insert(t_sort, v)
    end

    table.sort(t_sort, sortAscending)

    for i,v in ipairs(t_sort) do
        table.insert(t_ret, v)
    end

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_back
-- @brief 
-------------------------------------
function TargetRule_getTargetList_back(org_list)
    local t_ret = {}
    local t_sort = {}

    for i,v in pairs(org_list) do
        local v_x, v_y = v:getPosForFormation()

        if (v.m_bLeftFormation) then
            v.m_sortValue = v_x
        else
            v.m_sortValue = -v_x
        end
        v.m_sortRandomIdx = nil
        table.insert(t_sort, v)
    end

    table.sort(t_sort, sortAscending)

    for i,v in ipairs(t_sort) do
        table.insert(t_ret, v)
    end

    return t_ret
end

-------------------------------------
-- function TargetRule_getTargetList_category
-- @brief 드래곤 희귀도로 받아오기
-------------------------------------
function TargetRule_getTargetList_category(target_type, org_list)
    local t_ret = {}
    local l_subType = pl.stringx.split(target_type, '_')

    if (not l_subType) or (#l_subType < 1) then return t_ret end

    -- 서브타겟마다 한번씩 루프를 돌아 타겟을 받아온다.
    for _, subType in ipairs(l_subType) do
        -- 카테고리가 고유값이라 중복추가 걱정은 없음
        for _, target in ipairs(org_list) do
            if (target and target.m_charTable) then
                if (target.m_charTable['category'] and target.m_charTable['category'] == subType) then
                    table.insert(t_ret, target)
                elseif (target.m_charTable['rarity'] and target.m_charTable['rarity'] == subType) then
                    table.insert(t_ret, target)
                end
            end
        end
    end

    return t_ret
end


-------------------------------------
-- function TargetRule_getTargetList_leader
-- @brief 드래곤 리더 받아오기
-------------------------------------
function TargetRule_getTargetList_leader(org_list)
    local t_ret = {}

    if  (not g_gameScene) or 
        (not g_gameScene.m_gameWorld) or 
        (not g_gameScene.m_gameWorld.m_mUnitGroup[PHYS.HERO]) or 
        (not g_gameScene.m_gameWorld.m_mUnitGroup[PHYS.HERO]:getLeader()) then 
            return t_ret 
        end

    local leader = g_gameScene.m_gameWorld.m_mUnitGroup[PHYS.HERO]:getLeader()

    -- 받은 리스트에 리더가 있나?
    for _, target in ipairs(org_list) do
        if (leader == target) then table.insert(t_ret, target) end
    end

    return t_ret
end