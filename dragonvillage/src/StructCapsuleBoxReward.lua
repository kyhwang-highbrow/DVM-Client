local PARENT = Structure

-------------------------------------
-- class StructCapsuleBoxReward
-------------------------------------
StructCapsuleBoxReward = class(PARENT, {
		id = 'number',
		rank = 'number',
		count = 'number',
		rate = 'number',

		item_id = 'number',
		item_cnt = 'number',
    })

local THIS = StructCapsuleBoxReward
-------------------------------------
-- function init
-------------------------------------
function StructCapsuleBoxReward:init(data)
	self.count = 0
	self.rate = 0
end

-------------------------------------
-- function getClassName
-------------------------------------
function StructCapsuleBoxReward:getClassName()
    return 'StructCapsuleBoxReward'
end

-------------------------------------
-- function getThis
-------------------------------------
function StructCapsuleBoxReward:getThis()
    return THIS
end

-------------------------------------
-- function setGiftID
-------------------------------------
function StructCapsuleBoxReward:setGiftID(gift_id)
	self.id = gift_id
	self.rank = math_floor(gift_id / 100) % 10
end

-------------------------------------
-- function setItem
-------------------------------------
function StructCapsuleBoxReward:setItem(item_str)
	local l_item = plSplit(item_str, ';')
	self.item_id = tonumber(l_item[1])
	self.item_cnt = tonumber(l_item[2])
end

-------------------------------------
-- function setCount
-------------------------------------
function StructCapsuleBoxReward:setCount(count)
	self.count = count
end

-------------------------------------
-- function calcRate
-------------------------------------
function StructCapsuleBoxReward:calcRate(total)
	self.rate = self.count/total
end

-------------------------------------
-- function getState
-------------------------------------
function StructCapsuleBoxReward:getState()
	if (self.rate > 0) then
		return Str('È¹µæ °¡´É')
	else
		return Str('È¹µæ ºÒ°¡')
	end
end
