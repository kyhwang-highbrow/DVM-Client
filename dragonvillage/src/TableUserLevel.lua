local PARENT = TableClass

-------------------------------------
-- class TableUserLevel
-------------------------------------
TableUserLevel = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableUserLevel:init()
    self.m_tableName = 'user_level'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getUserLevelExpPercentage
-- @breif
-------------------------------------
function TableUserLevel:getUserLevelExpPercentage(lv, exp)
    local t_user_level = self:get(lv)

    local req_exp = t_user_level['req_exp']
    local percentage = (exp / req_exp)
    percentage = math_floor(percentage * 100)

    return percentage
end