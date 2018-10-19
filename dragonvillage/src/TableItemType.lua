local PARENT = TableClass

-------------------------------------
-- class TableItemType
-------------------------------------
TableItemType = class(PARENT, {
    })
	
-------------------------------------
-- function init
-------------------------------------
function TableItemType:init()
    self.m_tableName = 'item_type'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function isCanReadAllFromType
-- @brief 모두 받기 여부 판별해주는 함수
-------------------------------------
function TableItemType:isCanReadAllFromType(item_type)
	if (not self.m_orgTable[item_type]) then
		--아이템이 table_item_type에 정의되지 않았다면 테스트모드에서만 에러
		if (CppFunctionsClass:isTestMode()) then
			error('undefined type in Item_Type_Table : '..tostring(item_type))
		end
		return false
	end
	
	--true : 1 / false : ''
	if (self.m_orgTable[item_type]['is_read_all'] == 1) then
		return true
	else
		return false
	end
end

-------------------------------------
-- function MailItemTypeFromType
-- @brief 메일탭에 따른 타입
-------------------------------------
function TableItemType:MailItemTypeFromType(item_type)
	if (not self.m_orgTable[item_type]) then
		if (CppFunctionsClass:isTestMode()) then
			error('undefined type in Item_Type_Table : '..tostring(item_type))
		end
		return false
	end	

	return self.m_orgTable[item_type]['mail_tab_type']
end
