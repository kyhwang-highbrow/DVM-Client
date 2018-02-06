CON_SKILL_START = 'skill_start'
CON_SKILL_HIT_FIRST = 'skill_hit_first'
CON_SKILL_HIT = 'skill_hit'
CON_SKILL_HIT_CRI = 'skill_hit_cri'
CON_SKILL_HIT_KILL = 'skill_kill'
CON_SKILL_HIT_TARGET = 'skill_hit_target'
CON_SKILL_END = 'skill_end'

-- 조건부 leader/passive 버프의 조건에 따른 받아야 하는 이벤트들의 목록.
PASSIVE_CHANCE_TYPE = {}
PASSIVE_CHANCE_TYPE['wave_boss'] = {'change_wave'}
PASSIVE_CHANCE_TYPE['non_debuff'] = {'get_debuff', 'release_debuff'}
PASSIVE_CHANCE_TYPE['over_hp_rate'] = {'character_set_hp'}
PASSIVE_CHANCE_TYPE['alive'] = {'character_dead', 'character_revive'} 

-- 조건부 leader/passive 버프의 조건을 검사하는 함수.
PASSIVE_CONDITION_FUNC = {}
UNIT_PASSIVE_CONDITION_FUNC = {}

PASSIVE_CONDITION_FUNC['wave_boss'] = function(status_effect)
    -- 보스 웨이브일 때 true, 아니면 false
    return status_effect.m_owner.m_world.m_waveMgr.m_currWave == status_effect.m_owner.m_world.m_waveMgr.m_maxWave
end

PASSIVE_CONDITION_FUNC['non_debuff'] = function(status_effect)
    -- 디버프를 가지고 있지 않으면 true, 아니면 false
   return not status_effect.m_owner:hasHarmfulStatusEffect() 
end

PASSIVE_CONDITION_FUNC['over_hp_rate'] = function(status_effect, t_event)
    -- 체력이 일정% 이상일 경우 true, 아니면 false
    -- t_event : EVENT_CHANGE_HP_CARRIER

    local t_status_effect = status_effect.m_statusEffectTable

    if (not t_event) then
        local owner = status_effect.m_owner
        t_event = { hp_rate = owner:getHpRate() }
    end

    local hp_rate = t_event['hp_rate']
    if (not hp_rate) then return false end

    
    local chance_value = t_status_effect['val_2']
    if (not chance_value or chance_value == '') then return false end
    
    return ( hp_rate * 100 >= chance_value )
end

PASSIVE_CONDITION_FUNC['alive'] = function(status_effect)
    -- unit 중 하나라도 시전자가 살아 있을 경우
    for _, unit in ipairs(status_effect.m_lUnit) do
        if (unit:checkCondition()) then
            return true
        end
    end

    return false
end

UNIT_PASSIVE_CONDITION_FUNC['alive'] = function(status_effect_unit)
    -- 시전자가 살아있을 경우 true, 아니면 false
    local caster = status_effect_unit:getCaster()

    if (not caster:isDead()) then
        return true
    end

    return false
end