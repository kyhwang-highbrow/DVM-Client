local CONST_REDUNCTION_RATIO_P = 249

-------------------------------------
-- function DamageCalc_P
-- @brief 물리 데미지 계산
-------------------------------------
function DamageCalc_P(atk_dmg, def_pwr)
    
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
	
	if final_hit_rates > 100 then
		final_hit_rates = 100
	end

    -- 회피율 0~100 (100 이상일 경우 100% 회피)
    local avoid_chance = (100 - final_hit_rates)

    return avoid_chance
end

-------------------------------------
-- function CalcCriticalChance
-- @brief 크리티컬 발생 계산 (%)
-------------------------------------
function CalcCriticalChance(critical_chance, critical_avoid)
    return critical_chance - critical_avoid
end