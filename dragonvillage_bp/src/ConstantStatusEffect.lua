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


-- 조건부 leader/passive 버프의 조건을 검사하는 함수.
PASSIVE_CONDITION_FUNC = {}
PASSIVE_CONDITION_FUNC['wave_boss'] = function(status_effect)
    -- 보스 웨이브일 때 true, 아니면 false
    return status_effect.m_owner.m_world.m_waveMgr.m_currWave == status_effect.m_owner.m_world.m_waveMgr.m_maxWave
end

PASSIVE_CONDITION_FUNC['non_debuff'] = function(status_effect)
    -- 디버프를 가지고 있지 않으면 true, 아니면 false
   return not status_effect.m_owner:hasHarmfulStatusEffect() 
end