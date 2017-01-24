local PARENT = TableClass

-------------------------------------
-- class TableItem
-------------------------------------
TableItem = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableItem:init()
    self.m_tableName = 'item'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getRewardItem
-- @brief ����� ������ ID�� ã�´�
-------------------------------------
function TableItem:getRewardItem(reward_type)
	local reward_item_type = reward_type .. '_r'
	local key = 'type'
	local ret = nil

    for i,v in pairs(self.m_orgTable) do
        if (v[key] == reward_item_type) then
            ret = v
			break;
        end
    end

	return ret
end