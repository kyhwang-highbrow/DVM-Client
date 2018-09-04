PackageManager = {}

-------------------------------------
-- function getTargetUI
-- @brief 해당 패키지 상품 UI
-- @param package_name : table_bundle_package에 등록된 패키지 네임
-- @param is_popup : true - 팝업, false - 이벤트 탭에 등록 (종료 버튼 없음)
-------------------------------------
function PackageManager:getTargetUI(package_name, is_popup)
    local target_ui = nil
    local _package_name = package_name

    -- struct product로 들어온 경우 package_name 으로 변환
    if (type(package_name) ~= 'string') then
        local struct_product = package_name
        local pid = struct_product['product_id']
        _package_name = TablePackageBundle:getPackageNameWithPid(pid)   
    end

    -- 서버에서 받은 상품 정보가 없다면 nil 반환
    if (self:isExist(_package_name) == false) then
        return nil
    end

    -- 레벨업 패키지 UI
    if (_package_name == 'package_levelup') then
        local _struct_product = g_shopDataNew:getLevelUpPackageProduct()
        target_ui = UI_Package_LevelUp(_struct_product, is_popup)

    -- 모험돌파 패키지 UI
    elseif (_package_name == 'package_adventure_clear') then
        local _struct_product = g_shopDataNew:getAdventureClearProduct()
        target_ui = UI_Package_AdventureClear(_struct_product, is_popup)

    -- 단계별 패키지 UI
    elseif (_package_name == 'package_step') then
        target_ui = UI_Package_Step(_package_name, is_popup)

    -- 단계별 패키지 2 UI
    elseif (_package_name == 'package_step_02') then
        target_ui = UI_Package_Step02(_package_name, is_popup)

    -- 스타터 지원 패키지 UI - 구조가 다른 패키지와 비슷한듯 하면서 상이하다
    elseif (_package_name == 'package_starter_2') then
        target_ui = UI_Package_Bundle(_package_name, is_popup)
        target_ui.click_buyBtn = function()
            local ui = UI_Package_Select_Radio(_package_name, true)
            ui:setBuyCB(function() target_ui:refresh() end)
        end

    -- 패키지 상품 묶음 UI 
    -- ### 단일 상품도 table_bundle_package에 등록
    elseif (TablePackageBundle:checkBundleWithName(_package_name)) then
        target_ui = UI_Package_Bundle(_package_name, is_popup)

    else
        error('등록 되지 않은 package name : '.. _package_name .. ' TABLE_PACKAGE_BUNDLE 등록')
    end

    return target_ui
end
--[[
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
]]
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

    -- 패키지가 아니지만 풀팝업을 위해 패키지 번들에 추가한 케이스 (추후 리팩토링 필요) klee 2018-06-14
    if (package_name == 'event_dia_discount') or (package_name == 'event_gold_bonus') then
        local target_product = TablePackageBundle:getPidsWithName(package_name)
        local is_exist = false
        for _, pid in ipairs(target_product) do
            local struct_product = g_shopDataNew:getTargetProduct(tonumber(pid))
            if (struct_product) and (struct_product:checkMaxBuyCount()) then
                is_exist = true
            end
        end

        return is_exist
    end

    -- 일반 패키지 검사
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
    local l_product_list = g_shopDataNew:getProductList('package')
    local l_pid_list = TablePackageBundle:getPidsWithName(package_name)
    local is_buy_all = false

    if (not l_pid_list) then
        return is_buy_all
    end
    
    if (TablePackageBundle:isSelectOnePackage(package_name)) then
        for _, pid in ipairs(l_pid_list) do
            local data = l_product_list[tonumber(pid)]
            if (data) then
                local buy_cnt = g_shopDataNew:getBuyCount(pid)
                local max_buy_cnt = data['max_buy_count']
                if (buy_cnt >= max_buy_cnt) then
                    is_buy_all = true
                    break
                end

            -- struct_product가 없다면 구매한것으로 봄
            else
                is_buy_all = true
                break
            end
        end

    else
        for _, pid in ipairs(l_pid_list) do
            local data = l_product_list[tonumber(pid)]
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

    end

    return is_buy_all
end

-------------------------------------
-- function isBuyable
-------------------------------------
function PackageManager:isBuyable(package_name)
	-- 모두 구매
	if (self:isBuyAll(package_name)) then
		return false

	-- 레벨 제한 걸림
	elseif (not TablePackageBundle:isBuyableLv(package_name, g_userData:get('lv'))) then
		return false
	end

	-- 모두 통과하면 구매 가능
	return true
end
