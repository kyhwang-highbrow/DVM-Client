PackageManager = {}

-------------------------------------
-- function getTargetUI
-- @brief 해당 패키지 상품 UI
-- @param package_name : table_bundle_package에 등록된 패키지 네임
-- @param is_popup : true - 팝업, false - 이벤트 탭에 등록 (종료 버튼 없음)
-------------------------------------
function PackageManager:getTargetUI(package_name, is_popup)
    local target_ui = nil

    -- 레벨업 패키지 UI
    if (package_name == 'package_levelup') then
        local _struct_product = g_shopDataNew:getLevelUpPackageProduct()
        target_ui = UI_Package_LevelUp(_struct_product, is_popup)

    -- 모험돌파 패키지 UI
    elseif (package_name == 'package_adventure_clear') then
        local _struct_product = g_shopDataNew:getAdventureClearProduct()
        target_ui = UI_Package_AdventureClear(_struct_product, is_popup)

    -- 패키지 상품 묶음 UI 
    -- ### 단일 상품도 table_bundle_package에 등록
    elseif (TablePackageBundle:checkBundleWithName(package_name)) then
        target_ui = UI_Package_Bundle(package_name, is_popup)

    else
        if (type(package_name) == 'string') then
            error('등록 되지 않은 package name : '.. package_name)
            
        -- struct_product 로 들어온 경우 패키지 네임으로 변환하여 타겟 UI 찾음
        else
            local struct_product = package_name
            local pid = struct_product['product_id']
            local _package_name = TablePackageBundle:getPackageNameWithPid(pid)   
            target_ui = UI_Package_Bundle(_package_name, is_popup)
        end
    end

    return target_ui
end

-------------------------------------
-- function goToTargetUI
-- @brief 해당 패키지 상품 UI
-------------------------------------
function PackageManager:goToTargetUI(product_id)
    local l_item_list = g_shopDataNew:getProductList('package')
    local struct_product

    -- 묶음 UI 별도 처리
    if (string.find(product_id, 'package_') and PackageManager:isExist(product_id)) then
        struct_product = {product_id = product_id}
            
    else
        struct_product = l_item_list[tonumber(product_id)]
    end

    if (struct_product) then
        local is_popup = true
        local ui = PackageManager:getTargetUI(struct_product, is_popup)
    end
end

-------------------------------------
-- function isExist
-- @brief 묶음 UI에서 상품정보가 하나라도 있는지 (모두 구매해서 없거나, 기간이 자니서 없거나 하는 경우)
-------------------------------------
function PackageManager:isExist(package_name)
    -- 레벨업 패키지는 구매를 한 후에도 노출되도록 설정(추후 리팩토링 필요) sgkim 2017-10-25
    if (package_name == 'package_levelup') then
        local is_active = g_levelUpPackageData:isActive()
        local is_visible = g_levelUpPackageData:isVisible_lvUpPack()
        if (is_active and (is_visible == false)) then
            return false
        else
            return true
        end
    end

    -- 모험돌파 패키지는 구매를 한 후에도 노출되도록 설정(추후 리팩토링 필요) sgkim 2017-12-18
    if (package_name == 'package_adventure_clear') then
        local is_active = g_adventureClearPackageData:isActive()
        local is_visible = g_adventureClearPackageData:isVisible_adventureClearPack()
        if (is_active and (is_visible == false)) then
            return false
        else
            return true
        end
    end

    local l_shop_list = g_shopDataNew:getProductList('package')
    local target_product = TablePackageBundle:getPidsWithName(package_name)
    local is_exist = false

    if (not target_product) then
        error('package_name : ' .. package_name)
    end

    for _, pid in ipairs(target_product) do
        if (l_shop_list[tonumber(pid)]) then
            is_exist = true
        end
    end


    return is_exist
end

-------------------------------------
-- function isBuyAll
-- @brief 번들 패키지일 경우 모두 구매했는지 체크
-------------------------------------
function PackageManager:isBuyAll(package_name)
    local l_shop_list = g_shopDataNew:getProductList('package')
    local target_product = TablePackageBundle:getPidsWithName(package_name)
    local is_buy_all = false

    if (not target_product) then
        return is_buy_all
    end

    for _, pid in ipairs(target_product) do
        local data = l_shop_list[tonumber(pid)]
        if (data) then
            local buy_cnt = g_shopDataNew:getBuyCount(pid)
            local max_buy_cnt = data['max_buy_count']
            if (buy_cnt == '' or max_buy_cnt == '') then
                is_buy_all = false
                break
            end
            if (buy_cnt >= max_buy_cnt) then
                is_buy_all = true
            else
                is_buy_all = false
                break
            end
        end
    end

    return is_buy_all
end