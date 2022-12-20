local PARENT = TableClass

-------------------------------------
---@class TablePackageAchievement
-------------------------------------
TablePackageAchievement = class(PARENT, {

})

local THIS = TablePackageAchievement

-------------------------------------
-- function init
-------------------------------------
function TablePackageAchievement:init()
    self.m_tableName = 'table_package_achievement'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

