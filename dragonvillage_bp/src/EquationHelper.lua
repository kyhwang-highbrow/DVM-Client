-------------------------------------
-- table EquationHelper
-------------------------------------
EquationHelper = {}

EV_HIT_TARGET_COUNT = 'hit_target_count'
EV_BOSS_RARITY = 'boss_rarity'
EV_DIED_ALLY_COUNT = 'died_ally_count'

----------------------------------------------------------------------------------
-- 스킬 관련 수식에서 사용하기 위한 값을 맵에 추가(공격자와 방어자의 정보를 제외한 모두)
----------------------------------------------------------------------------------
function EquationHelper:setEquationParamOnMapForSkill(target_map, skill_entity)
    local world = skill_entity.m_world

    if (isInstanceOf(skill_entity, Skill)) then
        if (skill_entity.m_lTargetChar) then
            target_map[EV_HIT_TARGET_COUNT] = #skill_entity.m_lTargetChar
        end
    end

    if (world.m_waveMgr.m_currWave == world.m_waveMgr.m_maxWave) then
        target_map[EV_BOSS_RARITY] = world.m_waveMgr.m_highestRarity
    end

    if (skill_entity.m_owner.m_bLeftFormation) then
        target_map[EV_DIED_ALLY_COUNT] = #world.m_leftNonparticipants
    else
        target_map[EV_DIED_ALLY_COUNT] = #world.m_rightNonparticipants
    end
end

----------------------------------------------------------------------------------
-- 상태효과 관련 수식에서 사용하기 위한 값을 맵에 추가(공격자와 방어자의 정보를 제외한 모두)
----------------------------------------------------------------------------------
function EquationHelper:setEquationParamOnMapForStatusEffect(target_map, status_effect_entity)
    local world = status_effect_entity.m_owner.m_world
    local org_map = status_effect_entity.m_tParam

    target_map[EV_HIT_TARGET_COUNT] = org_map[EV_HIT_TARGET_COUNT]
    
    if (world.m_waveMgr.m_currWave == world.m_waveMgr.m_maxWave) then
        target_map[EV_BOSS_RARITY] = world.m_waveMgr.m_highestRarity
    end

    if (status_effect_entity.m_owner.m_bLeftFormation) then
        target_map[EV_DIED_ALLY_COUNT] = #world.m_leftNonparticipants
    else
        target_map[EV_DIED_ALLY_COUNT] = #world.m_rightNonparticipants
    end
end

----------------------------------------------------------------------------------
-- 수식에서 사용하기 위한 전역 함수
----------------------------------------------------------------------------------
function CON(con_expression)
    if (con_expression) then
        return 1
    end

    return 0
end