local PARENT = TableClass

-------------------------------------
-- class TableRuneExp
-------------------------------------
TableRuneExp = class(PARENT, {
        m_lMaxLevel = 'list',
    })

-------------------------------------
-- function init
-------------------------------------
function TableRuneExp:init()
    self.m_tableName = 'rune_exp'
    self.m_orgTable = TABLE:get(self.m_tableName)
end


-------------------------------------
-- function getRuneMaxLevel
-- @brief 룬의 등급별 최대 레벨을 얻어옴
-------------------------------------
function TableRuneExp:getRuneMaxLevel(grade)
    if (not self.m_lMaxLevel) then
        self.m_lMaxLevel = {}

        for i,v in ipairs(self.m_orgTable) do
            for _grade=1, 5 do
                local req_exp = v['req_exp_grade' .. _grade]
                if (req_exp == 'x') or (req_exp == '') then
                    local max_level = i
                    self.m_lMaxLevel[_grade] = max_level
                end
            end
        end
    end

    grade = (grade or 1)
    local max_level = self.m_lMaxLevel[grade]
    return max_level
end

-------------------------------------
-- function getReqExp
-- @brief 필요 경험치를 얻어옴
-------------------------------------
function TableRuneExp:getReqExp(grade, lv)
    if (self == TableRuneExp) then
        self = TableRuneExp()
    end

    local max_exp = self:getValue(lv, 'req_exp_grade' .. grade)

    -- 최대레벨의 경우
    if (max_exp == '') or (max_exp == 'x') then
        max_exp = 0
    end

    return max_exp
end