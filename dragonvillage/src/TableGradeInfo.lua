local PARENT = TableClass

local ECVL_KEY_OFFSET = 100

-- initGlobal 함수에서 설정함
MAX_DRAGON_GRADE = nil
MAX_DRAGON_ECLV = nil

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
function TableGradeInfo:isMaxLevel(grade, eclv, level)
    if (self == THIS) then
        self = THIS()
    end

    local max_lv = self:getMaxLv(grade, eclv)
    return (max_lv <= level)
end

-------------------------------------
-- function getMaxLv
-------------------------------------
function TableGradeInfo:getMaxLv(grade, eclv)
    if (self == THIS) then
        self = THIS()
    end

    local key

    if (eclv and 1 <= eclv) then
        key = self:makeEclvKey(eclv)
    else
        key = grade
    end

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
-- function getEclvBonusStatusLv
-------------------------------------
function TableGradeInfo:getEclvBonusStatusLv(eclv)
    if (self == THIS) then
        self = THIS
    end

    if (eclv <= 0) then
        return 0
    end

    local key = self:makeEclvKey(eclv)
    local lv = self:getValue(key, 'bonus_status_lv')
    return lv
end

-------------------------------------
-- function makeEclvKey
-- @brief 테이블상에서의 초월 key값 생성
-------------------------------------
function TableGradeInfo:makeEclvKey(eclv)
    if (not eclv) or (eclv <= 0) then
        return nil
    end

    local eclv_key = ECVL_KEY_OFFSET + eclv
    return eclv_key
end

-------------------------------------
-- function initGlobal
-------------------------------------
function TableGradeInfo:initGlobal()
    if (self == THIS) then
        self = THIS()
    end

    MAX_DRAGON_GRADE = nil
    MAX_DRAGON_ECLV = nil

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
        -- 초월
        else
            local eclv = (key - ECVL_KEY_OFFSET)
            if (not MAX_DRAGON_ECLV) then
                MAX_DRAGON_ECLV = eclv
            elseif (MAX_DRAGON_ECLV < eclv) then
                MAX_DRAGON_ECLV = eclv
            end
        end
    end
end

-------------------------------------
-- function dragonMaxLevel
-- @brief 드래곤 승급(grade)별 최대 레벨
-------------------------------------
function dragonMaxLevel(grade, eclv)
    return TableGradeInfo:getMaxLv(grade, eclv)
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

-------------------------------------
-- function isMaxEclv
-- @breif 최대 등급의 드래곤인지 확인
-------------------------------------
function TableGradeInfo:isMaxEclv(eclv)
    if (MAX_DRAGON_ECLV <= eclv) then
        return true
    else
        return false
    end
end

-------------------------------------
-- function getEclvUpgradeReqGold
-- @breif
-------------------------------------
function TableGradeInfo:getEclvUpgradeReqGold(eclv)
    if (self == THIS) then
        self = THIS()
    end

    local key = self:makeEclvKey(eclv)
    
    if (not key) then
        return 0
    end

    local req_gold = self:getValue(key, 'req_gold')
    return req_gold
end