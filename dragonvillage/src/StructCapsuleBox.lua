local PARENT = Structure

-------------------------------------
-- class StructCapsuleBox
-------------------------------------
StructCapsuleBox = class(PARENT, {
		box_key = 'string',
		contents = 'table',
		total = 'number',
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
-- function setContents
-- @brief 갯수는 없는 상태
-------------------------------------
function StructCapsuleBox:setContents(t_content)
	if (not self['contents']) then
		self['contents'] = {}
	end

	for gift_id, item_str in pairs(t_content) do
		self['contents'][gift_id] = {
			['id'] = gift_id,
			['item'] = item_str,
			['count'] = 0
		}
	end
end

-------------------------------------
-- function setContentCount
-- @brief 갯수 부여
-------------------------------------
function StructCapsuleBox:setContentCount(t_count)
	ccdump(t_count)
	for gift_id, count in pairs(t_count) do
		if (self['contents'][gift_id]) then
			self['contents'][gift_id]['count'] = count
		end
	end
end

-------------------------------------
-- function setContents
-------------------------------------
function StructCapsuleBox:getContents()
	return self['contents']
end
