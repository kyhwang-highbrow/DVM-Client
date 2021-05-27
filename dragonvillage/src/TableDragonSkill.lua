local PARENT = TableClass

-- 수식을 사용할 수 있는 칼럼 리스트
local l_columnToUseEquation = {
    'power_source',
    'chance_value',
    'add_option_rate_1',
    'add_option_rate_2',
    'add_option_rate_3',
    'add_option_rate_4',
    'add_option_source_1',
    'add_option_source_2',
    'add_option_source_3',
    'add_option_source_4',
    'add_option_value_1',
    'add_option_value_2',
    'add_option_value_3',
    'add_option_value_4',
    'add_option_time_1',
    'add_option_time_2',
    'add_option_time_3',
    'add_option_time_4'
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
    local t_table = PARENT.get(self, key, skip_error_msg)
    local ret

    if (t_table) then
        ret = clone(t_table)

        -- 해당 칼럼의 함수가 존재하는 경우 해당 함수로 치환시킴
        for i, column in ipairs(l_columnToUseEquation) do
            local equation = EquationHelper:getEquation(self.m_tableName, key, column)
            if (equation) then
                ret[column] = equation
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
        sprite = cc.Sprite:create('res/ui/icons/skill/developing.png')
    end

    sprite:setDockPoint(cc.p(0.5, 0.5))
    sprite:setAnchorPoint(cc.p(0.5, 0.5))

    return sprite
end

-------------------------------------
-- function getSkillOwnerName
-------------------------------------
function TableDragonSkill:getSkillOwnerName(key)
	if (not key) or (key == '') then return end
    local t_skill = self:get(key)
    return t_skill['r_d_name']
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
    local desc = DragonSkillCore.getSimpleSkillDesc(t_skill)
    return desc
end

-------------------------------------
-- function getSkillType
-------------------------------------
function TableDragonSkill:getSkillType(key)
	if (not key) or (key == '') then return end
    
    local t_skill = self:get(key)
    if (not t_skill) then return end

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
    if (EquationHelper:isExistTable(self.m_tableName)) then return end
    
    -- 칼럼별로 수식이 포함된 경우 해당 수식을 위한 함수 생성
    if (self.m_orgTable) then
        for i, column in ipairs(l_columnToUseEquation) do
            for sid, v in pairs(self.m_orgTable) do
                if (v[column] and v[column] ~= '') then
                    if (string.find(column, 'source')) then
                        local source = SkillHelper:getValid(v[column], 'atk')
                        if (source ~= 'atk') then
                            EquationHelper:addEquationFromTable(self.m_tableName, sid, column, source)
                        end

                    elseif (string.find(column, 'rate')) then
                        local rate = SkillHelper:getValid(v[column], 100)
                        if (type(rate) == 'string') then
                            EquationHelper:addEquationFromTable(self.m_tableName, sid, column, rate)
                        end

                    elseif (string.find(column, 'value')) then
                        local value = SkillHelper:getValid(v[column], 0)
                        if (type(value) == 'string' and not string.find(value, ';')) then
                            EquationHelper:addEquationFromTable(self.m_tableName, sid, column, value)
                        end
                    end
                end
            end
        end
    end
end