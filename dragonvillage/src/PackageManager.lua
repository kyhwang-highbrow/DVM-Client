PackageManager = {}

-------------------------------------
-- function getTargetUI
-- @brief 해당 패키지 상품 UI
-------------------------------------
function PackageManager:getTargetUI(struct_product, is_popup)
    local target_ui = nil
    local pid = struct_product['product_id']

    -- 월간 패키지 상품
    if (pid == 90007 or pid == 90008 or pid == 90009) then
        target_ui = UI_Package_Monthly(is_popup)

    -- 주말 패키지 상품
    elseif (pid == 90013 or pid == 90014) then
        target_ui = UI_Package_Weekly(is_popup)

    -- 성장 패키지 상품 (묶음 UI)
    elseif (pid == 'growth_package') then
        target_ui = UI_Package_Growth(is_popup)

    -- 슬라임 패키지 상품 (묶음 UI)
    elseif (pid == 'slime_package') then
        target_ui = UI_Package_Slime(is_popup)

    -- 월정액 상품
    elseif (pid == 99001 or pid == 99002 or pid == 99003 or pid == 99011 or pid == 99012 or pid == 99013) then
        -- pid로 처리하는건지

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



