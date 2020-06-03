local PARENT = TableClass


-- 수식을 사용할 수 있는 칼럼 리스트
local l_columnToUseEquation = {
    'add_option_source_1',
    'add_option_source_2'
}

-------------------------------------
-- class TableStatusEffect
-------------------------------------
TableStatusEffect = class(PARENT, {
    })

local THIS = TableStatusEffect

-------------------------------------
-- function init
-------------------------------------
function TableStatusEffect:init()
    self.m_tableName = 'status_effect'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function get
-------------------------------------
function TableStatusEffect:get(key, skip_error_msg)
    local t_table = PARENT.get(self, key, skip_error_msg)
    if (not t_table) then
        -- add_dmg_%s 이름의 타입은 add_dmg 타입과 일치시킨다
        if (string.find(key, 'add_dmg_')) then
            t_table = PARENT.get(self, 'add_dmg', skip_error_msg)
        end
    end

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
-- function getRes
-------------------------------------
function TableStatusEffect:getRes(key, attr)
    local t_table = self:get(key)
    if (not t_table) then return end

    -- res attr parsing
    local res = t_table['res']
	if (res and attr) then 
		res = string.gsub(res, '@', attr)
	end

	-- nil 처리
	if (res == '') then 
		res = nil 
	end

    return res
end

-------------------------------------
-- function getRes2
-------------------------------------
function TableStatusEffect:getRes2(key, attr)
    local t_table = self:get(key)
    if (not t_table) then return end

    -- res attr parsing
    local res = t_table['res_2']
	if (res and attr) then 
		res = string.gsub(res, '@', attr)
	end

	-- nil 처리
	if (res == '') then 
		res = nil 
	end

    return res
end



-------------------------------------
-- function initGlobal
-------------------------------------
function TableStatusEffect:initGlobal()
    if (self == THIS) then
        self = THIS()
    end
    
    self:makeFunctions()
end

-------------------------------------
-- function makeFunctions
-------------------------------------
function TableStatusEffect:makeFunctions()
    if (EquationHelper:isExistTable(self.m_tableName)) then return end
    
    -- 특수한 경우만 수식을 사용함
    if (self.m_orgTable) then
        for k, v in pairs(self.m_orgTable) do
            if (v['type'] == 'consume_missile') then
                for i, column in ipairs({'val_3', 'val_4'}) do
                    local string_value = v[column]
                    if (string_value and string_value ~= '') then
                        local l_str = seperate(string_value, ';')

                        local name = l_str[1]
                        local value = SkillHelper:getValid(l_str[2], 0)
                        local time = l_str[3]
                        local source = SkillHelper:getValid(l_str[4], 'atk')
                        local rate = SkillHelper:getValid(l_str[5], 100)

                        -- add_option 칼럼 생성
                        v['add_option_type_' .. i] = name
                        v['add_option_value_' .. i] = value
                        v['add_option_time_' .. i] = time
                        v['add_option_source_' .. i] = source
                        v['add_option_rate_' .. i] = rate

                        if (source ~= 'atk') then
                            EquationHelper:addEquationFromTable(self.m_tableName, k, 'add_option_source_' .. i, source)
                        end
                        if (type(rate) == 'string') then
                            EquationHelper:addEquationFromTable(self.m_tableName, k, 'add_option_rate_' .. i, rate)
                        end
                        if (type(value) == 'string') then
                            EquationHelper:addEquationFromTable(self.m_tableName, k, 'add_option_value_' .. i, value)
                        end
                    end
                end
            end
        end
    end
end