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

    if data then
        self:applyTableData(data)
    end
end

-------------------------------------
-- function applyTableData
-------------------------------------
function StructCollectionData:applyTableData(data)
    for i,v in pairs(data) do
        self[i] = v
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