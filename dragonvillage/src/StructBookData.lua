-------------------------------------
-- class StructBookData
-- @instance
-------------------------------------
StructBookData = class({
        dragon_id = 'number',
        grade = 'number',
        relation = 'number',
        evolution = 'number',
		rate = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function StructBookData:init(data)
    self.dragon_id = nil
    self.grade = 0
    self.relation = 0
    self.evolution = 0
	self.rate = 0

    if data then
        self:applyTableData(data)
    end
end

-------------------------------------
-- function applyTableData
-------------------------------------
function StructBookData:applyTableData(data)
	-- 서버에서 key값을 줄여서 쓴 경우가 있어서 변환해준다
    local replacement = {}
    replacement['evo'] = 'evolution'
	replacement['rel'] = 'relation'

    for i,v in pairs(data) do
        local key = replacement[i] and replacement[i] or i
        self[key] = v
    end
end

-------------------------------------
-- function setDragonID
-------------------------------------
function StructBookData:setDragonID(did)
    self.dragon_id = did
end

-------------------------------------
-- function setRelation
-------------------------------------
function StructBookData:setRelation(relation)
    self.relation = relation
end

-------------------------------------
-- function getRelation
-------------------------------------
function StructBookData:getRelation()
    return self.relation
end

-------------------------------------
-- function setRate
-------------------------------------
function StructBookData:setRate(rate)
    self.rate = rate
end

-------------------------------------
-- function getRate
-------------------------------------
function StructBookData:getRate()
    return self.rate
end

-------------------------------------
-- function getGrade
-------------------------------------
function StructBookData:getGrade()
    return self.grade
end

-------------------------------------
-- function getEvolution
-------------------------------------
function StructBookData:getEvolution()
    return self.evolution
end