local PARENT = TableClass

-------------------------------------
-- class TableGradeInfo
-------------------------------------
TableGradeInfo = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableGradeInfo:init()
    self.m_tableName = 'grade_info'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getDragonGradeAndExpInfo
-------------------------------------
function TableGradeInfo:getDragonGradeAndExpInfo(t_dragon_data)
    if (self == TableGradeInfo) then
        self = TableGradeInfo()
    end

    local grade = t_dragon_data['grade'] or 1
    local exp = t_dragon_data['gexp'] or 0

     
    local t_table = self:get(grade)
    local req_exp = t_table['req_exp']

    local percentage
    local is_max

    -- MAX 등급
    if (not req_exp) or (req_exp == 0) then
        percentage = 100
        is_max = true
    else
        percentage = (exp / req_exp) * 100
        percentage = math_clamp(percentage, 0, 100)
        is_max = false
    end
    percentage = math_floor(percentage)

    local t_grade_exp_info = {}
    t_grade_exp_info['percentage'] = percentage
    t_grade_exp_info['exp'] = exp
    t_grade_exp_info['req_exp'] = req_exp
    t_grade_exp_info['is_max'] = is_max

    return t_grade_exp_info
end