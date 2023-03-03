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

    return self:getTableKeyList()
end


-------------------------------------
-- function getDefaultSkinID
-- @brief 드래곤의 기본 스킨 ID
-------------------------------------
function TableDragonSkin:getDefaultSkinID(did)
    -- local tamer_idx = tonumber(tamer_id)%100
    local default_id = 0

    -- return self:getValue(did, 'skin_id')
    return default_id
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

