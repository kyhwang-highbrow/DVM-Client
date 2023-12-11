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
        if self:isButtonVisible(product_id) == true then
            return v
        end
    end
    return nil
end

-------------------------------------
--- @function isRecentPackage
-------------------------------------
function ServerData_AdventureBreakthroughAbyssPackage:isRecentPackage(product_id)
    if (type(product_id) ~= 'number') then
        product_id = tonumber(product_id) 
    end

    local index = self:getIndexFromProductId(product_id) - 4
    return (table.getn(self.m_productIdList) == index)
end

-------------------------------------
--- @function isReceivedReward
--- @breif 보상 수령 여부
-------------------------------------
function ServerData_AdventureBreakthroughAbyssPackage:isReceivableReward(product_id, target_stage_id) -- isReceived
    if (type(product_id) ~= 'number') then
        product_id = tonumber(product_id)
    end
 
    -- 모험돌파 n번 상품의 보상 정보 - csv 파일
    local reward_list = self:getRewardListFromProductId(product_id)

    for index, reward in pairs(reward_list) do
        local stage_id = reward['stage']

        if (stage_id == target_stage_id) and (self:isReceivedReward(product_id, stage_id) == false) then
            local stage_info = g_adventureData:getStageInfo(stage_id)
            local star = stage_info:getNumberOfStars()
            -- 보상 조건인 별 3개인 경우 혹은 판매 종료 된 패키지인 경우
            if (star >= 3) then
                return true
            end
        end
    end

    return false
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