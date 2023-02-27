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
-- function getDefaultSkinID
-- @brief 드래곤의 기본 스킨 ID
-------------------------------------
function TableDragonSkin:getDefaultSkinID(did)
    -- local tamer_idx = tonumber(tamer_id)%100
    local default_id = 0

    --@dhkim 23.02.27 temp 하드코딩으로 default 스킨 찾아주는 중
    if did == 121854 then
        default_id = 731000
    elseif did == 121842 then
        default_id = 731010
    elseif did == 121752 then
        default_id = 731020
    elseif did == 121861 then
        default_id = 731030
    end

    -- return self:getValue(did, 'skin_id')
    return default_id
end

-------------------------------------
-- function getDragonRes
-------------------------------------
function TableDragonSkin:getDragonRes(did)
    if (self == THIS) then
        self = THIS()
    end

    local path = self:getValue(did, 'res')
    return path
end

-------------------------------------
-- function getDragonResIcon
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

