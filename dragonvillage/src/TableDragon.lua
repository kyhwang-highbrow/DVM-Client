local PARENT = TableClass

-------------------------------------
-- class TableDragon
-------------------------------------
TableDragon = class(PARENT, {
        m_lIllustratedDragonList = 'list', -- 드래곤 도감 리스트
        m_mIllustratedDragonIdx = 'table',
    })

local THIS = TableDragon

-------------------------------------
-- function init
-------------------------------------
function TableDragon:init()
    self.m_tableName = 'dragon'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getDragonRole
-------------------------------------
function TableDragon:getDragonRole(key)
    local t_skill = self:get(key)
    return t_skill['role']
end

-------------------------------------
-- function isSameDragonType
-------------------------------------
function TableDragon:isSameDragonType(did1, did2)
    local type1 = self:getValue(did1, 'type')
    local type2 = self:getValue(did2, 'type')

    return (type1 == type2), type1, type2
end

-------------------------------------
-- function initIllustratedDragonList
-- @breif 도감 리스트 초기화
-------------------------------------
function TableDragon:initIllustratedDragonList()
    if (self.m_lIllustratedDragonList and self.m_mIllustratedDragonIdx) then
        return
    end

    -- 드래곤 테이블에서 test값이 1인 드래곤만 추출
    --self.m_lIllustratedDragonList = self:filterList('test', 1)
    self.m_lIllustratedDragonList = self:filterList('none', nil)

    -- did순으로 정렬
    table.sort(self.m_lIllustratedDragonList, function(a, b)
        return a['did'] < b['did']
    end)

    -- 해당 did가 어떤 idx에 있는지 저장
    self.m_mIllustratedDragonIdx = {}
    for i,v in ipairs(self.m_lIllustratedDragonList) do
        self.m_mIllustratedDragonIdx[v['did']] = i
    end
end

-------------------------------------
-- function getIllustratedDragonList
-- @breif 도감 리스트
-------------------------------------
function TableDragon:getIllustratedDragonList()
    self:initIllustratedDragonList()
    return self.m_lIllustratedDragonList
end

-------------------------------------
-- function getIllustratedDragonIdx
-- @breif 도감 리스트
-------------------------------------
function TableDragon:getIllustratedDragonIdx(did)
    self:initIllustratedDragonList()
    return self.m_mIllustratedDragonIdx[did]
end

-------------------------------------
-- function getIllustratedDragon
-- @breif 도감 리스트
-------------------------------------
function TableDragon:getIllustratedDragon(idx)
    local illustrated_dragon_list = self:getIllustratedDragonList()
    return illustrated_dragon_list[idx]
end

-------------------------------------
-- function getRandomRow
-------------------------------------
function TableDragon:getRandomRow()
    --local l_list = self:filterList('test', 1)
    local l_list = self:filterList('none', nil)

    local cnt = table.count(l_list)
    local rand_num = math_random(1, cnt)

    local idx = 1
    for i,v in pairs(l_list) do
        if (idx == rand_num) then
            return clone(v)
        end

        idx = (idx + 1)
    end
end

-------------------------------------
-- function getRelationPoint
-------------------------------------
function TableDragon:getRelationPoint(did)
    local relation_point = self:getValue(did, 'relation_point')
    return relation_point
end

-------------------------------------
-- function getImplementedDid
-------------------------------------
function TableDragon:getImplementedDid(did)
    if (self == THIS) then
        self = THIS()
    end

    local value = self:getValue(did, 'test')
    if (value == 1) then
        return did
    else
        return 120011 -- 파워드래곤
    end
end