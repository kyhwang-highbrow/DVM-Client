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

    local item_id = nil

    -- 단순 재화의 id가 지정된 경우
    if (reward_type == 'cash') then
        item_id = 700001
    elseif (reward_type == 'gold') then
        item_id = 700002
    elseif (reward_type == 'fp') then
        item_id = 700003
    elseif (reward_type == 'lactea') then
        item_id = 700004
    elseif (reward_type == 'honor') then
        item_id = 700005
    elseif (reward_type == 'badge') then
        item_id = 700006
    elseif (reward_type == 'staminas_st') then
        item_id = 700101
    elseif (reward_type == 'staminas_pvp') then
        item_id = 700102
    end

    -- 아이템 정보가 유효한 경우(타입 체크)
    if item_id then
        local t_item = self:get(item_id)
        if t_item and (t_item['type'] == reward_type) then
            return t_item
        end
    end

    -- 지정된 id가 없을 경우 수동으로 찾음
    local l_item_list = self:filterList('type', reward_type)

    -- 해당하는 타입의 행이 많은 결루 item_id가 가장 낮은 정보를 선택
    table.sort(l_item_list, function(a, b)
            return a['item'] < b['item']
        end)
	local t_item = l_item_list[1]

	return t_item
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