local PARENT = TableClass

-------------------------------------
-- class TableItemType
-------------------------------------
TableItemType = class(PARENT, {
        m_itemTable = 'class',
    })

local THIS = TableItemType

-------------------------------------
-- function init
-------------------------------------
function TableItemType:init()
    self.m_tableName = 'item_type'
    self.m_orgTable = TABLE:get(self.m_tableName)
	self.m_itemTable = TableItem()
end

-------------------------------------
-- function isMailItem
-- @brief �������� '������' �� ���������� ����
-------------------------------------
function TableItemType:isMailItem(item_type)
	if (self:getMailType(item_type) == 'item') then
		return true
	else
		return false
	end
end

-------------------------------------
-- function isMailMoney
-- @brief �������� '��ȭ' �� ���������� ����
-------------------------------------
function TableItemType:isMailMoney(item_type)
	if (self:getMailType(item_type) == 'money') then
		return true
	else
		return false
	end
end

-------------------------------------
-- function isMailStaminas
-- @brief �������� '����' �� ���������� ����
-------------------------------------
function TableItemType:isMailStaminas(item_type)
	if (self:getMailType(item_type) == 'staminas') then
		return true
	else
		return false
	end
end

-------------------------------------
-- function isMailFP
-- @brief �������� '����' �� ���������� ����
-------------------------------------
function TableItemType:isMailFp(item_type)
	if (self:getMailType(item_type) == 'fp') then
		return true
	else
		return false
	end
end

-------------------------------------
-- function getMailType
-- @brief ������ �ǿ� ���� Ÿ��
-------------------------------------
function TableItemType:getMailType(item_id)	
	if (self == THIS) then
        self = THIS()
    end
	
	local item_type = self.m_itemTable:getItemType(item_id)
	local mail_type = self:getValue(item_type, 'mail_tab_type')
	
	-- item_type�� ���ǵ��� ���� ���
	if (not mail_type) then
		self:errorUndefineType(item_type)
		return false
	end
	return mail_type
end

-------------------------------------
-- function isCanReadAll
-- @brief �����Կ��� ��� �ޱⰡ �������� ���� ����
-------------------------------------
function TableItemType:isCanReadAll(item_id)
	if (self == THIS) then
        self = THIS()
    end

	local item_type = self.m_itemTable:getItemType(item_id)
	
	if (not self:exists(item_type)) then
		self:errorUndefineType(item_type)
		return false
	end

	local is_read_all = self:getValue(item_type, 'is_read_all')
	
	-- ���� 1�� ��� ��ιޱ� ����/nil�� ��� �Ұ���
	if (is_read_all == 1) then
		return true
	else
		return false
	end
end

-------------------------------------
-- function errorUndefineType
-- @brief csv�� ���ǵ��� ���� ��Ұ� �ִٸ� �׽�Ʈ ����� ���� �����޼��� ���
-------------------------------------
function TableItemType:errorUndefineType(item_type)
	if (CppFunctionsClass:isTestMode()) then
			error('table_item_type.csv�� ���� ���� ���� : ' .. tostring(item_type))
	end
end
