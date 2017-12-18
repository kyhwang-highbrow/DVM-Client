local PARENT = Skill

----------------------------------------
-- class SkillRandom
----------------------------------------
SkillRandom = class(PARENT, {
    })

----------------------------------------
-- function init 
----------------------------------------
function SkillRandom:init(file_name, body, ...)

end

----------------------------------------
-- function makeSkillInstance
----------------------------------------
function SkillRandom:makeSkillInstance(owner, t_skill, t_data)

    -- 변수 선언부
    ---------------------------------------------------------
    local strSkillID = t_skill['val_1']
    local skill_choose_rate = t_skill['val_2']

    local l_skillID = pl.stringx.split(strSkillID, ';')
    local l_rate = pl.stringx.split(skill_choose_rate, ';')

    local random_value = math_random()

    for i = 1, #l_rate do
        l_rate[i] = tonumber(l_rate[i]) 
    end
    
    for i = 1, #l_rate - 1 do 
        l_rate[i + 1] = l_rate[i] + l_rate[i + 1] 
    end

    for i = 1, #l_rate do 
        if (random_value < l_rate[i]) then
            random_value = i
            break
        end
    end
    
    local derived_skill_info = DragonSkillIndivisualInfo(owner.m_charType, 'skill_random', tonumber(l_skillID[random_value]), t_skill.m_skillLevel) 

    derived_skill_info:applySkillLevel()
    derived_skill_info:applySkillDesc()
    -- 스킬 실행
    ---------------------------------------------------------
    owner:doSkill(tonumber(l_skillID[random_value]), 0, 0, t_data, derived_skill_info.m_tSkill)

end

