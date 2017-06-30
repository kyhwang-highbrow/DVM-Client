local PARENT = TableClass

-- 수식을 사용할 수 있는 칼럼 리스트
local l_columnToUseEquation = {
    'power_source',
    'add_option_source_1',
    'add_option_source_2'
}

-------------------------------------
-- class TableDragonSkill
-------------------------------------
TableDragonSkill = class(PARENT, {
    })

local THIS = TableDragonSkill

-------------------------------------
-- function init
-------------------------------------
function TableDragonSkill:init()
    self.m_tableName = 'dragon_skill'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function get
-- @brief 필요한 특정 칼럼들의 값을 치환해서 리턴
-------------------------------------
function TableDragonSkill:get(key, skip_error_msg)
    local t_table = PARENT.get(self, key)
    local ret

    if (t_table and EQUATION_FUNC[self.m_tableName]) then
        ret = clone(t_table)

        -- 해당 칼럼의 함수가 존재하는 경우 해당 함수로 치환시킴
        for i, column in ipairs(l_columnToUseEquation) do
            if (EQUATION_FUNC[self.m_tableName][key] and EQUATION_FUNC[self.m_tableName][key][column]) then
                ret[column] = EQUATION_FUNC[self.m_tableName][key][column]
            end
        end
    else
        ret = t_table
    end

    return ret
end

-------------------------------------
-- function getSkillIcon
-------------------------------------
function TableDragonSkill:getSkillIcon(key)
    local t_skill = self:get(key)

    local res_name = t_skill['res_icon']
    local sprite = cc.Sprite:create(res_name)

    if (not sprite) then
        sprite = cc.Sprite:create('res/ui/icon/skill/developing.png')
    end

    sprite:setDockPoint(cc.p(0.5, 0.5))
    sprite:setAnchorPoint(cc.p(0.5, 0.5))

    return sprite
end

-------------------------------------
-- function getSkillName
-------------------------------------
function TableDragonSkill:getSkillName(key)
	if (not key) or (key == '') then return end
    local t_skill = self:get(key)
    return t_skill['t_name']
end

-------------------------------------
-- function getSkillDesc
-------------------------------------
function TableDragonSkill:getSkillDesc(key)
	if (not key) or (key == '') then return end
    local t_skill = self:get(key)
    local desc = IDragonSkillManager:getSkillDescWithSubstituted(t_skill)
    return desc
end

-------------------------------------
-- function getSkillType
-------------------------------------
function TableDragonSkill:getSkillType(key)
	if (not key) or (key == '') then return end
    local t_skill = self:get(key)
    return t_skill['chance_type']
end












-------------------------------------
-- function initGlobal
-------------------------------------
function TableDragonSkill:initGlobal()
    if (self == THIS) then
        self = THIS()
    end
    
    self:makeFunctions()
end

-------------------------------------
-- function makeFunctions
-------------------------------------
function TableDragonSkill:makeFunctions()
    EQUATION_FUNC[self.m_tableName] = {}

    -- 칼럼별로 수식이 포함된 경우 해당 수식을 위한 함수 생성
    for i, column in ipairs(l_columnToUseEquation) do
        TableDragonSkill.addFunctionsForEquation(self, column)
    end
end

-------------------------------------
-- function addFunctionsForEquation
-- @breif 해당 column의 값들에서 수식이 있을 경우 글로벌 함수를 추가
-------------------------------------
function TableDragonSkill:addFunctionsForEquation(column)
    if (not self.m_orgTable) then return end

    for sid, v in pairs(self.m_orgTable) do 
        local source = SkillHelper:getValid(v[column], 'atk')
                
        -- source가 수식일 경우 함수를 추가
        --local operator = string.match(source, '[*+/-]')
        --if (operator) then
        if (source ~= 'atk') then
            local key = v['sid']
            local b = true

            if (not EQUATION_FUNC[self.m_tableName][key]) then
                EQUATION_FUNC[self.m_tableName][key] = {}
            elseif (EQUATION_FUNC[self.m_tableName][key][column]) then
                b = false
            end

            if (b) then
                local func = pl.utils.load(
                    'EQUATION_FUNC[\'' .. self.m_tableName .. '\'][' .. key .. '][\'' .. column ..'\'] = function(owner, target)' ..
                    ' local atk = owner:getStat(\'atk\')' ..
                    ' local def = owner:getStat(\'def\')' ..
                    ' local hp = owner:getHp()' ..
                    ' local max_hp = owner:getStat(\'hp\')' ..
                    ' local aspd = owner:getStat(\'aspd\')' ..
                    ' local cri_chance = owner:getStat(\'cri_chance\')' ..
                    ' local cri_dmg = owner:getStat(\'cri_dmg\')' ..
                    ' local cri_avoid = owner:getStat(\'cri_avoid\')' ..
                    ' local hit_rate = owner:getStat(\'hit_rate\')' ..
                    ' local avoid = owner:getStat(\'avoid\')' ..
                    ' local attr = owner:getAttribute()' ..
                    ' local role = owner:getRole()' ..

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

                    ' local target_atk = target and target:getStat(\'atk\') or 0' ..
                    ' local target_def = target and target:getStat(\'def\') or 0' ..
                    ' local target_hp = target and target:getHp() or 0' ..
                    ' local target_max_hp = target and target:getStat(\'hp\') or 0' ..
                    ' local target_aspd = target and target:getStat(\'aspd\') or 0' ..
                    ' local target_cri_chance = target and target:getStat(\'cri_chance\') or 0' ..
                    ' local target_cri_dmg = target and target:getStat(\'cri_dmg\') or 0' ..
                    ' local target_cri_avoid = target and target:getStat(\'cri_avoid\') or 0' ..
                    ' local target_hit_rate = target and target:getStat(\'hit_rate\') or 0' ..
                    ' local target_avoid = target and target:getStat(\'avoid\') or 0' ..
                    ' local target_attr = target and target:getAttribute()' ..
                    ' local target_role = target and target:getRole()' ..

                    ' local STATUSEFFECT = function(name)' ..
                    ' return owner:isExistStatusEffectName(name) and 1 or 0' ..
                    ' end' ..

                    ' local TARGET_STATUSEFFECT = function(name)' ..
                    ' local b = target and target:isExistStatusEffectName(name) or false' ..
                    ' return (b) and 1 or 0' ..
                    ' end' ..

                    ' local ret = ' .. source .. 
                    ' return ret' ..
                    ' end'
                )

                func()
            end
        end
    end
end