local PARENT = TableClass

-------------------------------------
-- class TableItem
-------------------------------------
TableItem = class(PARENT, {
    })

local THIS = TableItem

ITEM_ID_CASH = 700001
ITEM_ID_GOLD = 700002
ITEM_ID_AMET = 700007
ITEM_ID_ST = 700101

-------------------------------------
-- function init
-------------------------------------
function TableItem:init()
    self.m_tableName = 'item'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-- item테이블의 단순 재화의 item_id 맵
local ITEM_ID_MAP = {}
ITEM_ID_MAP['cash'] = 700001
ITEM_ID_MAP['gold'] = 700002
ITEM_ID_MAP['fp'] = 700003
ITEM_ID_MAP['honor'] = 700005
ITEM_ID_MAP['badge'] = 700006
ITEM_ID_MAP['amethyst'] = 700007
ITEM_ID_MAP['mileage'] = 700008
ITEM_ID_MAP['topaz'] = 700009
ITEM_ID_MAP['capsule'] = 700201
ITEM_ID_MAP['event'] = 700202

ITEM_ID_MAP['stamina'] = 700101
ITEM_ID_MAP['staminas_st'] = 700101
ITEM_ID_MAP['staminas_pvp'] = 700102
ITEM_ID_MAP['staminas_tower'] = 700103

local ITEM_TYPE_MAP = {}
for i,v in pairs(ITEM_ID_MAP) do
    ITEM_TYPE_MAP[v] = i
end



-------------------------------------
-- function getItemIDFromItemType
-- @brief item_id를 문자열로 입력된 경우 치환해주는 함수
-------------------------------------
function TableItem:getItemIDFromItemType(item_type)
    local item_id = ITEM_ID_MAP[item_type]
    return item_id
end

-------------------------------------
-- function getItemTypeFromItemID
-- @brief item_id를 문자열로 치환해주는 함수
-------------------------------------
function TableItem:getItemTypeFromItemID(item_id)
    local item_type = ITEM_TYPE_MAP[item_id]
    return item_type
end

-------------------------------------
-- function getRewardItem
-- @brief 보상용 아이템을 찾는다
-------------------------------------
function TableItem:getRewardItem(reward_type)
    -- 단순 재화의 id가 지정된 경우
    local item_id = self:getItemIDFromItemType(reward_type)

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
    if (self == THIS) then
        self = THIS()
    end

    local trim_execution = true
    local l_region = self:getSemicolonSeparatedValues(item_id, 'get_region', trim_execution)

    return l_region
end

-------------------------------------
-- function getItemName
-- @brief
-------------------------------------
function TableItem:getItemName(item_id)
    if (self == THIS) then
        self = THIS()
    end

    local item_name = self:getValue(item_id, 't_name')
    return Str(item_name)
end

-------------------------------------
-- function getRuneItemIDList
-- @brief
-------------------------------------
function TableItem:getRuneItemIDList()
    if (self == THIS) then
        self = THIS()
    end

    local l_rune_item_list = self:filterList('type', 'rune')

    local sort_manager = SortManager_Rune()
    --sort_manager:pushSortOrder('grade')
    --sort_manager:pushSortOrder('rarity')
    --sort_manager:pushSortOrder('set_id')
    sort_manager:pushSortOrder('slot')
    sort_manager:sortExecution(l_rune_item_list)

    -- item_id만 들어가는 리스트 생성
    local l_ret = {}
    for _,v in ipairs(l_rune_item_list) do
        table.insert(l_ret, v['item'])
    end

    return l_ret
end

-------------------------------------
-- function getFruitsListByAttr
-- @brief 특정 속성의 열매 id 리스트를 리턴
-------------------------------------
function TableItem:getFruitsListByAttr(attr)
    if (self == THIS) then
        self = THIS()
    end

    local function condition_func(t_table)
        if (t_table['type'] ~= 'fruit') then
            return false
        end

        if (t_table['attr'] ~= attr) then
            return false
        end

        return true
    end

    local l_fruit_list = self:filterList_condition(condition_func)
    table.sort(l_fruit_list, function(a, b)
            return a['grade'] < b['grade']
        end)

    return l_fruit_list
end

-------------------------------------
-- function getDisplayItemIDList
-- @brief UI에 표기할 아이템 ID 리턴
-------------------------------------
function TableItem:getDisplayItemIDList(item_id)
    if (self == THIS) then
        self = THIS()
    end

    local type = self:getValue(item_id, 'type')
    if (type ~= 'rand') then
        return {item_id}
    end

    local icon = self:getValue(item_id, 'icon')
    if icon and (icon ~= '') then
        return {item_id}
    end

    return TableItemRand:getRandItemList(item_id)
end

-------------------------------------
-- function getItemType
-- @brief
-------------------------------------
function TableItem:getItemType(item_id)
    if (self == THIS) then
        self = THIS()
    end

    return self:getValue(item_id, 'type')
end

-------------------------------------
-- function getEggRes
-- @brief
-------------------------------------
function TableItem:getEggRes(egg_id)
    if (self == THIS) then
        self = THIS()
    end

    local egg_id = tonumber(egg_id)
    local full_type = self:getValue(egg_id, 'full_type')
    local res = 'res/item/egg/' .. full_type .. '/' .. full_type .. '.vrp'
    return res
end

-------------------------------------
-- function getItemIDByDid
-- @brief
-------------------------------------
function TableItem:getItemIDByDid(did, evolution)
    if (self == THIS) then
        self = THIS()
    end
	if (not did) then
		return
	end
	
	local evolution = evolution or 3

	--[[
	local l_dragon_item_list = self:filterList('type', 'dragon')
	for i, dragon_item in pairs(l_dragon_item_list) do
		if (dragon_item['did'] == did) and (dragon_item['evolution'] == evolution) then
			return dragon_item['item']
		end
	end
	]]

	local item_id = did + 640000 + (evolution * 10000)
	return item_id
end
