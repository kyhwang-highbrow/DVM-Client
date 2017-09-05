local CONST_REDUNCTION_RATIO_P = 249

-------------------------------------
-- function DamageCalc_P
-- @brief 물리 데미지 계산
-------------------------------------
function DamageCalc_P(atk_dmg, def_pwr)
    if (atk_dmg == 0 and def_pwr == 0) then return 0 end
    
    -- 물리 공격력
    local atk_dmg = atk_dmg

    -- 랜덤 (85% ~ 115%)
    local rand = math_random(85, 115) / 100 

    -- 데미지 감소율
    local reduction_ratio = ReductionRatioCalc_P(atk_dmg)

    -- 모든 계수를 곱함
    local damage = rand * (atk_dmg * (reduction_ratio + def_pwr) / (reduction_ratio + (251 * def_pwr)))
	
	return damage
	
end

-------------------------------------
-- function ReductionRatioCalc_P
-- @brief 물리 데미지 감소율 계산
-------------------------------------
function ReductionRatioCalc_P(atk_dmg)
    local reduction_ratio = atk_dmg * CONST_REDUNCTION_RATIO_P
    return reduction_ratio
end


-------------------------------------
-- function ReductionRatioCalc_M
-- @brief 마법 데미지 감소율 계산
-------------------------------------
function ReductionRatioCalc_M(atk_dmg)
    local reduction_ratio = atk_dmg * CONST_REDUNCTION_RATIO_P
    return reduction_ratio
end


-------------------------------------
-- function HealCalc_M
-- @brief 회복량 계산
-------------------------------------
function HealCalc_M(atk_dmg)
    
    -- 물리 공격력
    local atk_dmg = atk_dmg

    -- 랜덤 (85% ~ 115%)
    local rand = math_random(85, 115) / 100 

    -- 모든 계수를 곱함
    local damage = atk_dmg * rand

    return damage
end


-------------------------------------
-- function CalcAvoidChance
-- @brief 회피 발생 계산 (%)
-------------------------------------
function CalcAvoidChance(hit_rate, avoid)
    -- 최종 적중률 100 이상일 경우 100% 적중
    local final_hit_rates = hit_rate - avoid

    local min_value = g_constant:get('INGAME', 'FINAL_RATE_HIT')[1]
    local max_value = g_constant:get('INGAME', 'FINAL_RATE_HIT')[2]
    final_hit_rates = math_max(final_hit_rates, min_value)
    final_hit_rates = math_min(final_hit_rates, max_value)
    	
	-- 회피율 0~100 (100 이상일 경우 100% 회피)
    local avoid_chance = (100 - final_hit_rates)
    avoid_chance = math_max(avoid_chance, 0)

    return avoid_chance
end

-------------------------------------
-- function CalcCriticalChance
-- @brief 크리티컬 발생 계산 (%)
-------------------------------------
function CalcCriticalChance(critical_chance, critical_avoid)
    local value = critical_chance - critical_avoid

    local min_value = g_constant:get('INGAME', 'FINAL_RATE_CRITICAL')[1]
    local max_value = g_constant:get('INGAME', 'FINAL_RATE_CRITICAL')[2]
    value = math_max(value, min_value)
    value = math_min(value, max_value)
    
    return value
end

-------------------------------------
-- function CalcAttackTick
-- @brief 공격 주기 계산 (초)
-------------------------------------
function CalcAttackTick(attack_speed)
    local value = 3 - (2 * ((attack_speed - 100) / 100))

    local min_value = g_constant:get('INGAME', 'FINAL_ATTACK_TICK')[1]
    local max_value = g_constant:get('INGAME', 'FINAL_ATTACK_TICK')[2]
    value = math_max(value, min_value)
    value = math_min(value, max_value)

    return value
end

-------------------------------------
-- function CalcAccuracyChance
-- @brief 효과 적중 계산 (%)
-------------------------------------
function CalcAccuracyChance(accuracy, resistance)
    local value = accuracy - resistance + 100

    local min_value = g_constant:get('INGAME', 'FINAL_RATE_ACCURACY')[1]
    local max_value = g_constant:get('INGAME', 'FINAL_RATE_ACCURACY')[2]
    value = math_max(value, min_value)
    value = math_min(value, max_value)

    return value
end

-------------------------------------
-- function CalcDamageRateDueToFormation
-- @brief 진형에 따른 데미지 배율 계산
-------------------------------------
function CalcDamageRateDueToFormation(unit)
    local world = unit.m_world

    local formation_mgr = unit:getFormationMgr(false)
    local damage_rate = 1

    -- 전방 유닛이 있을 경우 후방 유닛 데미지 감소 처리
    if (formation_mgr:isFrontLineAlive() and not formation_mgr:isFrontLine(unit)) then
        if (unit.m_bLeftFormation or world.m_gameMode == GAME_MODE_COLOSSEUM) then
            damage_rate = damage_rate * g_constant:get('INGAME', 'COVER_COEF')
        end
    end

    return damage_rate
end

-------------------------------------
-- function CalcDamageRateDueToGameMode
-- @brief 게임 모드에 따른 데미지 배율 계산
-------------------------------------
function CalcDamageRateDueToGameMode(unit)
    local world = unit.m_world

    local damage_rate = 1

    -- 콜로세움에서 모든 데미지 배수 조정
    if (world.m_gameMode == GAME_MODE_COLOSSEUM) then
        damage_rate = damage_rate * g_constant:get('INGAME', 'COLOSSEUM_DAMAGE_MULTI')
    end

    return damage_rate
end