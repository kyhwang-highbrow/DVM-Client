local PARENT = Structure

-------------------------------------
-- class StructCapsuleBox
-------------------------------------
StructCapsuleBox = class(PARENT, {
		box_key = 'string',
		contents = 'table',
		total = 'number',
		price = 'table',
    })

local THIS = StructCapsuleBox
-------------------------------------
-- function init
-------------------------------------
function StructCapsuleBox:init(data)
    if data then
        self:applyData(data)
    end
end

-------------------------------------
-- function getClassName
-------------------------------------
function StructCapsuleBox:getClassName()
    return 'StructCapsuleBox'
end

-------------------------------------
-- function getThis
-------------------------------------
function StructCapsuleBox:getThis()
    return THIS
end

-------------------------------------
-- function setBoxKey
-------------------------------------
function StructCapsuleBox:setBoxKey(box_key)
	self['box_key'] = box_key
end

-------------------------------------
-- function getBoxKey
-------------------------------------
function StructCapsuleBox:getBoxKey()
	return self['box_key']
end

-------------------------------------
-- function setTotal
-------------------------------------
function StructCapsuleBox:setTotal(total)
	self['total'] = total
end

-------------------------------------
-- function getTotal
-------------------------------------
function StructCapsuleBox:getTotal()
	return self['total']
end

-------------------------------------
-- function setPrice
-------------------------------------
function StructCapsuleBox:setPrice(price_str)
	local l_price_list = {}
	
	-- ���� Ÿ���� ������ ���� �� �� �ֵ���
	for _, each_price in ipairs(plSplit(price_str, ',')) do
		local t_price = {}
		local l_split = plSplit(each_price, ';')
		t_price['type'] = l_split[1]
		t_price['value'] = l_split[2]
		table.insert(l_price_list, t_price)
	end
	ccdump(l_price_list)
	self['price'] = l_price_list
end

-------------------------------------
-- function getPrice
-------------------------------------
function StructCapsuleBox:getPrice(idx)
	return self['price'][idx]
end

-------------------------------------
-- function getPriceList
-------------------------------------
function StructCapsuleBox:getPriceList()
	return self['price']
end

-------------------------------------
-- function setContents
-- @brief ������ ���� ����
-------------------------------------
function StructCapsuleBox:setContents(t_content)
	if (not self['contents']) then
		self['contents'] = {}
	end

	for gift_id, item_str in pairs(t_content) do
		local struct_reward = StructCapsuleBoxReward()
		struct_reward:setGiftID(gift_id)
		struct_reward:setItem(item_str)

		self['contents'][gift_id] = struct_reward
	end
end

-------------------------------------
-- function setContentCount
-- @brief ���� �ο�
-------------------------------------
function StructCapsuleBox:setContentCount(t_count)
	local total = self['total']
	for gift_id, count in pairs(t_count) do
		local struct_reward = self['contents'][gift_id]
		if (struct_reward) then
			struct_reward:setCount(count)
			struct_reward:calcRate(total)
		end
	end
end

-------------------------------------
-- function getContents
-------------------------------------
function StructCapsuleBox:getContents()
	local l_content = {}
	for _, content in pairs(self['contents']) do
		table.insert(l_content, content)
	end
	table.sort(l_content, function(a, b)
		local a_num = tonumber(a['id'])
		local b_num = tonumber(b['id'])
		return a_num < b_num
	end)

	return l_content
end

-------------------------------------
-- function getRankRewardList
-------------------------------------
function StructCapsuleBox:getRankRewardList(rank)
	local l_reward = {}
	for _, struct_reward in pairs(self['contents']) do
		if (struct_reward.rank == rank) then
			table.insert(l_reward, struct_reward)
		end
	end
	-- id ������� ����
	table.sort(l_reward, function(a, b)
		local a_num = tonumber(a['id'])
		local b_num = tonumber(b['id'])
		return a_num < b_num
	end)

	return l_reward
end