local PARENT = TableClass

local ECVL_KEY_OFFSET = 100 -- 초월은 삭제되었지만 테이블 구조로 인해 남겨둠

-- initGlobal 함수에서 설정함
MAX_DRAGON_GRADE = nil

-------------------------------------
-- class TableGradeInfo
-------------------------------------
TableGradeInfo = class(PARENT, {
    })

local THIS = TableGradeInfo

-------------------------------------
-- function init
-------------------------------------
function TableGradeInfo:init()
    self.m_tableName = 'grade_info'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function isMaxLevel
-------------------------------------
function TableGradeInfo:isMaxLevel(grade, level)
    if (self == THIS) then
        self = THIS()
    end

    local max_lv = self:getMaxLv(grade)
    return (max_lv <= level), max_lv
end

-------------------------------------
-- function getMaxLv
-------------------------------------
function TableGradeInfo:getMaxLv(grade)
    if (self == THIS) then
        self = THIS()
    end

    local key = grade

    local max_lv = self:getValue(key, 'max_lv')
    return max_lv
end

-------------------------------------
-- function getBonusStatusLv
-------------------------------------
function TableGradeInfo:getBonusStatusLv(grade)
    if (self == THIS) then
        self = THIS
    end

    local lv = self:getValue(grade, 'bonus_status_lv')
    return lv
end

-------------------------------------
-- function initGlobal
-------------------------------------
function TableGradeInfo:initGlobal()
    if (self == THIS) then
        self = THIS()
    end

    MAX_DRAGON_GRADE = nil

    for i,v in pairs(self.m_orgTable) do
        local key = v['grade']

        -- 등급
        if (key < ECVL_KEY_OFFSET) then
            local grade = key
            if (not MAX_DRAGON_GRADE) then
                MAX_DRAGON_GRADE = grade
            elseif (MAX_DRAGON_GRADE < grade) then
                MAX_DRAGON_GRADE = grade
            end
        -- 초월 (테이블 구조때문에 남겨둠)
        else

        end
    end
end

-------------------------------------
-- function dragonMaxLevel
-- @brief 드래곤 승급(grade)별 최대 레벨
-------------------------------------
function dragonMaxLevel(grade)
    return TableGradeInfo:getMaxLv(grade)
end

-------------------------------------
-- function isMaxGrade
-- @breif 최대 등급의 드래곤인지 확인
-------------------------------------
function TableGradeInfo:isMaxGrade(grade)
    if (MAX_DRAGON_GRADE <= grade) then
        return true
    else
        return false
    end
end

local T_ORIGIN_GRADE = {
	common = 1,
	rare = 3,
	hero = 4,
	legend = 5,
    myth = 6,
}
-------------------------------------
-- function getOriginGrade
-- @breif 태생 등급을 리턴한다.
-------------------------------------
function TableGradeInfo:getOriginGrade(rarity)
    return T_ORIGIN_GRADE[rarity]
end
