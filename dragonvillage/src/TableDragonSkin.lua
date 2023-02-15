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
-- function getDefaultCostumeID
-- @brief 드래곤의 기본 스킨 ID
-------------------------------------
function TableDragonSkin:getDefaultCostumeID(dragon_id)
    -- local tamer_idx = tonumber(tamer_id)%100
    -- local default_id = string.format('73%02d00', tamer_idx)
    return tonumber(dragon_id)
end

-------------------------------------
-- function getTamerResSD
-------------------------------------
function TableDragonSkin:getDragonRes(did)
    if (self == THIS) then
        self = THIS()
    end

    local path = self:getValue(did, 'res')
    return path
end

-------------------------------------
-- function getTamerSDImage
-------------------------------------
function TableDragonSkin:getDragonResIcon(did)
    if (self == THIS) then
        self = THIS()
    end

    local path = self:getValue(did, 'res_icon')
    local image = cc.Sprite:create(path)
    if (image) then
        image:setDockPoint(CENTER_POINT)
        image:setAnchorPoint(CENTER_POINT)
    end

    return image
end

