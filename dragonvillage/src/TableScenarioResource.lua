local PARENT = TableClass

-------------------------------------
-- class TableScenarioResource
-------------------------------------
TableScenarioResource = class(PARENT, {
    })

local THIS = TableScenarioResource

-------------------------------------
-- function init
-------------------------------------
function TableScenarioResource:init()
    self.m_tableName = 'scenario_resource'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getScenarioRes
-------------------------------------
function TableScenarioResource:getScenarioRes(key)
    if (self == THIS) then
        self = THIS()
    end

    local t_table = self:get(key)
    if (not t_table) then
        return key
    end

    return t_table['res'] or key
end

-------------------------------------
-- function getScenarioResType
-------------------------------------
function TableScenarioResource:getScenarioResType(key)
	-- @TODO 작별 연출 처럼 외부에서 데이터를 줘야 하는 경우 
	-- 드래곤은 리소스 경로를 직접 보내며
	-- 타입을 따로 지정해줘야 하기 때문에 다음처럼 구분
	if (string.find(key, 'character/dragon/')) then
		return 'dragon'
	end

    if (self == THIS) then
        self = THIS()
    end

    local t_table = self:get(key)
    if (not t_table) then
		return 'none'
    end

    return t_table['type']
end
