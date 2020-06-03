local PARENT = TableClass

-------------------------------------
-- class TableSlimeExp
-------------------------------------
TableSlimeExp = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableSlimeExp:init()
    self.m_tableName = 'table_slime_exp'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function makeExpID
-- @brief table_dragon_exp.csv에서 사용하는 eid를 만드는 함수
-------------------------------------
function TableSlimeExp:makeExpID(grade, lv)
    local eid = (grade * 100) + lv
    return eid
end

-------------------------------------
-- function getDragonMaxExp
-- @breif 드래곤의 등급, 레벨에 따른 최대 경험치
-------------------------------------
function TableSlimeExp:getDragonMaxExp(grade, lv)
    local eid = self:makeExpID(grade, lv)
    local max_exp = self:getValue(eid, 'max_exp')
    return max_exp or 0
end

-------------------------------------
-- function getDragonGivingExp
-- @breif
-------------------------------------
function TableSlimeExp:getDragonGivingExp(grade, lv)
    local eid = self:makeExpID(grade, lv)
    local max_exp = self:getValue(eid, 'giving_exp')
    return max_exp or 0
end

-------------------------------------
-- function getDragonReqGoldPerMtrl
-- @breif
-------------------------------------
function TableSlimeExp:getDragonReqGoldPerMtrl(grade, lv)
    local eid = self:makeExpID(grade, lv)
    local max_exp = self:getValue(eid, 'req_gold_per_mtrl')
    return max_exp or 0
end