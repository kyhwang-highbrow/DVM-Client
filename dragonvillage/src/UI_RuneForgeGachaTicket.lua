local PARENT = UI_IndivisualTab
-------------------------------------
-- class UI_RuneForgeGachaTicket
-------------------------------------
UI_RuneForgeGachaTicket = class(PARENT,{
    m_TabCount = 'number',  --탭 개수
    m_myTab = 'number',     --바라보고있는 탭번호
    m_mapConstMileage = 'List<string>',
    m_mTabAnimator = 'Map<number, Animator>',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_RuneForgeGachaTicket:init(owner_ui)
    local vars = self:load('rune_forge_gacha_ticket.ui')
    --[1]:일반 [2]:고대
    self.m_TabCount = 2 
    self.m_myTab = 1    --기본은 일반
    self.m_mTabAnimator = {}
    self.m_mapConstMileage = {'rune_mileage', 'rune_ancient_mileage'}
    self:refresh()
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_RuneForgeGachaTicket:onEnterTab(first)
    self.m_ownerUI:showNpc() -- NPC 등장

    if (first == true) then
        self:initUI()
    end

    self:refresh()
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_RuneForgeGachaTicket:onExitTab()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RuneForgeGachaTicket:initUI()
    local vars = self.vars
    local package_rune = g_shopDataNew:getTargetPackage('package_rune_box')

    if package_rune then
        vars['buyBtn']:registerScriptTapHandler(function() UI_Package(package_rune:getProductList(), true) end)
    else
        vars['buyBtn']:setVisible(false)
    end

    vars['gachaBtn']:registerScriptTapHandler(function() self:click_gachaBtn('rune_ticket') end)
    vars['gachaDiaBtn']:registerScriptTapHandler(function() self:click_gachaBtn('cash') end)

    vars['infoBtn']:registerScriptTapHandler(function() UI_RuneForgeGachaInfo(self.m_myTab, 'rune_forge_gacha_ticket_info.ui') end)
    vars['rewardBtn']:registerScriptTapHandler(function() self:click_rewardBtn() end)
    --vars['rewardInfoBtn']:registerScriptTapHandler(function() self:click_rewardInfoBtn() end)

    --룬 뽑기 버튼 설정
    for index = 1, self.m_TabCount do
        vars['runeSelectBtn'..index]:registerScriptTapHandler(function() self:click_ChangeBtn(index) end)
    end

    do -- 다이아 가격
        local item_value = g_runesData:getRuneTicketGachaDiaPrice()
        vars['gachaDiaLabel']:setString(comma_value(item_value))
    end

    do
        local tint_action = cca.buttonShakeAction(1 ,3.0)
        vars['speechSprite']:stopAllActions()
        vars['speechSprite']:runAction(tint_action)
    end
end

-------------------------------------
-- function update
-------------------------------------
function UI_RuneForgeGachaTicket:update(dt)
    local vars = self.vars
end

-------------------------------------
-- function click_gachaBtn
-------------------------------------
function UI_RuneForgeGachaTicket:click_gachaBtn(goods_type)
    -- 조건 체크
    local rune_ticket_count = g_userData:get(goods_type) or 0
    local item_name = TableItem:getItemNameFromItemType(goods_type) -- 룬 교환 티켓

    if (rune_ticket_count <= 0) then
        UIManager:toastNotificationRed(Str('{1}이(가) 부족합니다.', item_name))
        return
    end

    local item_value = 1
    if goods_type == 'cash' then
        item_value = g_runesData:getRuneTicketGachaDiaPrice()
    end

    local msg = Str('{@item_name}"{1} x{2}"\n{@default}사용하시겠습니까?', item_name, comma_value(item_value))
    MakeSimplePopup_Confirm(goods_type, item_value, msg, function() self:request_runeGacha(goods_type == 'cash') end)
end

-------------------------------------
-- function subsequentSummons
-- @brief 이어서 뽑기 설정
-------------------------------------
function UI_RuneForgeGachaTicket:subsequentSummons(gacha_result_ui, is_cash)
    local vars = gacha_result_ui.vars
	-- 다시하기 버튼 등록
    vars['againBtn']:registerScriptTapHandler(function()
        gacha_result_ui:close()
        self:request_runeGacha(is_cash)
    end)
end

-------------------------------------
-- function request_runeGacha
-------------------------------------
function UI_RuneForgeGachaTicket:request_runeGacha(is_cash)
    local myTab = tostring(self.m_myTab)
    -- 룬 최대 보유 수량 체크
    if (not g_runesData:checkRuneGachaMaximum(10)) then
        return
    end

    local function close_cb()
        self.m_ownerUI:refresh_highlight()
        self:refresh()
    end

    local function finish_cb(ret)
		local gacha_type = 'rune_ticket'
        local l_rune_list = ret['runes']

        local ui = UI_GachaResult_Rune(gacha_type, l_rune_list)
        
        ui:setCloseCB(close_cb)

        -- 이어서 뽑기 설정
        self:subsequentSummons(ui, is_cash)
    end
    
    local is_bundle = true
    g_runesData:request_runeGachaTicket(is_bundle, is_cash, myTab, finish_cb, nil) -- param: is_bundle, finish_cb, fail_cb
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RuneForgeGachaTicket:refresh()
    local vars = self.vars

    --룬 상자 이미지
    vars['runeBoxNode']:removeAllChildren()
    vars['runeBoxNode']:addChild(self:getRuneBoxIcon())

    --룬 상자 텍스트
    self:setRuneBoxString()

    --룬 버튼 상태
    local myTab = self.m_myTab
    for i = 1, self.m_TabCount do
        vars['runeSelectBtn'..i]:setEnabled(not (myTab == i))
    end
--[[ 
    do -- 다이아 노티
        local cash = g_userData:get('cash') or 0
        local is_cash_on = cash >= g_runesData:getRuneTicketGachaDiaPrice()
        vars['diaNotiSprite']:setVisible(is_cash_on)
    end  ]]

    do -- 룬티켓 노티
        local ticket = g_userData:get('rune_ticket') or 0
        local is_ticket_on = ticket > 0
        vars['ticketNotiSprite']:setVisible(is_ticket_on)
    end

    -- 룬 마일리지 정보
    self:refreshMileage()

    -- 탭 레드닷 노출
    self:refreshTabNoti()
end

-------------------------------------
-- function getMileageProduct
-------------------------------------
function UI_RuneForgeGachaTicket:getMileageProduct()
    local str_type = self.m_mapConstMileage[self.m_myTab]
    local struct_product_list = g_shopDataNew:getProductList(str_type)
    local struct_product =  table.getFirst(struct_product_list)
    return struct_product, str_type
end


-------------------------------------
-- function refreshMileage
-------------------------------------
function UI_RuneForgeGachaTicket:refreshMileage()
    local vars = self.vars

    -- 마일리지 상품
    local struct_product, mileage_type = self:getMileageProduct()
    if struct_product ~= nil then 
        -- 상품 이름
        local product_name = struct_product:getFirstItemName()
        vars['itemLabel']:setString(product_name)
        
        -- 상품 아이콘
        if self.m_mTabAnimator[self.m_myTab] == nil then
            local icon = struct_product:makeProductIcon()
            if (icon) then            
                vars['rewardNode']:addChild(icon)
                self.m_mTabAnimator[self.m_myTab] = icon
            end
        end

        self.m_mTabAnimator[self.m_myTab]:setVisible(true)
        local other_animator = self.m_mTabAnimator[3 - self.m_myTab]
        if other_animator ~= nil then
            other_animator:setVisible(false)
        end

        self.m_mTabAnimator[self.m_myTab]:setVisible(true)
        local other_animator = self.m_mTabAnimator[3 - self.m_myTab]
        if other_animator ~= nil then
            other_animator:setVisible(false)
        end

        local curr_count = g_userData:get(mileage_type)
        local need_count = struct_product:getPrice()
        local percent = (curr_count/need_count)*100
        -- 게이지
        local gauge_node = vars['mileageGauge']
        gauge_node:setPercentage(percent)
        -- 게이지 수치
        vars['mileageLabel']:setStringArg(comma_value(curr_count), comma_value(need_count))
        -- 소환권 획득이 가능할 경우
        local is_enough_mileage = curr_count >= need_count
        vars['rewardNotiSprite']:setVisible(is_enough_mileage)
        -- 버튼 enable
        vars['rewardBtn']:setEnabled(is_enough_mileage)

        if is_enough_mileage == false then
            vars['changeLabel']:setTextColor(cc.c4b(0, 0, 0, 255))
        else
            vars['changeLabel']:setTextColor(cc.c4b(70, 60, 0, 255))
        end
    end
end

-------------------------------------
-- function refreshNoti
-------------------------------------
function UI_RuneForgeGachaTicket:refreshTabNoti()
    local vars = self.vars
    local is_gacha_on = g_runesData:isRuneTicketGachaAvailable(true)

    local rune_ticket_mileage_type = {'rune_mileage', 'rune_ancient_mileage'}
    for idx, type in ipairs(rune_ticket_mileage_type) do
        local is_mileage_on = g_runesData:isRuneTicketGachaMileageAvailable(type)
        local str = string.format('runeSelectNotiSprite%d',idx)
        vars[str]:setVisible(is_gacha_on or is_mileage_on)
    end
end

-------------------------------------
-- function click_ChangeBtn
-------------------------------------
function UI_RuneForgeGachaTicket:click_ChangeBtn(myTab)
    local vars = self.vars
    self.m_myTab = myTab
    self:refresh()

    do -- 게이지 연출
        local struct_product, mileage_type = self:getMileageProduct()
        if struct_product ~= nil then
            local curr_count = g_userData:get(mileage_type)
            local need_count = struct_product:getPrice()
            local percent = (curr_count/need_count)*100

            local gauge_node = vars['mileageGauge']    
            gauge_node:setPercentage(0)
            gauge_node:runAction(cc.ProgressTo:create(0.5, percent))
        end
    end

    do -- 
        local select_animator = self.m_mTabAnimator[self.m_myTab]
        local other_animator = self.m_mTabAnimator[3 - self.m_myTab]

        select_animator:setVisible(true)
        select_animator:setScale(0)
        other_animator:setVisible(true)
        other_animator:setScale(1)

        local func_select = function ()
            local select_action = cc.EaseIn:create(cc.ScaleTo:create(0.2, 1, 1), 0.3)
            select_animator:stopAllActions()
            select_animator:runAction(select_action)
        end

        
        if other_animator ~= nil then           
            local other_action = cc.EaseOut:create(cc.ScaleTo:create(0.2, 0, 0), 0.3)
            local call_func = cc.CallFunc:create(func_select)
            local seq = cc.Sequence:create(other_action, call_func)
            other_animator:stopAllActions()
            other_animator:runAction(seq)
        end
    end
end

-------------------------------------
-- function click_rewardInfoBtn
-- @brief 선택권 리스트
-------------------------------------
function UI_RuneForgeGachaTicket:click_rewardInfoBtn()
    local struct_product = self:getMileageProduct()
    if struct_product == nil then
        return
    end

    local item_list = struct_product:getItemList()
    if item_list[1] == nil then
        return
    end
end


-------------------------------------
-- function click_rewardBtn
-- @brief 마일리지 상품 구매
-------------------------------------
function UI_RuneForgeGachaTicket:click_rewardBtn()
    local struct_product = self:getMileageProduct()
    if struct_product == nil then
        return
    end

    local cb_func = function ()
        local toast_msg = Str('보상이 우편함으로 전송되었습니다.')
        UI_ToastPopup(toast_msg)

        self.m_ownerUI:refresh_highlight()
        self:refresh()
    end

    struct_product:buy(cb_func)
end
-------------------------------------
-- function getRuneBoxIcon
-- @breif 탭에 맞는 룬상자 리소스 리턴
-------------------------------------
function UI_RuneForgeGachaTicket:getRuneBoxIcon()
    local myTab = self.m_myTab
    local res = 'res/ui/icons/rune_forge_gacha/rune_forge_020'..myTab..'.png'
    local sprite = IconHelper:getIcon(res)
    return sprite
end

-------------------------------------
-- function setRuneBoxString
-- @breif 탭에 맞는 룬상자 텍스트 설정
-------------------------------------
function UI_RuneForgeGachaTicket:setRuneBoxString()
    local vars = self.vars
    local myTab = self.m_myTab
    local item_name = TableItem:getItemNameFromItemType('rune_ticket')  -- 룬 교환 티켓

    local text = ''
    if (myTab == 1) then        --일반
        text = item_name
    elseif (myTab == 2) then    --고대
        text = Str('고대 {1}', item_name)
    end
    vars['runeLabel']:setString(text)
end