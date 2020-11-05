local PARENT = TableClass

-------------------------------------
-- class TableDragonExp
-------------------------------------
TableDragonExp = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableDragonExp:init()
    self.m_tableName = 'dragon_exp'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function makeExpID
-- @brief table_dragon_exp.csv에서 사용하는 eid를 만드는 함수
-------------------------------------
function TableDragonExp:makeExpID(grade, lv)
    local eid = (grade * 100) + lv
    return eid
end

-------------------------------------
-- function getDragonMaxExp
-- @breif 드래곤의 등급, 레벨에 따른 최대 경험치
-------------------------------------
function TableDragonExp:getDragonMaxExp(grade, lv)
    local eid = self:makeExpID(grade, lv)
    local max_exp = self:getValue(eid, 'max_exp')
    return max_exp or 0
end

-------------------------------------
-- function getDragonGivingExp
-- @breif
-------------------------------------
function TableDragonExp:getDragonGivingExp(grade, lv)
    local eid = self:makeExpID(grade, lv)
    local max_exp = self:getValue(eid, 'giving_exp')
    return max_exp or 0
end

-------------------------------------
-- function getDragonReqGoldPerMtrl
-- @breif
-------------------------------------
function TableDragonExp:getDragonReqGoldPerMtrl(grade, lv)
    local eid = self:makeExpID(grade, lv)
    local max_exp = self:getValue(eid, 'req_gold_per_mtrl')
    return max_exp or 0
end

-------------------------------------
-- function getDragonSellGold
-- @breif
-------------------------------------
function TableDragonExp:getDragonSellGold(grade, lv)
    local eid = self:makeExpID(grade, lv)
    local max_exp = self:getValue(eid, 'sell_gold')
    return max_exp or 0
end

-------------------------------------
-- function getGoldPerLevelUp
-- @brief 드래곤 레벨업에 드는 골드
-------------------------------------
function TableDragonExp:getGoldPerLevelUp(grade, lv)
	local eid = self:makeExpID(grade, lv)
	local gold = self:getValue(eid, 'req_gold_per_lvup')
	return gold
end