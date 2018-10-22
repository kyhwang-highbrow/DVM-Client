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
-- @brief 우편함의 '아이템' 탭 아이템인지 여부
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
-- @brief 우편함의 '재화' 탭 아이템인지 여부
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
-- @brief 우편함의 '날개' 탭 아이템인지 여부
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
-- @brief 우편함의 '우정' 탭 아이템인지 여부
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
-- @brief 우편함 탭에 따른 타입
-------------------------------------
function TableItemType:getMailType(item_id)	
	if (self == THIS) then
        self = THIS()
    end
	
	local item_type = self.m_itemTable:getItemType(item_id)
	local mail_type = self:getValue(item_type, 'mail_tab_type')
	
	-- item_type이 정의되지 않은 경우
	if (not mail_type) then
		self:errorUndefineType(item_type)
		return false
	end
	return mail_type
end

-------------------------------------
-- function isCanReadAll
-- @brief 우편함에서 모두 받기가 가능한지 여부 리턴
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
	
	-- 값이 1인 경우 모두받기 가능/nil인 경우 불가능
	if (is_read_all == 1) then
		return true
	else
		return false
	end
end

-------------------------------------
-- function errorUndefineType
-- @brief csv에 정의되지 않은 요소가 있다면 테스트 모드일 때만 에러메세지 출력
-------------------------------------
function TableItemType:errorUndefineType(item_type)
	if (CppFunctionsClass:isTestMode()) then
			error('table_item_type.csv에 정의 되지 않음 : ' .. tostring(item_type))
	end
end
