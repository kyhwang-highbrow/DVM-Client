local PARENT = TableClass
-------------------------------------
-- class TableLairSchedule
-------------------------------------
TableLairSchedule = class(PARENT, {
})

local instance = nil
-------------------------------------
-- function init
-------------------------------------
function TableLairSchedule:init()
    assert(instance == nil, 'Can not initalize twice')
    self.m_tableName = 'table_lair_schedule'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getInstance
---@return TableLairSchedule instance
-------------------------------------
function TableLairSchedule:getInstance()
    if (instance == nil) then
        instance = TableLairSchedule()
    end
    return instance
end

-------------------------------------
-- function getLairSeasonName
---@return string
-------------------------------------
function TableLairSchedule:getLairSeasonName(season_id)
    local str = self:getValue(season_id, 't_season_id') or ''
    return Str(str)
end

-------------------------------------
-- function getLairSeasonDesc
---@return string
-------------------------------------
function TableLairSchedule:getLairSeasonDesc(season_id)
    local str = self:getValue(season_id, 't_season_desc') or ''
    return Str(str)
end

-------------------------------------
-- function getLairSpecialType
---@return number
-------------------------------------
function TableLairSchedule:getLairSpecialType(season_id)
    return self:getValue(season_id, 'special_type') or 1
end