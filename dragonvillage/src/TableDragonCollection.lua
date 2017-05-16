local PARENT = TableClass

-------------------------------------
-- class TableDragonCollection
-------------------------------------
TableDragonCollection = class(PARENT, {
    })

local THIS = TableDragonCollection

-------------------------------------
-- function init
-------------------------------------
function TableDragonCollection:init()
    self.m_tableName = 'table_dragon_collection'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getDragonCollectionTitle
-- @breif 이름을 뭘로 지어야 하나....
-------------------------------------
function TableDragonCollection:getDragonCollectionTitle(collection_key_list)
    if (self == THIS) then
        self = THIS()
    end

    local collection_key_list = collection_key_list or {}
    
    local max_key = 0
    for i,v in pairs(collection_key_list) do
        local _key = tonumber(v)
        if (max_key < _key) then
            max_key = _key
        end
    end

    local title = self:getValue(max_key, 't_desc')
    return Str(title)
end