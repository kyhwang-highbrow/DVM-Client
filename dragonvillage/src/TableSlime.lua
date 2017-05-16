local PARENT = TableClass

-------------------------------------
-- class TableSlime
-------------------------------------
TableSlime = class(PARENT, {
    })

local THIS = TableSlime

-------------------------------------
-- function init
-------------------------------------
function TableSlime:init()
    self.m_tableName = 'table_slime'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getValue
-------------------------------------
function TableSlime:getValue(primary, column)
    if (self == THIS) then
        self = THIS()
    end

    return PARENT.getValue(self, primary, column)
end

-------------------------------------
-- function getDesc
-------------------------------------
function TableSlime:getDesc(slime_id)
    local desc = self:getValue(slime_id, 't_desc')
    return Str(desc)
end

-------------------------------------
-- function getMaterialType
-------------------------------------
function TableSlime:getMaterialType(slime_id)
    return self:getValue(slime_id, 'material_type')
end

-------------------------------------
-- function isSlimeID
-------------------------------------
function TableSlime:isSlimeID(id)
    local code = getDigit(id, 1000, 3)
    --129113
    if (code == 129) then
        return true
    end
    return false
end

-------------------------------------
-- function getGivingExpInfo
-- @brief exp 슬라임을 드래곤 레벨업 재료로 사용했을 때
--        슬라임 테이블에 exp와 gold정보가 있으면 우선 사용
-------------------------------------
function TableSlime:getGivingExpInfo(id)
    if (self == THIS) then
        self = THIS()
    end

    -- 재료로 사용될 때 주는 경험치
    local giving_exp = self:getValue(id, 'giving_exp')
    if (giving_exp == '') then
        giving_exp = nil
    end

    -- 재료로 사용될 때 소모되는 골드 량
    local req_gold_per_mtrl = self:getValue(id, 'req_gold_per_mtrl')
    if (req_gold_per_mtrl == '') then
        req_gold_per_mtrl = nil
    end

    return giving_exp, req_gold_per_mtrl
end