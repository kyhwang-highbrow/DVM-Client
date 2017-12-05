-------------------------------------
-- class StructReinforcement
-- @instance dragon_obj
-------------------------------------
StructReinforcement = class({
		lv = 'number',
		exp = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function StructReinforcement:init(data)
	self['lv'] = 0
	self['exp'] = 0

	if data then
        self:applyTableData(data)
    end
end

-------------------------------------
-- function applyTableData
-- @breif 단순 데이터 table에서 struct로 맴버 변수를 설정하는 함수
-------------------------------------
function StructReinforcement:applyTableData(data)
    -- 서버에서 key값을 줄여서 쓴 경우가 있어서 변환해준다
    local replacement = {}

	-- 구조를 살짝 바꿔준다
    for i,v in pairs(data) do
        local key = replacement[i] and replacement[i] or i
        self[key] = v
    end
end

-------------------------------------
-- function getRlv
-- @breif
-------------------------------------
function StructFriendshipObject:getRlv()
    return self['lv']
end

-------------------------------------
-- function isMaxRlv
-- @breif
-------------------------------------
function StructFriendshipObject:isMaxRlv()
    return false
end

-------------------------------------
-- function getExp
-- @breif
-------------------------------------
function StructFriendshipObject:getExp()
    return self['exp']
end