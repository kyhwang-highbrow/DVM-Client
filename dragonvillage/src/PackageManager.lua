PackageManager = {}

-------------------------------------
-- function getTargetUI
-- @brief 해당 패키지 상품 UI
-------------------------------------
function PackageManager:getTargetUI(struct_product, is_popup)
    local target_ui = nil
    local pid = struct_product['product_id'] 

    local package_name = TablePackageBundle:getPackageNameWithPid(pid) 

    -- 패키지 상품 묶음 UI (pid로 들어오지만 패키지 상품 묶음 UI를 보여줘야 하는 경우)
    if package_name then
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



