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
	-- @TODO �ۺ� ���� ó�� �ܺο��� �����͸� ��� �ϴ� ��� 
	-- �巡���� ���ҽ� ��θ� ���� ������
	-- Ÿ���� ���� ��������� �ϱ� ������ ����ó�� ����
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
