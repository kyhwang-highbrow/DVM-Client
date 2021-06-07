-- 관련 테이블
-- table_package_levelup
-- table_shop_lsit
-- table_shop_cash

LEVELUP_PACKAGE_PRODUCT_ID = 90037
LEVELUP_PACKAGE_2_PRODUCT_ID = 110271
-- 2020.08.24 신규 추가
LEVELUP_PACKAGE_3_PRODUCT_ID = 110272

-------------------------------------
-- class ServerData_LevelUpPackage
-- @breif 레벨업 패키지 관리
-- @instance g_levelUpPackageData
-------------------------------------
ServerData_LevelUpPackage = class({
        m_serverData = 'ServerData',
        
        m_tPackage = 'map - StructPackageState',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_LevelUpPackage:init(server_data)
    self.m_serverData = server_data
    self.m_tPackage = {}
end

-------------------------------------
-- function getProductState
-------------------------------------
function ServerData_LevelUpPackage:getProductState(_product_id)
    local product_id = tostring(_product_id)
    return self.m_tPackage[product_id]
end

-------------------------------------
-- function setDirty
-------------------------------------
function ServerData_LevelUpPackage:setDirty(product_id, dirty)
    local struct_product_state = self:getProductState(product_id)
    if (not struct_product_state) then
        return
    end

    struct_product_state:setDirty(dirty)
end

-------------------------------------
-- function isDirty
-------------------------------------
function ServerData_LevelUpPackage:isDirty(product_id)
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
function ServerData_LevelUpPackage:getBuyLevelUpPackageDirty()
    if (self:isDirty(LEVELUP_PACKAGE_PRODUCT_ID)) then
        return true
    end
    
    if (self:isDirty(LEVELUP_PACKAGE_2_PRODUCT_ID)) then
        return true
    end

    if (self:isDirty(LEVELUP_PACKAGE_3_PRODUCT_ID)) then
        return true
    end

    return false
end

-------------------------------------
-- function resetBuyLevelUpPackageDirty
-- @brief 더티 처리 리셋
-------------------------------------
function ServerData_LevelUpPackage:resetBuyLevelUpPackageDirty()
    self:setDirty(LEVELUP_PACKAGE_PRODUCT_ID, false)
    self:setDirty(LEVELUP_PACKAGE_2_PRODUCT_ID, false)
    self:setDirty(LEVELUP_PACKAGE_3_PRODUCT_ID, false)
end


-------------------------------------
-- function isBattlePassProduct
-------------------------------------
function ServerData_LevelUpPackage:isBattlePassProduct(product_id)
    local pid = tonumber(product_id)
    
    return pid == LEVELUP_PACKAGE_PRODUCT_ID 
            or pid == LEVELUP_PACKAGE_2_PRODUCT_ID
            or pid == LEVELUP_PACKAGE_3_PRODUCT_ID
end

-------------------------------------
-- function request_lvuppackInfo
-------------------------------------
function ServerData_LevelUpPackage:request_lvuppackInfo(cb_func, fail_cb, product_id)
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
function ServerData_LevelUpPackage:response_lvuppackInfoByTitle(ret)
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

-- function ServerData_LevelUpPackage:isPurchasedAnyProduct()
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
function ServerData_LevelUpPackage:isActive(product_id)
    local struct_product_state = self:getProductState(product_id)
    if (not struct_product_state) then
        return
    end
    return struct_product_state:isActive()
end

-------------------------------------
-- function 
-------------------------------------
function ServerData_LevelUpPackage:isUnclearedAnyPackage()
    local package_list = {LEVELUP_PACKAGE_PRODUCT_ID, LEVELUP_PACKAGE_2_PRODUCT_ID, LEVELUP_PACKAGE_3_PRODUCT_ID}

    local result = false

    for _, pid in pairs(package_list) do
        if isVisibleAtBattlePassShop(pid) then
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
function ServerData_LevelUpPackage:isVisibleAtBattlePassShop(product_id)
    if (not self:isActive(product_id)) then 
        return true 
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

function ServerData_LevelUpPackage:isVisibleNotiAtLobby(product_id)
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
function ServerData_LevelUpPackage:isVisible_lvUpPack(product_id)
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
function ServerData_LevelUpPackage:isVisibleAtPackageShop(product_id)
    local is_active = g_levelUpPackageData:isActive(product_id)
    local is_visible = g_levelUpPackageData:isVisible_lvUpPack(product_id)
    if (is_active and (is_visible == false)) then
        return false
    else
        return true
    end    
end

-------------------------------------
-- function isVisible_levelUpPackNoti
-------------------------------------
function ServerData_LevelUpPackage:isVisible_levelUpPackNoti(product_id)
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
function ServerData_LevelUpPackage:request_lvuppackReward(lv, cb_func, fail_cb, product_id)
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
function ServerData_LevelUpPackage:isReceived(product_id, lv)
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
function ServerData_LevelUpPackage:getFocusRewardLevel(product_id)
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
function ServerData_LevelUpPackage:getLevelUpPackageTable(product_id)
    local table_package_levelup
    if (product_id == LEVELUP_PACKAGE_PRODUCT_ID) then
        table_package_levelup = TABLE:get('table_package_levelup')
    elseif (product_id == LEVELUP_PACKAGE_2_PRODUCT_ID) then
        table_package_levelup = TABLE:get('table_package_levelup_02')
    elseif (product_id == LEVELUP_PACKAGE_3_PRODUCT_ID) then
        table_package_levelup = TABLE:get('table_package_levelup_03')
    end
    return table_package_levelup
end
