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
function TableDragonSkin:getDragonSkinIdList(did)
    if (self == THIS) then
        self = THIS()
    end

    local ret = self:filterTable_conditionDate('start_date', 'end_date')
    local id_list = {}

    for _, v in pairs(ret) do

        if did ~= nil then
            if did == v['did'] then
                table.insert(id_list, v['skin_id'])                
            end
        else
            table.insert(id_list, v['skin_id'])
        end

        
    end

    return id_list
end


-------------------------------------
-- function getDragonSkinInfo
-------------------------------------
function TableDragonSkin:getDragonSkinInfo(skin_id)
    if (self == THIS) then
        self = THIS()
    end

    return self:get(skin_id)
end


-------------------------------------
-- function getDefaultSkinID
-- @brief 드래곤의 기본 스킨 ID
-------------------------------------
function TableDragonSkin:getDefaultSkinID(did)
    return 0
end


-------------------------------------
-- function getDragonSkinValue
-------------------------------------
function TableDragonSkin:getDragonSkinValue(col_name, skin_id)
    if (self == THIS) then
        self = THIS()
    end

    return self:getValue(skin_id, col_name)
end

