-------------------------------------
-- class StructProduct
-------------------------------------
StructProduct = class({
        product_id = 'number',
        t_name = 'string',
        t_desc = 'string',

        price_type = 'string',
        price = 'number',
        price_dollar = 'number',
        product_content = 'string',
        icon = 'string',
        max_buy_count = 'number',
        max_buy_term = 'string',



        m_tabCategory = 'string',
        m_startDate = 'pl.Date',
        m_endDate = 'pl.Date',
        m_dependency = 'product_id',
    })

-------------------------------------
-- function init
-------------------------------------
function StructProduct:init(data)
    self.price_dollar = 0

    if data then
        self:applyTableData(data)
    end
end

-------------------------------------
-- function applyTableData
-------------------------------------
function StructProduct:applyTableData(data)
    for key,value in pairs(data) do
        self[key] = value
    end
end

-------------------------------------
-- function setTabCategory
-------------------------------------
function StructProduct:setTabCategory(tab_category)
    self.m_tabCategory = tab_category
end

-------------------------------------
-- function getTabCategory
-------------------------------------
function StructProduct:getTabCategory()
    return self.m_tabCategory
end

-------------------------------------
-- function setStartDate
-------------------------------------
function StructProduct:setStartDate(date)
    self.m_startDate = date
end

-------------------------------------
-- function setEndDate
-------------------------------------
function StructProduct:setEndDate(date)
    self.m_endDate = date
end

-------------------------------------
-- function setDependency
-------------------------------------
function StructProduct:setDependency(product_id)
    if (product_id == '') then
        product_id = nil
    end
    self.m_dependency = product_id
end

-------------------------------------
-- function getDependency
-------------------------------------
function StructProduct:getDependency()
    return self.m_dependency
end

-------------------------------------
-- function isItBuyable
-------------------------------------
function StructProduct:isItBuyable()
    return false
end

-------------------------------------
-- function getDesc
-------------------------------------
function StructProduct:getDesc()
    if self['t_desc'] and (self['t_desc'] ~= '') then
        return Str(self['t_desc'])
    end

    local l_item_list = ServerData_Item:parsePackageItemStr(self['product_content'])
    if (not l_item_list) then
        return ''
    end

    local first_item = l_item_list[1]
    if (not first_item) or (not first_item['item_id']) then
        return ''
    end

    -- 첫 번째 아이템의 설명을 사용
    local table_item = TableItem()
    local item_id = first_item['item_id']
    local t_desc = table_item:getValue(item_id, 't_desc')
    return Str(t_desc)
end

-------------------------------------
-- function makeProductIcon
-------------------------------------
function StructProduct:makeProductIcon()
    if self['icon'] and (self['icon'] ~= '') then
        return IconHelper:getIcon(self['icon'])
    end

    local l_item_list = ServerData_Item:parsePackageItemStr(self['product_content'])
    if (not l_item_list) then
        return nil
    end

    local first_item = l_item_list[1]
    if (not first_item) or (not first_item['item_id']) then
        return nil
    end

    -- 첫 번째 아이템의 설명을 사용
    local table_item = TableItem()
    local item_id = first_item['item_id']
    return IconHelper:getItemIcon(item_id)
end

-------------------------------------
-- function makePriceIcon
-------------------------------------
function StructProduct:makePriceIcon()
    local price_type = self['price_type']

    if (price_type == 'money') then
        price_type = 'krw'
    end

    local res = string.format('res/ui/icon/item/%s.png', price_type)

    local icon = IconHelper:getIcon(res)
    return icon
end

-------------------------------------
-- function getPriceStr
-------------------------------------
function StructProduct:getPriceStr()
    return comma_value(self['price'])
end