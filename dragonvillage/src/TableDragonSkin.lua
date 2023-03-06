local PARENT = TableClass

-------------------------------------
-- class TableDragonSkin
-------------------------------------
TableDragonSkin = class(PARENT, {
    })

local THIS = TableDragonSkin

-------------------------------------
-- function init
-------------------------------------
function TableDragonSkin:init()
    self.m_tableName = 'dragon_skin'
    self.m_orgTable = TABLE:get(self.m_tableName)
end


-------------------------------------
-- function getDragonSkinIdList
-------------------------------------
function TableDragonSkin:getDragonSkinIdList()
    if (self == THIS) then
        self = THIS()
    end

    local ret = self:filterTable_conditionDate('start_date', 'end_date')
    local id_list = {}

    for _, v in pairs(ret) do
        table.insert(id_list, v['skin_id'])
    end

    return id_list
end


-------------------------------------
-- function getDefaultSkinID
-- @brief 드래곤의 기본 스킨 ID
-------------------------------------
function TableDragonSkin:getDefaultSkinID(did)
    return 0
end

-- -------------------------------------
-- -- function getDragonRes
-- -------------------------------------
-- function TableDragonSkin:getDragonRes(did)
--     if (self == THIS) then
--         self = THIS()
--     end

--     local path = self:getValue(did, 'res')
--     return path
-- end

-- -------------------------------------
-- -- function getDragonResIcon
-- -------------------------------------
-- function TableDragonSkin:getDragonResIcon(did)
--     if (self == THIS) then
--         self = THIS()
--     end

--     local path = self:getValue(did, 'res_icon')
--     return path
-- end


-------------------------------------
-- function getDragonSkinValue
-------------------------------------
function TableDragonSkin:getDragonSkinValue(col_name, skin_id)
    if (self == THIS) then
        self = THIS()
    end

    return self:getValue(skin_id, col_name)
end

