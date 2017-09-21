local PARENT = TableClass

-------------------------------------
-- class TableTamerCostume
-------------------------------------
TableTamerCostume = class(PARENT, {
    })

local THIS = TableTamerCostume

-------------------------------------
-- function init
-------------------------------------
function TableTamerCostume:init()
    self.m_tableName = 'tamer_costume'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getDefaultCostumeID
-- @brief ���̸��� �⺻ �ڽ�Ƭ ID (ex:730100  item digit 73, tamer digit 2�ڸ�, costume digit 2�ڸ� (default:0))
-------------------------------------
function TableTamerCostume:getDefaultCostumeID(tamer_id)
    local tamer_idx = tonumber(tamer_id)%100
    local default_id = string.format('73%02d00', tamer_idx)
    return tonumber(default_id)
end

-------------------------------------
-- function getTamerResSD
-------------------------------------
function TableTamerCostume:getTamerResSD(cid)
    if (self == THIS) then
        self = THIS()
    end

    local path = self:getValue(cid, 'res_sd')
    return path
end

-------------------------------------
-- function getTamerSDImage
-------------------------------------
function TableTamerCostume:getTamerSDImage(cid)
    if (self == THIS) then
        self = THIS()
    end

    local path = self:getValue(cid, 'res_icon')
    local image = cc.Sprite:create(path)
    if (image) then
        image:setDockPoint(CENTER_POINT)
        image:setAnchorPoint(CENTER_POINT)
    end

    return image
end

