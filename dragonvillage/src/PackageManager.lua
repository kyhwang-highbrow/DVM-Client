PackageManager = {}

-------------------------------------
-- function getTargetUI
-- @brief 해당 패키지 상품 UI
-- @param package_name : table_bundle_package에 등록된 패키지 네임
-- @param is_popup : true - 팝업, false - 이벤트 탭에 등록 (종료 버튼 없음)
-------------------------------------
function PackageManager:getTargetUI(package_name, is_popup, product_id, is_full_popup)
    local target_ui = nil
    local _package_name = package_name
    
    print('Package Name : ' .. _package_name)
    -- 패키지에 뜨는 UI와 풀팝업에 뜨는 UI를 구분하고 싶은 경우
    -- 패키지 네임 뒤에 _popup 추가하고, 아래 조건문에서 분기로 구분하여 사용
    if (string.find(package_name, '_popup')) then
        local l_package_name_split = plSplit(package_name, '_popup')
        package_name = l_package_name_split[1]
    end

    -- struct product로 들어온 경우 package_name 으로 변환
    if (type(package_name) ~= 'string') then
        local struct_product = package_name
        local pid = struct_product['product_id']
        package_name = TablePackageBundle:getPackageNameWithPid(pid)   
        _package_name = package_name
    end
    
    -- 서버에서 받은 상품 정보가 없다면 nil 반환
    if (self:isExist(package_name) == false) then
        return nil
    end

    -- 레벨업 패키지 UI
    if (_package_name == 'package_levelup') then
        local _struct_product = g_shopDataNew:getTargetProduct(LEVELUP_PACKAGE_PRODUCT_ID)
        local list = {}
        table.insert(list, _struct_product)
        target_ui = UI_Package_LevelUp_01(list, is_popup)
    
    -- 레벨업 패키지2 UI
    elseif (_package_name == 'package_levelup_02') then
        local _struct_product = g_shopDataNew:getTargetProduct(LEVELUP_PACKAGE_2_PRODUCT_ID)
        local list = {}
        table.insert(list, _struct_product)
        target_ui = UI_Package_LevelUp_02(list, is_popup)

    -- 레벨업 패키지3 UI
    elseif (_package_name == 'package_levelup_03') then
        local _struct_product = g_shopDataNew:getTargetProduct(LEVELUP_PACKAGE_3_PRODUCT_ID)
        local list = {}
        table.insert(list, _struct_product)
        target_ui = UI_Package_LevelUp_03(list, is_popup)

    -- 모험돌파 패키지 UI
    elseif (_package_name == 'package_adventure_clear') then
        local _struct_product = g_shopDataNew:getAdventureClearProduct()
        local list = {}
        table.insert(list, _struct_product)
        target_ui = UI_Package_AdventureClear01(list, is_popup)
    
    -- 모험돌파 패키지2 UI
    elseif (_package_name == 'package_adventure_clear_02') then
        local _struct_product = g_shopDataNew:getAdventureClearProduct02()
        require('UI_Package_AdventureClear02')
        local list = {}
        table.insert(list, _struct_product)
        target_ui = UI_Package_AdventureClear02(list, is_popup)

    -- 모험돌파 패키지3 UI
    elseif (_package_name == 'package_adventure_clear_03') then
        local _struct_product = g_shopDataNew:getAdventureClearProduct03()
        require('UI_Package_AdventureClear03')
        local list = {}
        table.insert(list, _struct_product)
        target_ui = UI_Package_AdventureClear03(list, is_popup)

    -- 육성패스 
    elseif string.find(_package_name, 'battle_pass') then
        local pid
        if product_id then
            pid = product_id
        else
            local pid_strs = TablePackageBundle:getPidsWithName(_package_name)
            pid = tonumber(pid_strs[1])
        end
        local _struct_product = g_shopDataNew:getTargetProduct(pid)
        local list = {}
        table.insert(list, _struct_product)
        target_ui = UI_BattlePass_Nurture(list, is_popup)

    -- 차원문 돌파 패키지
    elseif string.find(_package_name, 'package_dmgate') and (not g_contentLockData:isContentLock('dmgate')) then
        require('UI_Package_Dmgate')
        local pid
        if product_id then 
            pid = product_id
        else
            local pid_strs = TablePackageBundle:getPidsWithName(_package_name)

            pid = pid_strs[1]
        end

        local _struct_product = g_shopDataNew:getTargetProduct(tonumber(pid))
        local list = {}
        table.insert(list, _struct_product)
        target_ui = UI_Package_Dmgate(list, is_popup)
    elseif string.find(_package_name, 'package_clan_raid_earth') then
        require('UI_Package_ClanRaid_Earth')
        local pid
        if product_id then 
            pid = product_id
        else
            local pid_strs = TablePackageBundle:getPidsWithName(_package_name)

            pid = pid_strs[1]
        end

        local _struct_product = g_shopDataNew:getTargetProduct(tonumber(pid))
        local list = {}
        table.insert(list, _struct_product)
        target_ui = UI_Package_ClanRaid_Earth(list, is_popup)
    elseif string.find(_package_name, 'package_clan_raid_water') then
        require('UI_Package_ClanRaid_Water')
        local pid
        if product_id then 
            pid = product_id
        else
            local pid_strs = TablePackageBundle:getPidsWithName(_package_name)

            pid = pid_strs[1]
        end

        local _struct_product = g_shopDataNew:getTargetProduct(tonumber(pid))
        local list = {}
        table.insert(list, _struct_product)
        target_ui = UI_Package_ClanRaid_Water(list, is_popup)
    elseif string.find(_package_name, 'package_clan_raid_fire') then
        require('UI_Package_ClanRaid_Fire')
        local pid
        if product_id then 
            pid = product_id
        else
            local pid_strs = TablePackageBundle:getPidsWithName(_package_name)

            pid = pid_strs[1]
        end

        local _struct_product = g_shopDataNew:getTargetProduct(tonumber(pid))
        local list = {}
        table.insert(list, _struct_product)
        target_ui = UI_Package_ClanRaid_Fire(list, is_popup)
    elseif string.find(_package_name, 'package_clan_raid_light') then
        require('UI_Package_ClanRaid_Light')
        local pid
        if product_id then 
            pid = product_id
        else
            local pid_strs = TablePackageBundle:getPidsWithName(_package_name)

            pid = pid_strs[1]
        end

        local _struct_product = g_shopDataNew:getTargetProduct(tonumber(pid))
        local list = {}
        table.insert(list, _struct_product)
        target_ui = UI_Package_ClanRaid_Light(list, is_popup)
    elseif string.find(_package_name, 'package_clan_raid_dark') then
        require('UI_Package_ClanRaid_Dark')
        local pid
        if product_id then 
            pid = product_id
        else
            local pid_strs = TablePackageBundle:getPidsWithName(_package_name)

            pid = pid_strs[1]
        end

        local _struct_product = g_shopDataNew:getTargetProduct(tonumber(pid))
        local list = {}
        table.insert(list, _struct_product)
        target_ui = UI_Package_ClanRaid_Dark(list, is_popup)
    -- 시험의 탑 정복선물 패키지
    elseif (_package_name == 'package_attr_tower') then
        require('UI_Package_AttrTowerPopup')
        target_ui = UI_Package_AttrTowerPopup(is_popup)

    -- 시험의 탑 정복선물 패키지 풀팝업 (구입하지 않은 빛, 어둠, 땅, 물, 불 순서로 풀팝업 출력, 모두 구입한 경우 띄우지 않음)
    elseif (_package_name == 'package_attr_tower_popup') then
        local l_attr_list = {'light', 'dark', 'earth', 'water', 'fire'}
        local attr_tower_package_id = nil   
        for idx, attr in ipairs(l_attr_list) do
            local l_product_list = g_attrTowerPackageData:getProductIdList(attr)
            
            for _, product_id in ipairs(l_product_list) do
                local struct_product = g_shopDataNew:getTargetProduct(product_id)
                if (struct_product:isItBuyable()) then
                    attr_tower_package_id = product_id
                    break
                end
            end

            if (attr_tower_package_id ~= nil) then
                break
            end
        end

        if (attr_tower_package_id ~= nil) then
            require('UI_Package_AttrTower')
            target_ui = UI_Package_AttrTower(nil, attr_tower_package_id, is_popup)
        end

    -- 기간제 단계별 패키지 UI
    --elseif (_package_name == 'package_step_period') then
    elseif pl.stringx.startswith(_package_name, 'package_step_period') then
        target_ui = UI_Package_Step02(_package_name, is_popup)

    -- 특정 드래곤 판매 패키지 UI(ex : 뱃도치)
    elseif (_package_name == 'package_new_dragon' or _package_name == 'package_new_dragon_02') then
        target_ui = UI_Package_New_Dragon(_package_name, is_popup)

    -- 단계별 패키지 UI
    elseif (_package_name == 'package_step') then
        target_ui = UI_Package_Step(_package_name, is_popup)

    -- 단계별 패키지 2 UI
    elseif (_package_name == 'package_step_02') then
        target_ui = UI_Package_Step02(_package_name, is_popup)

    -- 단계별 패키지 3 UI
    elseif (_package_name == 'package_step_03') then
        require('UI_Package_Step03')
        target_ui = UI_Package_Step03(_package_name, is_popup)

    -- 단계별 패키지 4 UI
    elseif (_package_name == 'package_step_04') then
        require('UI_Package_Step04')
        target_ui = UI_Package_Step04(_package_name, is_popup)

    -- 스타터 지원 패키지 UI - 구조가 다른 패키지와 비슷한듯 하면서 상이하다
    elseif (_package_name == 'package_starter_2') then
        target_ui = UI_Package_Bundle(_package_name, is_popup)
        target_ui.click_buyBtn = function()
            local ui = UI_Package_Select_Radio(_package_name, true)
            ui:setBuyCB(function() target_ui:refresh() end)
        end
    -- 글로벌 1주년 패키지
    elseif (_package_name == 'package_global_anniversary') then
        target_ui = UI_Package_Bundle(_package_name, is_popup)
        target_ui.vars['dragonInfoBtn']:registerScriptTapHandler(function() UI_SummonDrawInfo() end)
    
    -- 캡슐 코인 패키지
    elseif (_package_name == 'package_capsule_coin') then
        target_ui = UI_Package_Bundle(_package_name, is_popup)
        self:setCapsulePackageReward(target_ui)

    -- 영웅 드래곤 선택권 패키지
    elseif (_package_name == 'package_dragon_choice_hero') then
        require('UI_Package_DragonChoiceHero')
        target_ui = UI_Package_DragonChoiceHero(_package_name, is_popup)

    -- 보급소
    elseif (_package_name == 'package_supply') then
        require('UI_SupplyDepot')
        target_ui = UI_SupplyDepot(_package_name, is_popup)

    -- 드래곤 스킨 판매
    elseif (_package_name == 'package_dragon_skin') then
        require('UI_DragonSkinSale')
        target_ui = UI_DragonSkinSale(_package_name, is_popup)

    elseif (string.find(_package_name, 'winter_festival')) then
        target_ui = self:makeOfferPopup(_package_name, is_popup, is_full_popup)

    elseif (string.find(_package_name, 'package_2000day_01')) then
        target_ui = self:makeOfferPopup(_package_name, is_popup, is_full_popup)

    -- 패키지 상품 묶음 UI 
    -- ### 단일 상품도 table_bundle_package에 등록
    elseif (TablePackageBundle:checkBundleWithName(_package_name)) then
        local row_num = TablePackageBundle:getBundleValueByPackageName(_package_name, 'row_num')
        -- type이 bundle에서 row_num을 1로 설정할 경우 순차 구매 패키지로 간주
        if (row_num == 1) then
            target_ui = UI_Package_Bundle_Dependency(_package_name, is_popup)
        else
            target_ui = UI_Package_Bundle(_package_name, is_popup)
        end
    else
        error('등록 되지 않은 package name : '.. _package_name .. ' TABLE_PACKAGE_BUNDLE 등록')
    end

    return target_ui
end

-------------------------------------
-- function isExist
-- @brief 묶음 UI에서 상품정보가 하나라도 있는지 (모두 구매해서 없거나, 기간이 자니서 없거나 하는 경우)
-------------------------------------
function PackageManager:isExist(package_name)
    
    -- 레벨업 패키지는 구매를 한 후에도 노출되도록 설정(추후 리팩토링 필요) sgkim 2017-10-25
    if (package_name == 'package_levelup') then
        return g_levelUpPackageDataOld:isVisibleAtPackageShop(LEVELUP_PACKAGE_PRODUCT_ID)
    end

    -- 레벨업 패키지2는 구매를 한 후에도 노출되도록 설정(추후 리팩토링 필요) sgkim 2017-10-25
    if (package_name == 'package_levelup_02') then
        return g_levelUpPackageDataOld:isVisibleAtPackageShop(LEVELUP_PACKAGE_2_PRODUCT_ID)
    end

    -- 레벨업 패키지3는 구매를 한 후에도 노출되도록 설정(추후 리팩토링 필요) mskim 2020.08.24
    if (package_name == 'package_levelup_03') then
        return g_levelUpPackageDataOld:isVisibleAtPackageShop(LEVELUP_PACKAGE_3_PRODUCT_ID)
    end

    -- 모험돌파 패키지는 구매를 한 후에도 노출되도록 설정(추후 리팩토링 필요) sgkim 2017-12-18
    if (package_name == 'package_adventure_clear') then
        local is_active = g_adventureClearPackageData01:isActive()
        local is_visible = g_adventureClearPackageData01:isVisible_adventureClearPack()
        if (is_active and (is_visible == false)) then
            return false
        else
            return true
        end
    end

    -- 모험돌파 패키지는 구매를 한 후에도 노출되도록 설정(추후 리팩토링 필요)
    if (package_name == 'package_adventure_clear_02') then
        local is_active = g_adventureClearPackageData02:isActive()
        local is_visible = g_adventureClearPackageData02:isVisible_adventureClearPack()
        if (is_active and (is_visible == false)) then
            return false
        else
            return true
        end
    end

    -- 모험돌파 패키지는 구매를 한 후에도 노출되도록 설정(추후 리팩토링 필요) .. 2020.08.24
    if (package_name == 'package_adventure_clear_03') then
        local is_active = g_adventureClearPackageData03:isActive()
        local is_visible = g_adventureClearPackageData03:isVisible_adventureClearPack()
        if (is_active and (is_visible == false)) then
            return false
        else
            return true
        end
    end


    -- 차원의 문 돌파 패키지는 구매를 한 후에도 노출되도록 설정(추후 리팩토링 필요)
    if string.find(package_name, 'package_dmgate') then
        local pid
        if product_id then 
            pid = product_id
        else
            local pid_strs = TablePackageBundle:getPidsWithName(package_name)

            pid = pid_strs[1]
        end

        local is_visible = g_dmgatePackageData:isPackageVisible(pid)

        return is_visible
    end

    -- 클랜 던전 (땅) 패키지는 구매를 한 후에도 노출되도록 설정(추후 리팩토링 필요)
    if string.find(package_name, 'package_clan_raid_earth') then
        local is_active = g_clanDungeonEarthPackageData:isActive()
        local is_visible = g_clanDungeonEarthPackageData:isVisibleAtBattlePassShop()
        if (is_active and (is_visible == false)) then
            return false
        else
            return true
        end
        -- local pid
        -- if product_id then 
        --     pid = product_id
        -- else
        --     local pid_strs = TablePackageBundle:getPidsWithName(package_name)

        --     pid = pid_strs[1]
        -- end

        -- local is_visible = g_clanDungeonEarthPackageData:isPackageVisible(pid)

        -- return is_visible
    end
    
    -- 클랜 던전 (물) 패키지는 구매를 한 후에도 노출되도록 설정(추후 리팩토링 필요)
    if string.find(package_name, 'package_clan_raid_water') then

        local is_active = g_clanDungeonWaterPackageData:isActive()
        local is_visible = g_clanDungeonWaterPackageData:isVisibleAtBattlePassShop()
        if (is_active and (is_visible == false)) then
            return false
        else
            return true
        end
        -- local pid
        -- if product_id then 
        --     pid = product_id
        -- else
        --     local pid_strs = TablePackageBundle:getPidsWithName(package_name)

        --     pid = pid_strs[1]
        -- end

        -- local is_visible = g_clanDungeonWaterPackageData:isPackageVisible(pid)

        -- return is_visible
    end
    
    -- 클랜 던전 (불) 패키지는 구매를 한 후에도 노출되도록 설정(추후 리팩토링 필요)
    if string.find(package_name, 'package_clan_raid_fire') then
        local is_active = g_clanDungeonFirePackageData:isActive()
        local is_visible = g_clanDungeonFirePackageData:isVisibleAtBattlePassShop()
        if (is_active and (is_visible == false)) then
            return false
        else
            return true
        end
        -- local pid
        -- if product_id then 
        --     pid = product_id
        -- else
        --     local pid_strs = TablePackageBundle:getPidsWithName(package_name)

        --     pid = pid_strs[1]
        -- end

        -- local is_visible = g_clanDungeonFirePackageData:isPackageVisible(pid)

        -- return is_visible
    end
    
    -- 클랜 던전 (빛) 패키지는 구매를 한 후에도 노출되도록 설정(추후 리팩토링 필요)
    if string.find(package_name, 'package_clan_raid_light') then
        local is_active = g_clanDungeonLightPackageData:isActive()
        local is_visible = g_clanDungeonLightPackageData:isVisibleAtBattlePassShop()
        if (is_active and (is_visible == false)) then
            return false
        else
            return true
        end
        -- local pid
        -- if product_id then 
        --     pid = product_id
        -- else
        --     local pid_strs = TablePackageBundle:getPidsWithName(package_name)

        --     pid = pid_strs[1]
        -- end

        -- local is_visible = g_clanDungeonLightPackageData:isPackageVisible(pid)

        -- return is_visible
    end

    -- 클랜 던전 (어둠) 패키지는 구매를 한 후에도 노출되도록 설정(추후 리팩토링 필요)
    if string.find(package_name, 'package_clan_raid_dark') then
        local is_active = g_clanDungeonDarkPackageData:isActive()
        local is_visible = g_clanDungeonDarkPackageData:isVisibleAtBattlePassShop()
        if (is_active and (is_visible == false)) then
            return false
        else
            return true
        end
        -- local pid
        -- if product_id then 
        --     pid = product_id
        -- else
        --     local pid_strs = TablePackageBundle:getPidsWithName(package_name)

        --     pid = pid_strs[1]
        -- end

        -- local is_visible = g_clanDungeonDarkPackageData:isPackageVisible(pid)

        -- return is_visible
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

    
    -- table_package_bundle.csv
    local target_product = TablePackageBundle:getPidsWithName(package_name)
    
    if (not target_product) then
        error('package_name : ' .. package_name)
    end
    
    -- 일반 패키지 & 패스 검사
    local shop_list = g_shopDataNew:getProductList('package')
    local pass_list = g_shopDataNew:getProductList('pass')
    local etc_list = g_shopDataNew:getProductList('etc')

    for _, pid in ipairs(target_product) do
        if (shop_list[tonumber(pid)]) then
            return true
        elseif (pass_list[tonumber(pid)]) then
            return true
        elseif (etc_list[tonumber(pid)]) then
            return true
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

-------------------------------------
-- function setCapsulePackageReward
-------------------------------------
function PackageManager:setCapsulePackageReward(target_ui)
    local show_capule_reward = function()
        UI_CapsuleBox.setCapsulePackageReward(target_ui)  
    end
    
    -- 캡슐 보상 출력할 때, 그 시점의 캡슐뽑기 정보를 가져오기 위해 통신을 함
    g_capsuleBoxData:refreshCapsuleBoxStatus(show_capule_reward)
end


-------------------------------------
-- function showOfferPopup
-------------------------------------
function PackageManager:makeOfferPopup(package_name, is_popup, is_full_popup)
    -- 리스트에서 걸러서 보여줌
    local struct_product = g_shopDataNew:getSpecialOfferProductCommonStep(package_name)
    if (not struct_product) then return nil end
    
    local pid = struct_product['product_id']
    local package_name = TablePackageBundle:getPackageNameWithPid(pid)   
    local package_data = TablePackageBundle:getDataWithName(package_name)
    local ui = UI_Package_Bundle(package_name, is_popup, struct_product, is_full_popup)

    -- mail_content 하나하나 순서대로 라벨에 뿌려주기
    local l_product = ServerData_Item:parsePackageItemStr(struct_product['mail_content'])

    for i, product in ipairs(l_product) do
        local label = ui.vars['itemLabel' .. tostring(i)]
        local string_result = ''

        -- 구성품 t_desc 표시
        if (isTable(package_data)) and (package_data['use_desc'] == 1) then
            string_result = Str(struct_product['t_desc'])
        -- 구성품 mail_content 표시
        else
            local name = TableItem:getItemName(product['item_id'])
            local cnt = product['count']
            string_result = Str('{1} {2}개', name, comma_value(cnt))
        end

        if (label) then label:setString(string_result) end
    end

    local is_buy = struct_product and
                   struct_product:checkIsSale() and -- 판매중인 상품인지 확인
                   struct_product:isItBuyable()

    if (is_buy) then
		ui.vars['buyLabel']:setString('')
    else
		ui.vars['buyLabel']:setString('{@available}' .. Str('구매 가능'))
    end

    -- 혜택률 표시
    -- '800% 이상의 혜택!'
    if bonus_num and ui.vars['bonusLabel'] then ui.vars['bonusLabel']:setString(Str('{1}%', bonus_num)) end
    ui:doAction()

    return ui
end