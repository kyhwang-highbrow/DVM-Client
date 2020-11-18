-- 관련 테이블
-- table_package_attr_tower
-- table_package_attr_tower_reward
-------------------------------------
-- class ServerData_AttrTowerPackage
-- @breif 시험의 탑 정복 선물 패키지 관리
-------------------------------------
ServerData_AttrTowerPackage = class({
        m_serverData = 'ServerData',
        
        m_tProductInfo = 'table', 
    })



-------------------------------------
-- function init
-------------------------------------
function ServerData_AttrTowerPackage:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function request_attrTowerPackInfo
-------------------------------------
function ServerData_AttrTowerPackage:request_attrTowerPackInfo(cb_func, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        self:response_attrTowerPackInfo(ret)

        if (cb_func) then 
            cb_func(ret) 
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/attr_tower_pack/info')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function response_attrTowerPackInfo
-------------------------------------
function ServerData_AttrTowerPackage:response_attrTowerPackInfo(ret)
    self.m_tProductInfo = ret['attr_tower_pack_info']
end

-------------------------------------
-- function isActive
-------------------------------------
function ServerData_AttrTowerPackage:isActive(product_id_list) 
    local is_active = false

    if product_id == nil then

    elseif (table.count(product_id) == 1) then
        is_active = (self.m_tProductInfo[product_id] >= 0)
    
    else
        for i, v in ipairs(product_id_list) do
            if (self.m_tProductInfo[v] >= 0) then
                is_active = true
                break
            end
        end 
    end
 
    return is_active
end

-------------------------------------
-- function isVisible_attrTowerPackNoti
-- @brief 보상받을 수 있는 항목 있을 때에만 노티
-------------------------------------
function ServerData_AttrTowerPackage:isVisible_attrTowerPackNoti(product_id_list)
    if (not self:isActive(product_id_list)) then 
        return false 
    end

    local product_info_table = TABLE:get('table_package_attr_tower')
    local reward_info_table = TABLE:get('table_package_attr_tower_reward')
    
    local reward_floor_list = {} -- 보상을 받을 수 있는 층
    for k, _ in pairs(reward_info_table) do
        table.insert(reward_floor_list, k)
    end

    for _, product_id in ipairs(product_id_list) do
        if (self:isActive(product_id)) then
            -- continue
        else

            local product_info = product_info_table[product_id]
            local start_floor = product_info['start_floor']
            local end_floor = product_info['end_floor']
        
            -- 보상 안 받은 항목들 중에서
            for i, reward_floor in pairs(reward_floor_list) do
                if ((start_floor <= reward_floor) and (reward_floor <= end_floor)) then -- 해당 상품의 층 범위 안에서
                
                    --if (유저가 최대로 깬 층 >= floor) and (유저가 보상을 마지막으로 수령한 층 < floor) then
                    if (true) then
                        return true
                    end
                end
            end
        end
    end

    return false
end

-------------------------------------
-- function request_attrTowerPackReward
-------------------------------------
function ServerData_AttrTowerPackage:request_attrTowerPackReward(product_id, floor, cb_func, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        if (cb_func) then 
            cb_func(ret) 
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/attr_tower_pack/reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('product_id', product_id)
    ui_network:setParam('floor', floor)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_attrTowerPackReward
-------------------------------------
function ServerData_AttrTowerPackage:request_attrTowerPackRewardAll(product_id, cb_func, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        if (cb_func) then 
            cb_func(ret) 
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/attr_tower_pack/reward_all')
    ui_network:setParam('uid', uid)
    ui_network:setParam('product_id', product_id)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function getFocusRewardStage
-- @brief 보상 받기 가능한 idx로 이동
-------------------------------------
function ServerData_AttrTowerPackage:getFocusRewardFloor(product_id)
    local product_info_table = TABLE:get('table_package_attr_tower')
    local reward_info_table = TABLE:get('table_package_attr_tower_reward')

    for k, v in pairs(reward_info_table) do
        reward_info_table['floor'] = k
    end

    local reward_info_list = table.MapToList(reward_info_table)

    local function sort_func(a, b) -- 내림차순으로 정렬
        return a['floor'] > b['floor'] 
    end

    table.sort(reward_info_list, sort_func)

    local product_info = product_info_table[product_id]
    local start_floor = product_info['start_floor']
    local end_floor = product_info['end_floor']

    local package_floor_length = 0
    local result_index = 0
    local result_floor = 0

    for i, v in ipairs(reward_info_list) do
        local floor = v['stage']
        
        if (floor < start_floor) then
            break
        end
        
        if (floor <= end_floor) then
            package_floor_length = package_floor_length + 1
        end

        --if (유저가 최대로 깬 층 >= floor) and (유저가 보상을 마지막으로 수령한 층 < floor) then
        if (true) and (true) then
            result_floor = floor

        end
    end

    return result_floor, result_index
end

-------------------------------------
-- function getHuddleFloor
-- @brief 가장 첫번째 패키지의 end_floor
-------------------------------------
function ServerData_AttrTowerPackage:getHuddleFloor(attr)
    local product_id_list = self:getProductIdList(attr)
    local product_info_table = TABLE:get('table_package_attr_tower')

    local first_product_id = product_id_list[1]
    local product_info = product_info_table[first_product_id]

    local huddle_floor = nil

    if (product_info) then
        huddle_floor = product_info['end_floor']
    end

    return huddle_floor
end

-------------------------------------
-- function getProductIdList
-------------------------------------
function ServerData_AttrTowerPackage:getProductIdList(attr)
    local product_id_list = {}
    local product_info_table = TABLE:get('table_package_attr_tower')
    local attr_num = attributeStrToNum(attr)
    for idx = 1, 10 do -- 10은 임의의 큰 수
        local product_id = 121200 + (attr_num * 10) + idx 
        if (product_info_table[product_id] == nil) then
            break
        end
        table.insert(product_id_list, product_id)
    end

    return product_id_list    
end

-------------------------------------
-- function getProductInfo
-------------------------------------
function ServerData_AttrTowerPackage:getProductInfo(product_id)
    local product_info

    local product_info_table = TABLE:get('table_package_attr_tower')
    local reward_info_table = TABLE:get('table_package_attr_tower_reward')


    product_info = product_info_table[product_id]
    product_info['product_id'] = product_id

    local reward_info = {}
    local attr = product_info['attr']
    local start_floor = product_info['start_floor']
    local end_floor = product_info['end_floor']

    for floor, v in pairs(reward_info_table) do
        if ((start_floor <= floor) and (floor <= end_floor)) then
            reward_info[floor] = v[attr]
        end
    end

    product_info['reward_info'] = reward_info

    return product_info
end