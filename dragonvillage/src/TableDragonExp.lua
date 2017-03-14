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
-- @brief table_dragon_exp.csv���� ����ϴ� eid�� ����� �Լ�
-------------------------------------
function TableDragonExp:makeExpID(grade, lv)
    local eid = (grade * 100) + lv
    return eid
end

-------------------------------------
-- function getDragonMaxExpmax_exp
-- @breif �巡���� ���, ������ ���� �ִ� ����ġ
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