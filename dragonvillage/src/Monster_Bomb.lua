--local PARENT = MonsterLua_Boss
local PARENT = Monster
-------------------------------------
--- @class Monster_Bomb
--- @brief  차원문 광신도에 등장하는 정방향, 역방향 폭탄
---         난격에 타게팅되서 방향이 바뀌는 이슈가 있음.
---         확인 결과 폭탄이 스킬의 공격으로 제거되면 역방향의 폭탄이 소환되는데
---         소환이 된다고 바로 [일반 공격/패시브 스킬 공격 불가]가 발동되지 않고
---         프레임이 돌아야 업데이트 로직을 타면서 [일반 공격/패시브 스킬 공격 불가]가 발동이 됨
---         프레임이 돌지 않고 효과가 없는 상태로 타게팅이 되는 이슈
---         스킬 효과를 먹히도록 수정을 생각했으나 전투에 영향을 미칠 수 있어 몬스터 자체적으로 예외처리
-------------------------------------
Monster_Bomb = class(PARENT, {
     })

-------------------------------------
--- @function isAttackable
-------------------------------------
function Monster_Bomb:isAttackable(is_active_skill, attack_activity_carrier)
    local is_attackable = true
    local has_active_only_passive = true --self:isExistStatusEffectName('target_active_skill_only')
    local has_without_skill_passive = self:isExistStatusEffectName('target_without_skill')
    local has_disabled_passive = self:isExistStatusEffectName('target_disabled')

    -- 아예 못떄림
    if (has_disabled_passive) then
        is_attackable = false
    -- 액티브만 먹을 때
    elseif (has_active_only_passive) then
        is_attackable = is_active_skill == true
    -- 액티브 뺴고 다먹어야 할 때
    elseif (has_without_skill_passive) then
        is_attackable = not is_active_skill
    end
    
    -- 액티비티 캐리어가 없으면 그냥 결과 반환
    if (not attack_activity_carrier) then return is_attackable end

    -- 일부 특별한 공격은 무조건 적중.
    local skill_id = attack_activity_carrier:getSkillId()
    local t_skill = self:getSkillTable(skill_id)
    local is_definite_target = false

    if (t_skill and t_skill['target_type']) then 
        local target_type = t_skill['target_type']
        local is_teammate = string.find(target_type, 'teammate')
        local is_self = string.find(target_type, 'self')
        local is_ally = string.find(target_type, 'ally')
        local is_boss = string.find(target_type, 'boss')

        -- 이 중에 하나라도 해다된다면 타겟 지정 가능
        if (is_teammate or is_self or is_ally or is_boss) then 
            is_definite_target = true 
        end
    end

    if (is_definite_target) then 
        is_attackable = true
    end

    return is_attackable
end
