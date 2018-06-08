local PARENT = TableDragonSkill

-- 수식을 사용할 수 있는 칼럼 리스트
local l_columnToUseEquation = {
    'power_source',
    'add_option_rate_1',
    'add_option_rate_2',
    'add_option_source_1',
    'add_option_source_2',
    'add_option_value_1',
    'add_option_value_2'
}

-------------------------------------
-- class TableTamerSkill
-------------------------------------
TableTamerSkill = class(PARENT, {
    })

local THIS = TableTamerSkill

-------------------------------------
-- function init
-------------------------------------
function TableTamerSkill:init()
    self.m_tableName = 'tamer_skill'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getTamerSkill
-------------------------------------
function TableTamerSkill:getTamerSkill(skill_id)
	local t_skill = self:get(skill_id)
	
	-- 스킬 자체가 없는 경우는 nil 반환
	if not (t_skill) then 
		return nil
	end

	return t_skill
end

-------------------------------------
-- function getSkillType
-------------------------------------
function TableTamerSkill:getSkillType(key)
	if (not key) or (key == '') then return end
    
    local t_skill = self:get(key)
    if (not t_skill) then
        cclog('getSkillType : ' .. key)
        return
    end

    return t_skill['chance_type']
end


-------------------------------------
-- function initGlobal
-------------------------------------
function TableTamerSkill:initGlobal()
    if (self == THIS) then
        self = THIS()
    end
    
    self:makeFunctions()
end

-------------------------------------
-- function makeFunctions
-------------------------------------
function TableTamerSkill:makeFunctions()
    if (EquationHelper:isExistTable(self.m_tableName)) then return end
    
    -- 칼럼별로 수식이 포함된 경우 해당 수식을 위한 함수 생성
    if (self.m_orgTable) then
        for i, column in ipairs(l_columnToUseEquation) do
            for sid, v in pairs(self.m_orgTable) do
                if (v[column]) then
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
                        if (type(value) == 'string') then
                            EquationHelper:addEquationFromTable(self.m_tableName, sid, column, value)
                        end
                    end
                end
            end
        end
    end
end