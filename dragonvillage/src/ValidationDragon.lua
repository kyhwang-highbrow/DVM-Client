-------------------------------------
-- class ValidationAssistant
-- @brief 유효성을 검사를 돕는 클래스
-------------------------------------
ValidationDragon = class({
    })

-------------------------------------
-- function init
-- @brief 드래곤이 정상적으로 동작할 수 있는 테이블, 리소스, 구현이 되어있는지 확인
-- @param dragon_id
-------------------------------------
function ValidationDragon:init(dragon_id)
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[dragon_id]

    -- 스킬 유효성 검사
    --self:validationSkill(t_dragon)

    -- 에니메이션 리스트 검사
    self:validationAnimationList(t_dragon)
end

-------------------------------------
-- function validationAnimationList
-- @brief 에니메이션 리스트 검사
-------------------------------------
function ValidationDragon:validationAnimationList(t_dragon)
    local res_name = t_dragon['res']
	local attr = t_dragon['attr']

    local function func(l_ret, l_visual_list, visual_name)
        if (not table.find(l_visual_list, visual_name)) then
            table.insert(l_ret, visual_name)
        end
    end
    
    for evolution=1, 3 do
        local animator = AnimatorHelper:makeDragonAnimator(res_name, evolution, attr)
        local l_visual_list = animator:getVisualList()
        
        local l_ret = {}
        func(l_ret, l_visual_list, 'attack')
        func(l_ret, l_visual_list, 'idle')
        func(l_ret, l_visual_list, 'pose_1')
        func(l_ret, l_visual_list, 'skill_appear')
        func(l_ret, l_visual_list, 'skill_disappear')
        func(l_ret, l_visual_list, 'skill_idle')

        if (#l_ret > 0) then
            ccdump(l_ret, t_dragon['type'] .. '_' .. tostring(evolution))
        end
    end
end

-------------------------------------
-- function validationSkill
-- @brief
-------------------------------------
function ValidationDragon:validationSkill(t_dragon)
    local table_dragon_skill = TableDragonSkill()

    for i=1, 6 do
        local skill_id = t_dragon[string.format('skill_%d', i)]
        local skill_type = table_dragon_skill:getSkillType(skill_id)

        -- 스킬테이블 참조
        if isExistValue(skill_type, 'basic', 'normal', 'passive', 'active') then
            self:validationSkillIndividual(skill_type, table_dragon_skill, skill_id)
        else
            error('skill_type : ' .. skill_type)
        end
    end

    self:validationSkillIndividual('basic', table_dragon_skill, t_dragon['skill_basic'])
end

-------------------------------------
-- function validationSkillIndividual
-- @brief
-------------------------------------
function ValidationDragon:validationSkillIndividual(skill_type, table_skill, skill_id)
    if (not table_skill[skill_id]) then
        cclog(skill_type, skill_id)
    end
end

-------------------------------------
-- function ValidationDragonTotal
-- @brief
-------------------------------------
function ValidationDragonTotal()
    local table_dragon = TABLE:get('dragon')

    for dragon_id,v in pairs(table_dragon) do
        ValidationDragon(dragon_id)
    end
end