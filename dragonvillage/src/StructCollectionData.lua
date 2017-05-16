-------------------------------------
-- class StructCollectionData
-- @instance
-------------------------------------
StructCollectionData = class({
        dragon_id = 'number',
        grade = 'number',
        relation = 'number',
        evolution = 'number',
        flv = 'number',
        exist = 'boolean',
		grade_lv_state = 'list<number>',
    })

-------------------------------------
-- function init
-------------------------------------
function StructCollectionData:init(data)
    self.dragon_id = nil
    self.grade = 1
    self.relation = 0
    self.evolution = 1
    self.flv = 0
    self.exist = false
	self.grade_lv_state = nil

    if data then
        self:applyTableData(data)
    end
end

-------------------------------------
-- function applyTableData
-------------------------------------
function StructCollectionData:applyTableData(data)
	-- 서버에서 key값을 줄여서 쓴 경우가 있어서 변환해준다
    local replacement = {}
    replacement['evo'] = 'evolution'
	replacement['rel'] = 'relation'
	replacement['g_lv'] = 'grade_lv_state'

    for i,v in pairs(data) do
        local key = replacement[i] and replacement[i] or i
        self[key] = v
    end
end

-------------------------------------
-- function setDragonID
-------------------------------------
function StructCollectionData:setDragonID(did)
    self.dragon_id = did
end

-------------------------------------
-- function setRelation
-------------------------------------
function StructCollectionData:setRelation(relation)
    self.relation = relation
end

-------------------------------------
-- function getRelation
-------------------------------------
function StructCollectionData:getRelation()
    return self.relation
end

-------------------------------------
-- function setExist
-------------------------------------
function StructCollectionData:setExist()
    self.exist = true
end

-------------------------------------
-- function isExist
-------------------------------------
function StructCollectionData:isExist()
    return self.exist
end

-------------------------------------
-- function getGrade
-------------------------------------
function StructCollectionData:getGrade()
    return self.grade
end

-------------------------------------
-- function getFLv
-------------------------------------
function StructCollectionData:getFLv()
    return self.flv
end

-------------------------------------
-- function getEvolution
-------------------------------------
function StructCollectionData:getEvolution()
    return self.evolution
end

-------------------------------------
-- function getGradeLvState
-------------------------------------
function StructCollectionData:getGradeLvState()
    return self.grade_lv_state
end