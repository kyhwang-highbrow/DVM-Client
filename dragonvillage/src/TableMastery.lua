local PARENT = TableClass

-------------------------------------
-- class TableMastery
-------------------------------------
TableMastery = class(PARENT, {
    })

local THIS = TableMastery

-------------------------------------
-- function init
-------------------------------------
function TableMastery:init()
    self.m_tableName = 'table_mastery'
    self.m_orgTable = TABLE:get(self.m_tableName)
end


-------------------------------------
-- function getRequiredAmorQuantity
-- @brief 특성 레벨업에 필요한 아모르 수량 획득
-------------------------------------
function TableMastery:getRequiredAmorQuantity(dragon_rarity, mastery_lv)
    if (self == THIS) then
        self = THIS()
    end

    local key
    -- 특성 레벨은 10이 최대
    local mastery_lv = math_min(mastery_lv, 10)

    if (dragon_rarity == 'common') then
        key = 1000

    elseif (dragon_rarity == 'rare') then
        key = 2000

    elseif (dragon_rarity == 'hero') then
        key = 3000

    elseif (dragon_rarity == 'legend') then
        key = 4000

    else
        return 0
    end

    key = (key + mastery_lv)
    local package_item_str = self:getValue(key, 'price')
    if (not package_item_str) then
        return 0
    end


    local count = ServerData_Item:getItemCountFromPackageItemString(package_item_str, ITEM_ID_AMOR)
    return (count or 0)
end