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
function TableDragonExp:getDragonMaxExp(grade, lv, is_myth_dragon)
    local column_name = is_myth_dragon and 'max_exp_myth' or 'max_exp'
    local eid = self:makeExpID(grade, lv)
    local max_exp = self:getValue(eid, column_name)
    return max_exp or 0
end

-------------------------------------
-- function getDragonGivingExp
-- @breif
-------------------------------------
function TableDragonExp:getDragonGivingExp(grade, lv, is_myth_dragon)
    local column_name = is_myth_dragon and 'giving_exp_myth' or 'giving_exp'
    local eid = self:makeExpID(grade, lv)
    local max_exp = self:getValue(eid, column_name)
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
function TableDragonExp:getGoldPerLevelUp(grade, lv, is_myth_dragon)
    local column_name = is_myth_dragon and 'req_gold_per_lvup_myth' or 'req_gold_per_lvup'
	local eid = self:makeExpID(grade, lv)
	local gold = self:getValue(eid, column_name)
	return gold
end


-------------------------------------
-- function getGoldAndDragonEXPForDragonLevelUp
-- @brief 드래곤 레벨업에 드는 골드, 드래곤 경험치
-- @return total_gold
-- @return total_dragon_exp
-------------------------------------
function TableDragonExp:getGoldAndDragonEXPForDragonLevelUp(grade, lv, target_lv, is_myth_dragon)
    local total_gold = 0
    local total_dragon_exp = 0

    -- 시작 레벨부터 목표 레벨까지 필요 골드, 드래곤 경험치 계산
    for _lv=lv, target_lv-1 do
        total_gold = (total_gold + self:getGoldPerLevelUp(grade, _lv, is_myth_dragon))
        total_dragon_exp = (total_dragon_exp + self:getDragonMaxExp(grade, _lv, is_myth_dragon))
    end

    return total_gold, total_dragon_exp
end