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
-- @brief 보상용 아이템 ID를 찾는다
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

-------------------------------------
-- function getRegionList
-- @brief
-------------------------------------
function TableItem:getRegionList(item_id)
    if (self == TableItem) then
        self = TableItem()
    end

    local trim_execution = true
    local l_region = self:getSemicolonSeparatedValues(item_id, 'get_region', trim_execution)

    return l_region
end