PackageManager = {}

-------------------------------------
-- function getTargetUI
-- @brief 해당 패키지 상품 UI
-------------------------------------
function PackageManager:getTargetUI(struct_product, is_popup)
    local target_ui = nil
    local pid = struct_product['product_id'] 

    local package_name = TablePackageBundle:getPackageNameWithPid(pid) 

    -- 레벨업 패키지 UI
    if (package_name == 'package_levelup') or (pid == 'package_levelup') then
        local _struct_product = g_shopDataNew:getLevelUpPackageProduct()
        target_ui = UI_Package_LevelUp(_struct_product, is_popup)

    -- 다이아 몽땅 패키지
    elseif (package_name == 'package_dia_all') then
        target_ui = UI_Package(struct_product, is_popup)

    -- 패키지 상품 묶음 UI (pid로 들어오지만 패키지 상품 묶음 UI를 보여줘야 하는 경우)
    elseif package_name then
        target_ui = UI_Package_Bundle(package_name, is_popup)

    -- 패키지 상품 묶음 UI (package name으로 직접 들어오는 경우)
    elseif TablePackageBundle:checkBundleWithName(pid) then
        target_ui = UI_Package_Bundle(pid, is_popup)

    -- ** 일반 패키지 상품 
    -- 스페셜 패키지
    -- 스타터 패키지
    -- 골드 몽땅 패키지
    -- 날개 몽땅 패키지
    -- 속성 성장 패키지
    else
        target_ui = UI_Package(struct_product, is_popup)
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