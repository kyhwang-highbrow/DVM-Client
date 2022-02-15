-- 관련 테이블
-- table_package_levelup
-- table_shop_lsit
-- table_shop_cash

LEVELUP_PACKAGE_PRODUCT_ID = 90037
LEVELUP_PACKAGE_2_PRODUCT_ID = 110271
-- 2020.08.24 신규 추가
LEVELUP_PACKAGE_3_PRODUCT_ID = 110272
LEVELUP_PACKAGE_4_PRODUCT_ID = 110273

-------------------------------------
-- class ServerData_LevelUpPackageOld
-- @breif 레벨업 패키지 관리
-- @instance g_levelUpPackageData
-------------------------------------
ServerData_LevelUpPackageOld = class({
        m_serverData = 'ServerData',
        
        m_tPackage = 'map - StructPackageState',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_LevelUpPackageOld:init(server_data)
    self.m_serverData = server_data
    self.m_tPackage = {}
end

-------------------------------------
-- function getProductState
-------------------------------------
function ServerData_LevelUpPackageOld:getProductState(_product_id)
    local product_id = tostring(_product_id)
    return self.m_tPackage[product_id]
end

-------------------------------------
-- function setDirty
-------------------------------------
function ServerData_LevelUpPackageOld:setDirty(product_id, dirty)
    local struct_product_state = self:getProductState(product_id)
    if (not struct_product_state) then
        return
    end

    struct_product_state:setDirty(dirty)
end

-------------------------------------
-- function isDirty
-------------------------------------
function ServerData_LevelUpPackageOld:isDirty(product_id)
    local struct_product_state = self:getProductState(product_id)
    if (not struct_product_state) then
        return
    end
    return struct_product_state:getDirty()
end

-------------------------------------
-- function getBuyLevelUpPackageDirty
-- @brief 구매했을 경우, 모두 받았을 경우 더티 처리 한번 해준다 (로비에서 더티 = true 일경우 바로 레벨업 패키지 아이콘 보여줌)
-------------------------------------
function ServerData_LevelUpPackageOld:getBuyLevelUpPackageDirty()
    if (self:isDirty(LEVELUP_PACKAGE_PRODUCT_ID)) then
        return true
    end
    
    if (self:isDirty(LEVELUP_PACKAGE_2_PRODUCT_ID)) then
        return true
    end

    if (self:isDirty(LEVELUP_PACKAGE_3_PRODUCT_ID)) then
        return true
    end

    
    if (self:isDirty(LEVELUP_PACKAGE_4_PRODUCT_ID)) then
        return true
    end

    return false
end

-------------------------------------
-- function resetBuyLevelUpPackageDirty
-- @brief 더티 처리 리셋
-------------------------------------
function ServerData_LevelUpPackageOld:resetBuyLevelUpPackageDirty()
    self:setDirty(LEVELUP_PACKAGE_PRODUCT_ID, false)
    self:setDirty(LEVELUP_PACKAGE_2_PRODUCT_ID, false)
    self:setDirty(LEVELUP_PACKAGE_3_PRODUCT_ID, false)
    self:setDirty(LEVELUP_PACKAGE_4_PRODUCT_ID, false)
end


-------------------------------------
-- function isBattlePassProduct
-------------------------------------
function ServerData_LevelUpPackageOld:isBattlePassProduct(product_id)
    local pid = tonumber(product_id)
    
    return pid == LEVELUP_PACKAGE_PRODUCT_ID 
            or pid == LEVELUP_PACKAGE_2_PRODUCT_ID
            or pid == LEVELUP_PACKAGE_3_PRODUCT_ID
            or pid == LEVELUP_PACKAGE_4_PRODUCT_ID
end

-------------------------------------
-- function request_lvuppackInfo
-------------------------------------
function ServerData_LevelUpPackageOld:request_lvuppackInfo(cb_func, fail_cb, product_id)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        local _product_id = tostring(product_id)
        self.m_tPackage[_product_id] = StructPackageState(ret)
        if (cb_func) then
			cb_func(ret)
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/lvuppack_info')
    ui_network:setParam('uid', uid)
    -- 기존 레벨업 패키지 product_id : 90037, 
    -- 20191210 업데이트 이후 추가된 레벨업 패키지2 product_id : 110271
    ui_network:setParam('product_id', product_id) 
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function response_lvuppackInfoByTitle
-- @brief 타이틀에서도 정보 받고 있음
-------------------------------------
function ServerData_LevelUpPackageOld:response_lvuppackInfoByTitle(ret)
    --[[
        "lvuppack_info" = 
        {
            [1011010] = 
            {
                ['active'] = true
                ['received_list'] = {1,2,3,4,5}
            },
        }
    --]]
    for product_id, data in pairs(ret) do
        if (type(data) == 'table') then
            local _product_id = tostring(product_id)
            self.m_tPackage[_product_id] = StructPackageState(data)
        end
    end
end

-- function ServerData_LevelUpPackageOld:isPurchasedAnyProduct()
--     local isPurchased = false
--     for _, struct_product in pairs(self.m_tPackage) do
--         if (struct_product:isActive()) then
--             isPurchased = true
--             break
--         end
--     end

--     return isPurchased
-- end

-------------------------------------
-- function isActive
-------------------------------------
function ServerData_LevelUpPackageOld:isActive(product_id)
    local struct_product_state = self:getProductState(product_id)
    if (not struct_product_state) then
        return
    end
    return struct_product_state:isActive()
end

-------------------------------------
-- function isUnclearedAnyPackage
-------------------------------------
function ServerData_LevelUpPackageOld:isUnclearedAnyPackage()
    local package_list = {LEVELUP_PACKAGE_PRODUCT_ID, LEVELUP_PACKAGE_2_PRODUCT_ID, LEVELUP_PACKAGE_3_PRODUCT_ID, LEVELUP_PACKAGE_4_PRODUCT_ID}

    local result = false

    for _, pid in pairs(package_list) do
        if self:isVisibleAtBattlePassShop(pid) then
            result = true
            break
        end
    end

    return result
end

-------------------------------------
-- function isVisibleAtBattlePassShop
-- @breif 구매 전에는 출력하고 구매 후에는 보상이 남은 경우 출력
-------------------------------------
function ServerData_LevelUpPackageOld:isVisibleAtBattlePassShop(product_id)

    if (not self:isActive(product_id)) then 
        if (product_id == LEVELUP_PACKAGE_PRODUCT_ID) or (product_id == LEVELUP_PACKAGE_2_PRODUCT_ID) then
            return false
        else
            return true 
        end
    end


    local table_package = self:getLevelUpPackageTable(product_id)
    for i, v in pairs(table_package) do
        local lv = v['level']
        
        if (self:isReceived(product_id, lv) == false) then 
            return true 
        end
    end

    return false
end

function ServerData_LevelUpPackageOld:isVisibleNotiAtLobby(product_id)
    if(not self:isActive(product_id)) then
        return false
    end

    local table_package = self:getLevelUpPackageTable(product_id)
    local user_level = g_userData:get('lv')

    for i, v in pairs(table_package) do
        local lv = v['level']

        if(lv <= user_level) and (self:isReceived(product_id, lv) == false) then
            return true
        end
    end

    return false
end

-------------------------------------
-- function isVisible_lvUpPack
-------------------------------------
function ServerData_LevelUpPackageOld:isVisible_lvUpPack(product_id)
    if (not self:isActive(product_id)) then
        return false
    end
    
    local table_package_levelup = self:getLevelUpPackageTable(product_id)
    for i,v in pairs(table_package_levelup) do
        local lv = v['level']
        if (self:isReceived(product_id, lv) == false) then
            return true
        end
    end

    return false
end

-------------------------------------
-- function isVisibleAtPackageShop
-- @brief 패키지 상점에서는 구매를 한 후에도 노출됨, 상품을 다 받으면 노출 안됨
-------------------------------------
function ServerData_LevelUpPackageOld:isVisibleAtPackageShop(product_id)
    local is_active = g_levelUpPackageDataOld:isActive(product_id)
    local is_visible = g_levelUpPackageDataOld:isVisible_lvUpPack(product_id)
    if (is_active and (is_visible == false)) then
        return false
    else
        return true
    end    
end

-------------------------------------
-- function isVisible_levelUpPackNoti
-------------------------------------
function ServerData_LevelUpPackageOld:isVisible_levelUpPackNoti(product_id)
    local table_package_levelup = self:getLevelUpPackageTable(product_id)
    local list = table.MapToList(table_package_levelup)

    local function sort_func(a, b)
        return a['level'] < b['level']
    end
    table.sort(list, sort_func)
    
    local user_level = g_userData:get('lv')

    for i,v in ipairs(list) do
        local lv = v['level']
        if (lv <= user_level) and (not self:isReceived(product_id, lv)) then
            return true
        end
    end

    return false    
end

-------------------------------------
-- function request_lvuppackReward
-------------------------------------
function ServerData_LevelUpPackageOld:request_lvuppackReward(lv, cb_func, fail_cb, product_id)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        if (ret['received_list']) then
            local struct_package_state = self:getProductState(product_id)
            if (struct_package_state) then
                struct_package_state:setReceievedList(ret['received_list'])
            end
        end

		if (cb_func) then
			cb_func(ret)
		end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/lvuppack_reward')
    ui_network:setParam('uid', uid)
    -- 기존 레벨업 패키지 product_id : 90037, 
    -- 20191210 업데이트 이후 추가된 레벨업 패키지2 product_id : 110271
    ui_network:setParam('product_id', product_id) 
    ui_network:setParam('lv', lv)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function isReceived
-------------------------------------
function ServerData_LevelUpPackageOld:isReceived(product_id, lv)
    local struct_product_state = self:getProductState(product_id)
    if (not struct_product_state) then
        return
    end
    return struct_product_state:isReceived(lv)
end


-------------------------------------
-- function getFocusRewardLevel
-- @brief 보상 수령이 가능한 레벨 리턴
-------------------------------------
function ServerData_LevelUpPackageOld:getFocusRewardLevel(product_id)
    local table_package_levelup = self:getLevelUpPackageTable(product_id)
    local list = table.MapToList(table_package_levelup)

    local function sort_func(a, b)
        return a['level'] < b['level']
    end
    table.sort(list, sort_func)
    
    local user_level = g_userData:get('lv')

    for i,v in ipairs(list) do
        local lv = v['level']
        if (lv <= user_level) and (not self:isReceived(lv)) then
            return lv, i
        end
    end

    return nil
end

-------------------------------------
-- function getLevelUpPackageTable
-------------------------------------
function ServerData_LevelUpPackageOld:getLevelUpPackageTable(product_id)
    local table_package_levelup
    if (product_id == LEVELUP_PACKAGE_PRODUCT_ID) then
        table_package_levelup = TABLE:get('table_package_levelup_01')
    elseif (product_id == LEVELUP_PACKAGE_2_PRODUCT_ID) then
        table_package_levelup = TABLE:get('table_package_levelup_02')
    elseif (product_id == LEVELUP_PACKAGE_3_PRODUCT_ID) then
        table_package_levelup = TABLE:get('table_package_levelup_03')
    elseif (product_id == LEVELUP_PACKAGE_4_PRODUCT_ID) then
        table_package_levelup = TABLE:get('table_package_levelup_04')
    end
    return table_package_levelup
end















-------------------------------------
-- class ServerData_LevelUpPackage
-------------------------------------
ServerData_LevelUpPackage = class({
    m_serverData = 'ServerData',
    m_productIdList = 'List[number]',
    m_dataList = 'List[table]',
    
    m_tableKeyword = 'string',
})

-------------------------------------
-- function init
-------------------------------------
function ServerData_LevelUpPackage:init(server_data)
    self.m_serverData = server_data
    self.m_productIdList = {90037, 110271, 110272, 110273} -- 레벨업 패키지
    self.m_tableKeyword = 'table_package_levelup_%02d'
    self.m_dataList = {}
end

-------------------------------------
-- function getIndexFromProductId
-------------------------------------
function ServerData_LevelUpPackage:getIndexFromProductId(product_id)
     if (type(product_id) ~= 'number') then
        product_id = tonumber(product_id) 
    end

    local index = table.find(self.m_productIdList, product_id)

    return index
end

-------------------------------------
-- function checkPackage
-------------------------------------
function ServerData_LevelUpPackage:checkPackage(product_id)
     if (type(product_id) ~= 'number') then
        product_id = tonumber(product_id) 
    end

    local index = table.find(self.m_productIdList, product_id)

    return (index ~= nil)
end


-------------------------------------
-- function getRecentPid
-------------------------------------
function ServerData_LevelUpPackage:getRecentPid()
    local index = table.getn(self.m_productIdList)

    return self.m_productIdList[index]
end

-------------------------------------
-- function checkPackage
-------------------------------------
function ServerData_LevelUpPackage:isRecentPackage(product_id)
     if (type(product_id) ~= 'number') then
        product_id = tonumber(product_id) 
    end

    local index = self:getIndexFromProductId(product_id)

    return (table.getn(self.m_productIdList) == index)
end

-------------------------------------
-- function getRewardListFromProductId
-------------------------------------
function ServerData_LevelUpPackage:getRewardListFromProductId(product_id)
    -- 레벨업 패키지 n번 상품 (01, 02, ...) - csv 파일
    local index = table.find(self.m_productIdList, product_id)

    local table_name = string.format(self.m_tableKeyword, index)
    
    -- 레벨업 패키지 n번 상품의 보상 정보 - csv 파일
    local reward_list = TABLE:get(table_name)

    local result = {}

    for key, reward in pairs(reward_list) do
        table.insert(result, reward)
    end

    table.sort(result, function(a, b)
        return a['level'] < b['level']
    end)

    return result
end

-------------------------------------
-- function request_lvuppackInfo
-------------------------------------
function ServerData_LevelUpPackage:request_info(product_id, success_cb, fail_cb)
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function response_callback(ret)
        
        table.sort(ret['received_list'], function(a, b)
            return a < b
        end)
        
        local temp = {
            ['active'] = ret['active'],
            ['received_list'] = ret['received_list']
        }

        self:response_info(product_id, temp)

        if (success_cb) then 
            success_cb(ret) 
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/lvuppack_info')
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
-- function response_lvuppackInfoByTitle
-------------------------------------
function ServerData_LevelUpPackage:response_info(product_id, ret)
    --[[
        "lvuppack_info" = 
        {
            [1011010] = 
            {
                ['active'] = true
                ['received_list'] = {5,10,15,20,25}
            },
        }
    --]]

     if (type(product_id) ~= 'number') then
        product_id = tonumber(product_id) 
    end
    -- "110282":{
    --     "active":false,
    --     "received_list":[]
    -- }

    table.sort(ret, function(a, b) 
        return a < b
    end)

    self.m_dataList[product_id] = ret or {}
end

-------------------------------------
-- function request_lvuppackInfo
-------------------------------------
function ServerData_LevelUpPackage:request_reward(product_id, level, success_cb, fail_cb)
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
    ui_network:setUrl('/shop/lvuppack_reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('product_id', product_id)
    ui_network:setParam('lv', level)
    ui_network:setSuccessCB(response_callback)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function isActive
-------------------------------------
function ServerData_LevelUpPackage:isActive(product_id)
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
function ServerData_LevelUpPackage:isReceivableReward(product_id, target_level) -- isReceived
     if (type(product_id) ~= 'number') then
        product_id = tonumber(product_id)
    end
 
    -- 레벨업 패키지 n번 상품의 보상 정보 - csv 파일
    local reward_list = self:getRewardListFromProductId(product_id)

    for index, reward in pairs(reward_list) do
        local level = reward['level']

        if (level ~= 'number') then
            level = tonumber(level)
            target_level = tonumber(target_level)
        end

        if (level == target_level) and (self:isReceivedReward(product_id, target_level) == false) then
            local user_level = g_userData:get('lv')

            -- 레벨 달성 혹은 판매 종료된 패키지인 경우
            if (user_level >= target_level) or (self:isRecentPackage(product_id) == false) then
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
function ServerData_LevelUpPackage:isReceivedReward(product_id, target_level) -- isReceived
     if (type(product_id) ~= 'number') then
        product_id = tonumber(product_id)
    end

    local data = self.m_dataList[product_id]
    
    if (data == nil) then return false end

    local received_reward_list = data['received_list']

    if (received_reward_list == nil) then return false end

    for index, level in ipairs(received_reward_list) do
        if (level == target_level) then
            return true
        end

    end

    return false

    -- local index = table.find(received_reward_list, target_level)

    -- return (index ~= nil)
end


-------------------------------------
-- function isLeftRewardExist
-- @breif 남은 보상이 있는지 여부
-------------------------------------
function ServerData_LevelUpPackage:isLeftRewardExist(product_id)
     if (type(product_id) ~= 'number') then
        product_id = tonumber(product_id)
    end

    -- 레벨업 패키지 n번 상품의 보상 정보 - csv 파일
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
function ServerData_LevelUpPackage:isReceivableRewardExist(product_id)
     if (type(product_id) ~= 'number') then
        product_id = tonumber(product_id) 
    end

    local index = table.find(self.m_productIdList, product_id)
    
    local reward_list = TABLE:get(string.format(self.m_tableKeyword, index))

    for index, reward in ipairs(reward_list) do
        local level = reward['level']

        -- 받지 않은 보상이 있으면
        if (self:isReceivedReward(product_id, level) == false) then
            local user_level = g_userData:get('lv')

            -- 보상 레벨보다 테이머 레벨이 높은 경우 혹은 판매 종료된 패키지인 경우
            if (user_level >= level)  or (self:isRecentPackage(product_id) == false) then
                return true
            end
        end
    end

    return false
end

-------------------------------------
-- function isButtonVisible
-------------------------------------
function ServerData_LevelUpPackage:isButtonVisible(product_id)
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
function ServerData_LevelUpPackage:isNotiVisible(product_id)
    local is_visible = false

    if (product_id ~= nil) then
        if (self:checkPackage(product_id) == true) and (self:isActive(product_id) == true) and (self:isReceivableRewardExist(product_id) == true) then
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
