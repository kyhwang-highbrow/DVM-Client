local PARENT = ServerData_AdventureBreakthroughPackage
-------------------------------------
-- class ServerData_AdventureBreakthroughAbyssPackage
-------------------------------------
ServerData_AdventureBreakthroughAbyssPackage = class(PARENT, {
})

-------------------------------------
-- function init
-------------------------------------
function ServerData_AdventureBreakthroughAbyssPackage:init(server_data)
    self.m_serverData = server_data
    --90057, 110281, 110282, 110283
    --self.m_productIdList = {122458, 122459} -- 모험 돌파 패키지 1, 2, 3, 4    
    self.m_productIdList = {122458, 122459} -- 모험 돌파 패키지 1, 2, 3, 4    
    self.m_tableKeyword = 'table_package_stage_%02d'
    self.m_dataList = {}
end

-------------------------------------
-- function getIndexFromProductId
-------------------------------------
function ServerData_AdventureBreakthroughAbyssPackage:getIndexFromProductId(product_id)
    if (type(product_id) ~= 'number') then
        product_id = tonumber(product_id) 
    end

    local index = table.find(self.m_productIdList, product_id)

    if index ~= nil then
        return index + 4
    end

    return index
end

-------------------------------------
--- @function getAdventureBreakThroughAbyssProduct
-------------------------------------
function ServerData_AdventureBreakthroughAbyssPackage:getAdventureBreakThroughAbyssProduct()
    local struct_product_list = g_shopDataNew:getProductList('abyss_pass')
    for product_id, v in pairs(struct_product_list) do
        if self:checkPackage(product_id) == true and self:isButtonVisible(product_id) == true then
            return v
        end
    end
    return nil
end

-------------------------------------
--- @function getAbyssProductIdList
-------------------------------------
function ServerData_AdventureBreakthroughAbyssPackage:getAbyssProductIdList()
    return self.m_productIdList
end

-------------------------------------
-- function getDataList
-------------------------------------
function ServerData_AdventureBreakthroughAbyssPackage:getDataList()
    return g_adventureBreakthroughPackageData:getDataList()
end