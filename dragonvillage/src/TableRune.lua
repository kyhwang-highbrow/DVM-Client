local PARENT = TableClass

-------------------------------------
-- class TableRune
-------------------------------------
TableRune = class(PARENT, {
})

local THIS = TableRune
-------------------------------------
-- function init
-------------------------------------
function TableRune:init()
    self.m_tableName = 'table_rune'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getRuneSetId
-------------------------------------
function TableRune:getRuneSetId(rune_id)
    if (self == THIS) then
        self = THIS()
    end

        -- 룬 ID를 통해 세트ID, 슬롯, 등급 정보를 가져옴
    -- 710111
    -- 71xxxx -- 룬 아이디 식별 코드
    -- xx01xx -- set_id 1번 세트
    -- xxxx1x -- slot 1번 슬롯
    -- xxxxx1 -- grade 등급

    if self.m_orgTable == nil or self:exists(rune_id) == false then
        return getDigit(rune_id, 100, 2)
    end


    local set_id = self:getValue(rune_id, 'set_id')
    return set_id
end

-------------------------------------
-- function getRuneGrade
-------------------------------------
function TableRune:getRuneGrade(rune_id)
    if (self == THIS) then
        self = THIS()
    end

        -- 룬 ID를 통해 세트ID, 슬롯, 등급 정보를 가져옴
    -- 710111
    -- 71xxxx -- 룬 아이디 식별 코드
    -- xx01xx -- set_id 1번 세트
    -- xxxx1x -- slot 1번 슬롯
    -- xxxxx1 -- grade 등급

    if  self.m_orgTable == nil or self:exists(rune_id) == false then
        return getDigit(rune_id, 1, 1)
    end

    local grade = self:getValue(rune_id, 'grade')
    return grade
end

-------------------------------------
-- function getRuneSlot
-------------------------------------
function TableRune:getRuneSlot(rune_id)
    if (self == THIS) then
        self = THIS()
    end

    
    -- 룬 ID를 통해 세트ID, 슬롯, 등급 정보를 가져옴
    -- 710111
    -- 71xxxx -- 룬 아이디 식별 코드
    -- xx01xx -- set_id 1번 세트
    -- xxxx1x -- slot 1번 슬롯
    -- xxxxx1 -- grade 등급

    if self.m_orgTable == nil or self:exists(rune_id) == false then
        return getDigit(rune_id, 10, 1)
    end


    local slot = self:getValue(rune_id, 'slot')
    return slot
end