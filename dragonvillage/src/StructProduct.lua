-------------------------------------
-- class StructProduct
-------------------------------------
StructProduct = class({
        product_id = 'number',
        t_name = 'string',
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