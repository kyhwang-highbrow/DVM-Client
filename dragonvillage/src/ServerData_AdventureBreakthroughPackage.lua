-- "stagepack_info":{
--     "110282":{
--       "active":true,
--       "received_list":[1110107]
--     },
--     "90057":{
--       "active":false,
--       "received_list":[]
--     },
--     "110281":{
--       "active":false,
--       "received_list":[]
--     }
--   }




-- isVisible_adventureClearPack 
-- 구매 전에는 출력하지 않고 구매 후에는 보상이 남은 경우 출력
-- (isActive() == true) and (isLeftRewardExist() == true)

-- isVisibleAtBattlePassShop
-- 구매전 출력 O, 구매 후 남은 보상이 있을 때,
-- (isActive() == false) or (isLeftRewardExist() == true)


-- isVisibleNotiAtLobby
-- (isActive() == false) and (isReceivableRewardExist() == true)
-- 구매 전에는 X, 받을 수 있는 보상 O

-- isVisible_adventureClearPackOnAdventureMap
-- 구매전에는 O, 구매 후 남은 보상이 있을 때,
-- 

-- isVisible_adventureClearPackNoti
-- 구매 후 출력, 받을 수 있는 보상이 있을 때



-------------------------------------
-- class ServerData_AdventureBreakthroughPackage
-------------------------------------
ServerData_AdventureBreakthroughPackage = class({
    m_serverData = 'ServerData',
    m_productIdList = 'List[number]',
    m_dataList = 'List[table]',

    m_tableKeyword = 'string',
})

-------------------------------------
-- function init
-------------------------------------
function ServerData_AdventureBreakthroughPackage:init(server_data)
    self.m_serverData = server_data
    self.m_productIdList = {90057, 110281, 110282, 110283} -- 모험 돌파 패키지 1, 2, 3, 4
    self.m_tableKeyword = 'table_package_stage_%02d'
    self.m_dataList = {}
end

-------------------------------------
-- function getIndexFromProductId
-------------------------------------
function ServerData_AdventureBreakthroughPackage:getIndexFromProductId(product_id)
    if (type(product_id) ~= 'number') then
        product_id = tonumber(product_id) 
    end

    local index = table.find(self.m_productIdList, product_id)

    return index
end


-------------------------------------
-- function checkPackage
-------------------------------------
function ServerData_AdventureBreakthroughPackage:checkPackage(product_id)
    if (type(product_id) ~= 'number') then
        product_id = tonumber(product_id) 
    end

    local index = self:getIndexFromProductId(product_id)

    return (index ~= nil)
end

-------------------------------------
-- function getRecentPid
-------------------------------------
function ServerData_AdventureBreakthroughPackage:getRecentPid()
    local index = table.getn(self.m_productIdList)

    return self.m_productIdList[index]
end

-------------------------------------
-- function checkPackage
-------------------------------------
function ServerData_AdventureBreakthroughPackage:isRecentPackage(product_id)
    if (type(product_id) ~= 'number') then
        product_id = tonumber(product_id) 
    end

    local index = self:getIndexFromProductId(product_id)

    return (table.getn(self.m_productIdList) == index)
end

-------------------------------------
-- function getRewardListFromProductId
-------------------------------------
function ServerData_AdventureBreakthroughPackage:getRewardListFromProductId(product_id)
    -- 모험돌파 n번 상품 (01, 02, ...) - csv 파일
    local index = table.find(self.m_productIdList, product_id)

    local table_name = string.format(self.m_tableKeyword, index)
    
    -- 모험돌파 n번 상품의 보상 정보 - csv 파일
    local reward_list = TABLE:get(table_name)

    local result = {}

    for key, reward in pairs(reward_list) do
        table.insert(result, reward)
    end

    table.sort(result, function(a, b)
        return a['stage'] < b['stage']
    end)

    return result
end




-------------------------------------
-- function request_adventureClearInfo
-------------------------------------
function ServerData_AdventureBreakthroughPackage:request_info(product_id, success_cb, fail_cb)
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function response_callback(ret)

        table.sort(ret['received_list'], function(a, b)
            return a < b
        end)
        
        local temp = {
            ['active'] =ret['active'],
            ['received_list'] = ret['received_list']
        }

        self:response_info(product_id, temp)



        if (success_cb) then 
            success_cb(ret) 
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/stagepack_info')
    ui_network:setParam('product_id', product_id)
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(response_callback)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function response_adventureClearInfo
-------------------------------------
function ServerData_AdventureBreakthroughPackage:response_info(product_id, ret)
    if (type(product_id) ~= 'number') then
        product_id = tonumber(product_id) 
    end
    -- "110282":{
    --     "active":false,
    --     "received_list":[]
    -- }

    self.m_dataList[product_id] = ret or {}
end

-------------------------------------
-- function request_adventureClearReward
-------------------------------------
function ServerData_AdventureBreakthroughPackage:request_reward(product_id, stage_id, success_cb, fail_cb)
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function response_callback(ret)

        table.sort(ret['received_list'], function(a, b)
            return a < b
        end)

        local temp = {
            ['active'] = self:isActive(product_id),
            ['received_list'] = ret['received_list']
        }

        self:response_info(product_id, temp)

        if (success_cb) then 
            success_cb(ret) 
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/stagepack_reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('product_id', product_id)
    ui_network:setParam('stage', stage_id)
    ui_network:setSuccessCB(response_callback)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end


-------------------------------------
-- function isActive
-- @breif 구매 여부
-------------------------------------
function ServerData_AdventureBreakthroughPackage:isActive(product_id)
    if (type(product_id) ~= 'number') then
        product_id = tonumber(product_id) 
    end
    
    local data = self.m_dataList[product_id]

    if (data == nil) then return false end

    return data['active'] or false
end


-------------------------------------
-- function isReceivedReward
-- @breif 보상 수령 여부
-------------------------------------
function ServerData_AdventureBreakthroughPackage:isReceivableReward(product_id, target_stage_id) -- isReceived
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
            if (star >= 3) or (self:isRecentPackage(product_id) == false) then
                return true
            end
        end
    end

    return false
end


-------------------------------------
-- function isReceivedReward
-- @breif 보상 수령 여부
-------------------------------------
function ServerData_AdventureBreakthroughPackage:isReceivedReward(product_id, target_stage_id) -- isReceived
    if (type(product_id) ~= 'number') then
        product_id = tonumber(product_id)
    end

    local data = self.m_dataList[product_id]
    
    if (data == nil) then return false end

    local received_reward_list = data['received_list']

    if (received_reward_list == nil) then return false end

    for index, stage_id in ipairs(received_reward_list) do
        if (stage_id == target_stage_id) then
            return true
        end
    end

    return false
end


-------------------------------------
-- function isLeftRewardExist
-- @breif 남은 보상이 있는지 여부
-------------------------------------
function ServerData_AdventureBreakthroughPackage:isLeftRewardExist(product_id)
    if (type(product_id) ~= 'number') then
        product_id = tonumber(product_id)
    end
    
    -- 모험돌파 n번 상품의 보상 정보 - csv 파일
    local reward_list = self:getRewardListFromProductId(product_id)

    -- 보상 개수
    local reward_number = table.getn(reward_list)

    -- 유저 정보
    local data = self.m_dataList[product_id]
    
    if (data == nil) then return true end

    -- 유저가 수령한 보상 리스트
    local received_reward_list = data['received_list']

    if (received_reward_list == nil) then return true end

    -- 수령한 보상 개수
    local received_number = table.getn(received_reward_list)


    return (received_number ~= reward_number)
end

-------------------------------------
-- function isReceivableRewardExist
-- @breif 받을 수 있는 보상이 있는지 여부
-------------------------------------
function ServerData_AdventureBreakthroughPackage:isReceivableRewardExist(product_id)
    if (type(product_id) ~= 'number') then
        product_id = tonumber(product_id) 
    end
    local index = table.find(self.m_productIdList, product_id)
    
    local reward_list = TABLE:get(string.format(self.m_tableKeyword, index))

    for index, reward in ipairs(reward_list) do
        local stage_id = reward['stage']

        -- 받지 않은 보상이 있으면
        if (self:isReceivedReward(product_id, stage_id) == false) then
            local stage_info = g_adventureData:getStageInfo(stage_id)
            local star = stage_info:getNumberOfStars()

            -- 보상 조건인 별 3개인 경우 혹은 판매 종료 된 패키지인 경우
            if (star >= 3) or (self:isRecentPackage(product_id) == false) then
                return true
            end
        end
    end

    return false
end


-------------------------------------
-- function isButtonVisible
-------------------------------------
function ServerData_AdventureBreakthroughPackage:isButtonVisible(product_id)
    local is_visible = false

    if (product_id ~= nil) then
        if (self:checkPackage(product_id) == true) then
            if (self:isActive(product_id) == false) and (self:isRecentPackage(product_id) == false) then

            elseif(self:isLeftRewardExist(product_id) == false) then

            else
                is_visible = is_visible or true
            end
        end
    else
        for index, product_id in ipairs(self.m_productIdList) do
            if (self:isActive(product_id) == false) and (self:isRecentPackage(product_id) == false) then

            elseif(self:isLeftRewardExist(product_id) == false) then

            else
                is_visible = is_visible or true
                break
            end
        end
    end

    return is_visible
end

-------------------------------------
-- function isNotiVisible
-------------------------------------
function ServerData_AdventureBreakthroughPackage:isNotiVisible(product_id)
    local is_visible = false

    if (product_id ~= nil) then
        if (self:checkPackage(product_id) == true) and (self:isActive(product_id) == true) and (self:isActive(product_id) == true) and  (self:isReceivableRewardExist(product_id) == true) then
            is_visible = true
        end
    else
        for index, product_id in ipairs(self.m_productIdList) do
            if (self:isActive(product_id) == true) and (self:isReceivableRewardExist(product_id) == true) then
                is_visible = is_visible or true
                break
            end
        end
    end

    return is_visible
end
