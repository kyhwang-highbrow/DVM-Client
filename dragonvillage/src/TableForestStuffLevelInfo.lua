local PARENT = TableClass

-------------------------------------
-- class TableForestStuffLevelInfo
-------------------------------------
TableForestStuffLevelInfo = class(PARENT, {
    })

local THIS = TableForestStuffLevelInfo

local T_STUFF_TABLE = nil

-------------------------------------
-- function init
-------------------------------------
function TableForestStuffLevelInfo:init()
    self.m_tableName = 'table_forest_stuff_info'
    self.m_orgTable = TABLE:get(self.m_tableName)

    if (not T_STUFF_TABLE) then
        self:makeFilteredTable()
    end
end

-------------------------------------
-- function init
-------------------------------------
function TableForestStuffLevelInfo:makeFilteredTable()
    local l_key = {'nest', 'chest', 'table', 'well', 'bookshelf', 'extension'}
    T_STUFF_TABLE = {}
    for _, key in ipairs(l_key) do
        T_STUFF_TABLE[key] = self:filterList('stuff_type', key)
    end
end

-------------------------------------
-- function getOpenLevel
-------------------------------------
function TableForestStuffLevelInfo:getOpenLevel(stuff_type)
    if (self == THIS) then
        self = THIS()
    end

    if (not stuff_type) then
        return 0
    end

    return T_STUFF_TABLE[stuff_type][1]['open_lv']
end

-------------------------------------
-- function getOpenLavel
-------------------------------------
function TableForestStuffLevelInfo:getDragonMaxCnt(lv)
    if (self == THIS) then
        self = THIS()
    end
    if (not lv) then
        return 0
    end

    local t_extension = T_STUFF_TABLE['extension']
    return t_extension[lv]['dragon_cnt']
end