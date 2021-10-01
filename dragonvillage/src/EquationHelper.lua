-------------------------------------
-- table EquationHelper
-------------------------------------
EquationHelper = {}

EV_HIT_TARGET_COUNT = 'hit_target_count'
EV_BOSS_RARITY = 'boss_rarity'
EV_DIED_ALLY_COUNT = 'died_ally_count'
EV_SKILL_DAMAGE = 'skill_damage'

-------------------------------------
-- function addEquationFromTable
-- @breif 파라미터의 수식(source)을 함수로 만들어서 저장
-------------------------------------
function EquationHelper:addEquationFromTable(table_name, key, column, source)
    if (not EQUATION_FUNC[table_name]) then
        EQUATION_FUNC[table_name] = {}
    end
    if (not EQUATION_FUNC[table_name][key]) then
        EQUATION_FUNC[table_name][key] = {}
    end
    if (EQUATION_FUNC[table_name][key][column]) then
        return
    end

    if (type(key) == 'string') then
        key = '\'' .. key .. '\''
    end

    local str_param = 
        ' local atk = owner:getStat(\'atk\')' ..
        ' local def = owner:getStat(\'def\')' ..
        ' local hp = owner:getHp()' ..
        ' local max_hp = owner:getStat(\'hp\')' ..
        ' local hp_rate = owner:getHpRate()' ..
        ' local aspd = owner:getStat(\'aspd\')' ..
        ' local cri_chance = owner:getStat(\'cri_chance\')' ..
        ' local cri_dmg = owner:getStat(\'cri_dmg\')' ..
        ' local cri_avoid = owner:getStat(\'cri_avoid\')' ..
        ' local hit_rate = owner:getStat(\'hit_rate\')' ..
        ' local avoid = owner:getStat(\'avoid\')' ..
        ' local accuracy = owner:getStat(\'accuracy\')' ..
        ' local resistance = owner:getStat(\'resistance\')' ..
        ' local attr = owner:getAttribute()' ..
        ' local role = owner:getRole()' ..
        ' local rarity = owner:getRarity()' ..
        ' local grade = owner:getGrade()' ..
        ' local total_level = owner:getTotalLevel()' ..
        
        ' local target_atk = target and target:getStat(\'atk\') or 0' ..
        ' local target_def = target and target:getStat(\'def\') or 0' ..
        ' local target_hp = target and target:getHp() or 0' ..
        ' local target_max_hp = target and target:getStat(\'hp\') or 0' ..
        ' local target_hp_rate = target and target:getHpRate() or 0' ..
        ' local target_aspd = target and target:getStat(\'aspd\') or 0' ..
        ' local target_cri_chance = target and target:getStat(\'cri_chance\') or 0' ..
        ' local target_cri_dmg = target and target:getStat(\'cri_dmg\') or 0' ..
        ' local target_cri_avoid = target and target:getStat(\'cri_avoid\') or 0' ..
        ' local target_hit_rate = target and target:getStat(\'hit_rate\') or 0' ..
        ' local target_avoid = target and target:getStat(\'avoid\') or 0' ..
        ' local target_accuracy = target and target:getStat(\'accuracy\') or 0' ..
        ' local target_resistance = target and target:getStat(\'resistance\') or 0' ..
        ' local target_attr = target and target:getAttribute()' ..
        ' local target_role = target and target:getRole()' ..
        ' local target_rarity = target and target:getRarity() or 0' ..
        ' local target_grade = target and target:getGrade()' ..
        ' local target_total_level = target and target:getTotalLevel()' ..
        ' local target_active_skill_target_count = target and target:getActiveSkillTargetCount() or 0' ..
            
        ' local STATUSEFFECT = function(name, column)' ..
        ' if (column) then' ..
        ' return owner:isExistStatusEffect(column, name) and 1 or 0' ..
        ' else' ..
        ' return owner:isExistStatusEffectName(name) and 1 or 0' ..
        ' end' ..
        ' end' ..

        ' local TARGET_STATUSEFFECT = function(name, column)' ..
        ' if (column) then' ..
        ' local b = target and target:isExistStatusEffect(column, name) or false' ..
        ' return (b and 1 or 0)' ..
        ' else' ..
        ' local b = target and target:isExistStatusEffectName(name) or false' ..
        ' return (b and 1 or 0)' ..
        ' end' ..
        ' end' ..

        ' local STATUSEFFECT_COUNT = function(name, column)' ..
        ' return owner:getStatusEffectCount(column, name)' ..
        ' end' ..

        ' local TARGET_STATUSEFFECT_COUNT = function(name, column)' ..
        ' return target and target:getStatusEffectCount(column, name) or 0' ..
        ' end' ..

        ' local ALLY_MIN_HP_RATE = function()' ..
        ' return GET_ALLY_MIN_HP_RATE(owner)' ..
        ' end' ..

        -- 변신 상태 체크 함수(아이리스 변신 확인. isMetamorphosis이 함수는 Character클래스에 정의되어 있다.)
        ' local TARGET_METAMORPHOSIS_RATE = function()' ..
        '     if target then' ..
        '         if (target:isMetamorphosis() == true) then' ..
        '             return 1' ..
        '         end' ..
        '     end' ..
        '     return 0' ..
        ' end' ..

        -- 외부 환경 정보
        ' local hit_target_count = 0' ..
        ' local boss_rarity = 5' ..
        ' local died_ally_count = 0' ..

        ' if (add_param) then' ..
        ' hit_target_count = add_param[EV_HIT_TARGET_COUNT] or hit_target_count' ..
        ' boss_rarity = add_param[EV_BOSS_RARITY] or boss_rarity' ..
        ' died_ally_count = add_param[EV_DIED_ALLY_COUNT] or died_ally_count' ..
        ' end'

    -- 함수 내용이 너무 커질 경우 사용된 변수명에 따라 별도로 추가해야할듯하다...
    local str_add_param = ''

    if (string.find(source, 'skill_target')) then
        str_add_param = str_add_param ..
        ' local skill_target = owner:getTargetChar()' ..
        ' local skill_target_atk = skill_target and skill_target:getStat(\'atk\') or 0' ..
        ' local skill_target_def = skill_target and skill_target:getStat(\'def\') or 0' ..
        ' local skill_target_hp = skill_target and skill_target:getHp() or 0' ..
        ' local skill_target_max_hp = skill_target and skill_target:getStat(\'hp\') or 0' ..
        ' local skill_target_hp_rate = skill_target and skill_target:getHpRate() or 0' ..
        ' local skill_target_aspd = skill_target and skill_target:getStat(\'aspd\') or 0' ..
        ' local skill_target_cri_chance = skill_target and skill_target:getStat(\'cri_chance\') or 0' ..
        ' local skill_target_cri_dmg = skill_target and skill_target:getStat(\'cri_dmg\') or 0' ..
        ' local skill_target_cri_avoid = skill_target and skill_target:getStat(\'cri_avoid\') or 0' ..
        ' local skill_target_hit_rate = skill_target and skill_target:getStat(\'hit_rate\') or 0' ..
        ' local skill_target_avoid = skill_target and skill_target:getStat(\'avoid\') or 0' ..
        ' local skill_target_accuracy = skill_target and skill_target:getStat(\'accuracy\') or 0' ..
        ' local skill_target_resistance = skill_target and skill_target:getStat(\'resistance\') or 0' ..
        ' local skill_target_attr = skill_target and skill_target:getAttribute()' ..
        ' local skill_target_role = skill_target and skill_target:getRole()' ..
        ' local skill_target_rarity = skill_target and skill_target:getRarity() or 0' ..
        ' local skill_target_grade = skill_target and skill_target:getGrade()' ..
        ' local skill_target_total_level = skill_target and skill_target:getTotalLevel()' ..
        ' local SKILL_TARGET_STATUSEFFECT = function(name, column)' ..
        '   if (column) then' ..
        '       local b = skill_target and skill_target:isExistStatusEffect(column, name) or false' ..
        '       return (b and 1 or 0)' ..
        '   else' ..
        '       local b = skill_target and skill_target:isExistStatusEffectName(name) or false' ..
        '       return (b and 1 or 0)' ..
        '   end' ..
        ' end' ..
        ' local SKILL_TARGET_STATUSEFFECT_COUNT = function(name, column)' ..
        '   return skill_target and skill_target:getStatusEffectCount(column, name) or 0' ..
        ' end'
    end

    if (string.find(source, 'buff_')) then
        str_add_param = str_add_param ..
        ' local buff_atk = owner:getBuffStat(\'atk\')' ..
        ' buff_atk = math_max(buff_atk, 0)' ..
        ' local buff_def = owner:getBuffStat(\'def\')' ..
        ' buff_def = math_max(buff_def, 0)' ..
        ' local buff_hp = owner:getBuffStat(\'hp\')' ..
        ' buff_hp = math_max(buff_hp, 0)' ..
        ' local buff_aspd = owner:getBuffStat(\'aspd\')' ..
        ' buff_aspd = math_max(buff_aspd, 0)' ..
        ' local buff_cri_chance = owner:getBuffStat(\'cri_chance\')' ..
        ' buff_cri_chance = math_max(buff_cri_chance, 0)' ..
        ' local buff_cri_dmg = owner:getBuffStat(\'cri_dmg\')' ..
        ' buff_cri_dmg = math_max(buff_cri_dmg, 0)' ..
        ' local buff_cri_avoid = owner:getBuffStat(\'cri_avoid\')' ..
        ' buff_cri_avoid = math_max(buff_cri_avoid, 0)' ..
        ' local buff_hit_rate = owner:getBuffStat(\'hit_rate\')' ..
        ' buff_hit_rate = math_max(buff_hit_rate, 0)' ..
        ' local buff_avoid = owner:getBuffStat(\'avoid\')' ..
        ' buff_avoid = math_max(buff_avoid, 0)' ..
		' local buff_accuracy = owner:getBuffStat(\'accuracy\')' ..
        ' buff_resistance = math_max(buff_resistance, 0)' ..
		' local buff_resistance = owner:getBuffStat(\'resistance\')' ..
        ' buff_resistance = math_max(buff_resistance, 0)'
    end

    -- 해당 스킬 사용 횟수 정보
    if (string.find(source, 'skill_used_count') or string.find(source, 'skill_tried_count')) then
        str_add_param = str_add_param .. 
        ' local skill_used_count = 0' ..
        ' local skill_tried_count = 0' ..

        ' if (skill_id) then' ..
        ' local skill_info = owner:findSkillInfoByID(skill_id)' ..
        ' if (skill_info) then' ..
        ' skill_used_count = skill_info:getUsedCount()' ..
        ' skill_tried_count = skill_info:getTriedCount()' ..
        ' end' .. 
        ' end'
    end


    local func = pl.utils.load(
        'EQUATION_FUNC[\'' .. table_name .. '\'][' .. key .. '][\'' .. column ..'\'] = function(owner, target, add_param, skill_id)' ..
        str_param ..
        str_add_param .. 
        ' local ret = ' .. source .. 
        ' return ret' ..
        ' end'
    )

    if (not func) then
        error(string.format('%s 테이블에서 %s(행) %s(칼럼)의 수식 적용시 에러 발생 : %s', table_name, key, column, source))
    end

    func()
end

----------------------------------------------------------------------------------
-- function getEquation
----------------------------------------------------------------------------------
function EquationHelper:getEquation(table_name, key, column)
    if (EQUATION_FUNC[table_name] and EQUATION_FUNC[table_name][key]) then
        return EQUATION_FUNC[table_name][key][column]
    end

    return nil
end

----------------------------------------------------------------------------------
-- function isExistTable
----------------------------------------------------------------------------------
function EquationHelper:isExistTable(table_name)
    if (EQUATION_FUNC[self.m_tableName]) then
        return true
    end

    return false
end

----------------------------------------------------------------------------------
-- 스킬 관련 수식에서 사용하기 위한 값을 맵에 추가(공격자와 방어자의 정보를 제외한 모두)
----------------------------------------------------------------------------------
function EquationHelper:setEquationParamOnMapForSkill(target_map, skill_entity)
    local world = skill_entity.m_world

    if (isInstanceOf(skill_entity, Skill)) then
        if (skill_entity.m_lTargetChar) then
            target_map[EV_HIT_TARGET_COUNT] = #skill_entity.m_lTargetChar
        end

        target_map[EV_SKILL_DAMAGE] = skill_entity.m_totalDamage
    end

    if (world.m_waveMgr.m_currWave == world.m_waveMgr.m_maxWave) then
        target_map[EV_BOSS_RARITY] = world.m_waveMgr.m_highestRarity
    end

    -- 스킬 보유자 그룹 기준으로 설정되어야함
    local l_dead = world:getDeadList(skill_entity.m_owner)
    if (l_dead) then
        target_map[EV_DIED_ALLY_COUNT] = #l_dead
    end
end

----------------------------------------------------------------------------------
-- 상태효과 관련 수식에서 사용하기 위한 값을 맵에 추가(공격자와 방어자의 정보를 제외한 모두)
----------------------------------------------------------------------------------
function EquationHelper:setEquationParamOnMapForStatusEffect(target_map, status_effect_entity)
    local world = status_effect_entity.m_owner.m_world
    local org_map = status_effect_entity.m_tParam

    target_map[EV_HIT_TARGET_COUNT] = org_map[EV_HIT_TARGET_COUNT]
    target_map[EV_SKILL_DAMAGE] = org_map[EV_SKILL_DAMAGE]
    
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
function CON(con_expression, ret_true, ret_false)
    local ret_true = ret_true or 1
    local ret_false = ret_false or 0

    if (con_expression) then
        return ret_true
    end

    return ret_false
end

function GET_ALLY_MIN_HP_RATE(unit)
    local ally_min_hp_rate = 0

    if (isInstanceOf(unit, Character)) then
        local l_ally = unit:getTargetListByType('ally_hp_low')
        if (l_ally[1]) then
            ally_min_hp_rate = l_ally[1]:getHpRate()
        end
    end

    return ally_min_hp_rate
end