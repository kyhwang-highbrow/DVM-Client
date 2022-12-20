local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable())

-------------------------------------
-- class UI_PaymentShop
-- @yjkil 2022.02.11 기준 사용 X
-------------------------------------
UI_PaymentShop = class(PARENT,{
        m_tableView = 'UIC_TableView',
        m_lContainerForEachType = 'list[node]', -- (tab)타입별 컨테이너
        m_mTabUI = 'map',

        m_noti = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_PaymentShop:init(noti)
    self.m_noti = noti or false

    local vars = self:load('payment_shop.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_PaymentShop')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    --self:initButton()
    --self:refresh()

    self:sceneFadeInAction()
end

-------------------------------------
-- function initParentVariable
-- @brief
-------------------------------------
function UI_PaymentShop:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_PaymentShop'
    self.m_titleStr = Str('상점')
    self.m_bUseExitBtn = true
    self.m_subCurrency = 'amethyst'
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_PaymentShop:initUI()
    self:init_tableView()
    self:initTab()

    --[[
    g_broadcastManager:setEnableNotice(false) -- 운영 공지는 비활성화 - 웹뷰때문에 뎁스 꼬임

    local vars = self.vars

    -- 리소스가 1280길이로 제작되어 보정 (더 와이드한 해상도)
    local scr_size = cc.Director:getInstance():getWinSize()
    vars['bgVisual']:setScale(scr_size.width / 1280)
    --]]

    --require('UI_1030X640_FirstPurchaseReward')
    --local ui = UI_1030X640_FirstPurchaseReward()
    --self.vars['contentNode']:addChild(ui.root)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_PaymentShop:initButton()
    local vars = self.vars 
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_PaymentShop:refresh()
    
end

-------------------------------------
-- function getPaymentShopTabList
-------------------------------------
function UI_PaymentShop:getPaymentShopTabList()
    local l_tab = {}

    require('StructPaymentShopTab')

    do -- 첫 충전 선물
        for event_id,v in pairs(g_firstPurchaseEventData.m_tFirstPurchaseEventInfo) do
            local unique_key = ('first_purchase_reward_' .. event_id)
            --local unique_key = 'first_purchase_reward'
            local display_name = Str('첫 충전 선물')
            local ui_priority = 1000
            local icon_res = ''
            local func_get_badge_count = function() return 0 end
            local func_make_tab_content = function()
                require('UI_1030X640_FirstPurchaseReward')
                local ui = UI_1030X640_FirstPurchaseReward(event_id)
                return ui
            end
            local struct = StructPaymentShopTab:Create(unique_key, display_name, ui_priority, icon_res, func_get_badge_count, func_make_tab_content)
            struct.m_uiCategoryPriority = 100
            l_tab[unique_key] = struct
        end
    end

    do -- 초보자 선물
        local t_newcomer_shop_map = g_newcomerShop:getNewcomerShopList()
        for ncm_id, _ in pairs(t_newcomer_shop_map) do
            if (g_newcomerShop:isActiveNewcomerShop(ncm_id) == true) then
                -- 초보자 선물 데이터가 있고, 종료 시간이 지나지 않은 경우 생성
                local unique_key = ('newcomer_shop' .. ncm_id)

                local display_name = Str('초보자 선물')
                local ui_priority = 900
                local icon_res = ''
                local func_get_badge_count = function() return 0 end
                local func_make_tab_content = function()
                    require('UI_1030X640_NewcomerShop')
                    local ui = UI_1030X640_NewcomerShop(ncm_id)
                    return ui
                end
                local struct = StructPaymentShopTab:Create(unique_key, display_name, ui_priority, icon_res, func_get_badge_count, func_make_tab_content)
                struct.m_uiCategoryPriority = 100
                l_tab[unique_key] = struct
            end
        end
    end

    do -- 벼룩시장 선물
        local t_flea_shop_map = g_fleaShop:getNewcomerShopList()
        for ncm_id, _ in pairs(t_flea_shop_map) do
            if (g_fleaShop:isActiveNewcomerShop(ncm_id) == true) then
                -- 벼룩시장 선물 데이터가 있고, 종료 시간이 지나지 않은 경우 생성
                local unique_key = ('flea_shop' .. ncm_id)

                local display_name = Str('벼룩시장 선물')
                local ui_priority = 900
                local icon_res = ''
                local func_get_badge_count = function() return 0 end
                local func_make_tab_content = function()
                    require('UI_1030X640_NewcomerShop')
                    local ui = UI_1030X640_NewcomerShop(ncm_id)
                    return ui
                end
                local struct = StructPaymentShopTab:Create(unique_key, display_name, ui_priority, icon_res, func_get_badge_count, func_make_tab_content)
                struct.m_uiCategoryPriority = 100
                l_tab[unique_key] = struct
            end
        end
    end

    do -- 다이아 상점
        local unique_key = 'dia_shop'
        local display_name = Str('다이아 상점')
        local ui_priority = 800
        local icon_res = ''
        local func_get_badge_count = function() return 0 end
        local func_make_tab_content = function()
            require('UI_1030X640_DiaShop')
            local ui = UI_1030X640_DiaShop()
            return ui
        end
        local struct = StructPaymentShopTab:Create(unique_key, display_name, ui_priority, icon_res, func_get_badge_count, func_make_tab_content)
        struct.m_uiCategoryPriority = 100
        l_tab[unique_key] = struct
    end

    do -- 보급소
        local unique_key = 'supply_depot'
        local display_name = Str('보급소')
        local ui_priority = 700
        local icon_res = ''
        local func_get_badge_count = function() return 0 end
        local func_make_tab_content = function()
            require('UI_1030X640_SupplyDepot')
            local ui = UI_1030X640_SupplyDepot()
            return ui
        end
        local struct = StructPaymentShopTab:Create(unique_key, display_name, ui_priority, icon_res, func_get_badge_count, func_make_tab_content)
        struct.m_uiCategoryPriority = 100
        l_tab[unique_key] = struct
    end

    do -- 패키지
        local l_item_list = TablePackageBundle():getTableViewMap()
        for i,v in pairs(l_item_list) do
            local tab = i
            local struct_product = v
            local unique_key = 'pakcage..' .. struct_product.product_id
            local display_name = ''
            do
                -- 버튼 이름 (패키지 번들 참조)
                local pid = struct_product['product_id']
                local desc = TablePackageBundle:getPackageDescWithPid(pid)
                if (desc) then
                    display_name = desc
                end
            end
            local ui_priority = struct_product.m_uiPriority
            local icon_res = ''
            local func_get_badge_count = function() return 0 end
            local func_make_tab_content = function()
                local ui = nil
                local package_name = TablePackageBundle:getPackageNameWithPid(tab)
                if (TablePackageBundle:checkBundleWithName(package_name)) then
                    ui = UI_EventPopupTab_Package(package_name)
                end
                return ui
            end
            local struct = StructPaymentShopTab:Create(unique_key, display_name, ui_priority, icon_res, func_get_badge_count, func_make_tab_content)
            l_tab[unique_key] = struct
        end
    end

    return l_tab
end

-------------------------------------
-- function init_tableView
-------------------------------------
function UI_PaymentShop:init_tableView()
    local node = self.vars['tabListNode']
    --node:removeAllChildren()

    local l_item_list = self:getPaymentShopTabList()

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(220, 110 + 5)
    require('UI_PaymentShopTabButton')
    table_view:setCellUIClass(UI_PaymentShopTabButton)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    -- 테이블 뷰 아이템 바로 생성하고 정렬할 경우 애니메이션이 예쁘지 않음.
    -- 애니메이션 생략하고 바로 정렬하게 수정
    local function sort_func()
        table.sort(table_view.m_itemList, function(a, b)
            local a_struct = a['data']
            local b_struct = b['data']

            local a_category_priority = a_struct:getCategoryPriority()
            local b_category_priority = b_struct:getCategoryPriority()

            if (a_category_priority == b_category_priority) then
                return a_struct:getUIPriority() > b_struct:getUIPriority()
            else
                return a_category_priority > b_category_priority 
            end
        end)
    end
    table_view:setItemList3(l_item_list, sort_func)

    self.m_tableView = table_view
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_PaymentShop:initTab()
    local vars = self.vars

    self.m_lContainerForEachType = {}

    local initial_tab = nil
    for i,v in pairs(self.m_tableView.m_itemList) do
        local struct = v['data'] -- StructPaymentShopTab
        local type = struct.m_uniqueKey
        local ui = v['ui'] or v['generated_ui']

        local continer_node = cc.Node:create()
        continer_node:setDockPoint(cc.p(0.5, 0.5))
        continer_node:setAnchorPoint(cc.p(0.5, 0.5))
        vars['contentNode']:addChild(continer_node)
        self.m_lContainerForEachType[type] = continer_node
        self:addTab(type, ui.vars['listBtn'], continer_node, ui.vars['selectSprite'])

        if (not initial_tab) then
            initial_tab = type
        end
    end

    if (not self:checkNotiList()) then
        self:setTab(initial_tab)
    end
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_PaymentShop:onChangeTab(tab, first)
    --전면 웹뷰가 아닌 부분 웹뷰일때는 방송, 채팅 꺼줌
    do
        local enable = (tab ~= 'notice') and (tab ~= 'highbrow_shop')
        -- 공지, 하이브로 상점
        g_topUserInfo:setEnabledBraodCast(enable)
    end

    if first then
        local item = self.m_tableView:getItem(tab)
        local struct = item['data'] -- StructPaymentShopTab

        local container = self.m_lContainerForEachType[tab]
        local ui = struct:makeTabContentUI() --self:makeEventPopupTab(tab)
        if ui then
            container:addChild(ui.root)
        end

        if (not self.m_mTabUI) then
            self.m_mTabUI = {}
            self.m_mTabUI[tab] = ui
        end
    else
        if (self.m_mTabUI[tab]) then
            --self.m_mTabUI[tab]:onEnterTab()
        end
    end
    
    --[[
    local item = self.m_tableView:getItem(tab)
    if item and item['data'] then
        item['data'].m_hasNoti = false
    end
    --]]
end

-------------------------------------
-- function onFocus
-------------------------------------
function UI_PaymentShop:onFocus()
    --self:refresh_PurchasePointTab()
end

-------------------------------------
-- function refresh_PurchasePointTab
-------------------------------------
function UI_PaymentShop:refresh_PurchasePointTab()
    -- 누적 결제의 경우, 패키지로 들어가 상품 구매했을 때 갱신 필요
    for tab, ui in pairs(self.m_mTabUI) do
        if pl.stringx.startswith(tab, 'purchase_point') then
            self.m_mTabUI[tab]:refresh()
        end
    end
end
-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_PaymentShop:click_exitBtn()
    if (not self:checkNotiList()) then
        self:close()

        -- 노티 정보를 갱신하기 위해서 호출
        g_highlightData:setDirty(true)

        -- 방송 활성화
        g_topUserInfo:setEnabledBraodCast(true)

        -- 운영공지 활성화
        g_broadcastManager:setEnableNotice(true) 
    end
end

-------------------------------------
-- function checkNotiList
-------------------------------------
function UI_PaymentShop:checkNotiList()
    if (not self.m_noti) then 
        return 
    end

    for i,v in pairs(self.m_tableView.m_itemList) do
        local type = v['data'].m_type

        if v['data'].m_hasNoti then
            self:setTab(type)
            self.m_tableView:relocateContainerFromIndex(i, true)
            return true
        end

        local ui = v['ui'] or v['generated_ui']
        if ui then
            local is_noti = v['data'].m_hasNoti
            ui.vars['notiSprite']:setVisible(is_noti)
        end
    end

    return false
end

--@CHECK
UI:checkCompileError(UI_PaymentShop)
