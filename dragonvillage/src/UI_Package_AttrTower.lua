local PARENT = UI

-------------------------------------
-- class UI_Package_AttrTower
-------------------------------------
UI_Package_AttrTower = class(PARENT,{
        m_bundleUI = 'UI_Package_AttrTowerBundle',
        m_productInfo = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Package_AttrTower:init(bundle_ui, product_id)
    self.m_bundleUI = bundle_ui
    self.m_productInfo = g_attrTowerPackageData:getProductInfo(product_id)

    local attr = self.m_productInfo['attr']
    local ui_name = 'package_attr_tower_' .. attr .. '.ui'

    local vars = self:load(ui_name)
    
    UIManager:open(self, UIManager.POPUP)
    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_Package_AttrTower')

	-- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
	self:initButton()
    self:init_tableView()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Package_AttrTower:initUI()
    local vars = self.vars
    
    local product_info = self.m_productInfo
    local product_id = product_info['product_id']
    local start_floor = product_info['start_floor']
    local end_floor = product_info['end_floor']

    vars['attrLabel']:setString(Str('{1}~{2}층 정복', start_floor, end_floor))

    -- 상품 스프라이트 켜기
    local sprite_idx = product_id % 10 -- product_id의 1의 자리에 따라 층 수 구분
    -- vars['' .. sprite_idx]:setVisible(true)

    -- 상품 합산 계산해서 텍스트 출력하기
    self:initItemText()
end

-------------------------------------
-- function initItemText
-------------------------------------
function UI_Package_AttrTower:initItemText()
    local vars = self.vars

    local total_item_table = {}
    local product_info = self.m_productInfo

    for floor, items_str in pairs(product_info['reward_info']) do
        reward_items_list = g_itemData:parsePackageItemStr(items_str)
        for _, v in ipairs(reward_items_list) do
            local item_id = v['item_id']
            local item_count = v['count']
            if (total_item_table[item_id] == nil) then
                total_item_table[item_id] = {['item_id'] = item_id, ['count'] = 0,}
            end
            total_item_table[item_id]['count'] = total_item_table[item_id]['count'] + item_count
        end
    end

    local total_item_list = table.MapToList(total_item_table)

    local total_item_text = ''
    
    for idx, item_info in ipairs(total_item_list) do
        local item_id = item_info['item_id']
        local item_count = item_info['count']
        local item_name = TableItem:getItemName(item_id)
        local item_text = item_name .. ' ' .. Str('{1}개', comma_value(item_count))
        
        if (total_item_text ~= '') then
            total_item_text = total_item_text .. '\n'
        end
        
        total_item_text = total_item_text .. item_text
    end

     vars['itemLabel']:setString(total_item_text)
end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_Package_AttrTower:init_tableView()
    require('UI_Package_AttrTowerListItem')

    local vars = self.vars
    local product_info = self.m_productInfo
    local product_id = product_info['product_id']
    
    local node = vars['productNode']
    if (g_attrTowerPackageData:isActive(product_id)) then
        node = vars['productNodeLong']
        vars['productNode']:setVisible(false)
        vars['productNodeLong']:setVisible(true)
    else
        vars['productNode']:setVisible(true)
        vars['productNodeLong']:setVisible(false)
    end

    node:removeAllChildren()
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(440, 80+5)
    table_view:setCellUIClass(UI_Package_AttrTowerListItem)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    table_view:makeDefaultEmptyDescLabel('')

    local item_list = self:getItemList()
    table_view:setItemList(item_list)

    do -- 정렬
        local function sort_func(a, b)
            local a_value = a['data']['floor']
            local b_value = b['data']['floor']
            return a_value < b_value
        end

        table.sort(table_view.m_itemList, sort_func)
    end

    ---- 보상 받기 가능한 idx로 이동
    --local lv, idx = g_levelUpPackageData:getFocusRewardLevel(self.m_productId)
    --if lv then
        --table_view:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
        --table_view:relocateContainerFromIndex(idx, false)
    --end
end

-------------------------------------
-- function getItemList
-------------------------------------
function UI_Package_AttrTower:getItemList()
    local product_info = self.m_productInfo
    local product_id = product_info['product_id']
    local reward_info_table = product_info['reward_info']

    local item_list = {}    
    for floor, reward_info in pairs(reward_info_table) do
        local item_info = {['product_id'] = product_id, ['floor'] = floor, ['reward_info'] = reward_info, }
        table.insert(item_list, item_info)
    end
    
    return item_list
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Package_AttrTower:initButton()
    local vars = self.vars

    vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
    vars['allReceiveBtn']:registerScriptTapHandler(function() self:click_allReceiveBtn() end)
    vars['totalBtn']:registerScriptTapHandler(function() self:click_totalBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Package_AttrTower:refresh()
    if (self.m_bundleUI) then
        self.m_bundleUI:refresh()
    end
    
    self:init_tableView()

    local vars = self.vars
    local product_data = self.m_productInfo
    local product_id = product_data['product_id']
    local struct_product = g_shopDataNew:getTargetProduct(product_id)

    if (g_attrTowerPackageData:isActive(product_id)) then
        vars['completeNode']:setVisible(true)
        vars['contractBtn']:setVisible(false)
        vars['buyBtn']:setVisible(false)
    else
        vars['completeNode']:setVisible(false)
        vars['buyBtn']:setVisible(true)
    end

    -- 모두 수령
    if (g_attrTowerPackageData:isVisible_attrTowerPackNoti({product_id})) then
        vars['allReceiveBtn']:setEnabled(true)
        --vars['allReceiveBtn']:setTextColor(cc.c4b(0, 0, 0, 255))
    else
        vars['allReceiveBtn']:setEnabled(false)
        --vars['allReceiveBtn']:setTextColor(cc.c4b(240, 215, 159, 255))
    end

    -- 구매 제한
    if vars['buyLabel'] then
        local str = struct_product:getMaxBuyTermStr()
        -- 구매 가능/불가능 텍스트 컬러 변경
        local is_buy_all = struct_product:isBuyAll()
        local color_key = is_buy_all and '{@impossible}' or '{@available}'
        local rich_str = color_key .. str
        vars['buyLabel']:setString(rich_str)
        
        -- 구매 불가능할 경우 '구매완료' 출력
        if (vars['completeNode']) then
            vars['completeNode']:setVisible(is_buy_all)
        end
    end
	
    -- 가격
    if vars['priceLabel'] then
	    local price = struct_product:getPriceStr()
        vars['priceLabel']:setString(price)
    end
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_Package_AttrTower:click_buyBtn()
	local product_info = self.m_productInfo
    local product_id = product_info['product_id']
    local struct_product = g_shopDataNew:getTargetProduct(product_id)

    if (not struct_product) then
        return
    end

	local function cb_func(ret)
        -- 아이템 획득 결과창
        ItemObtainResult_Shop(ret)

        -- 갱신
        self:request_serverInfo()
	end

	struct_product:buy(cb_func)
end

-------------------------------------
-- function click_allReceiveBtn
-------------------------------------
function UI_Package_AttrTower:click_allReceiveBtn()
    local product_info = self.m_productInfo
    local product_id = product_info['product_id']

    -- 받을 게 없다면
    local b_avail_get = g_attrTowerPackageData:isVisible_attrTowerPackNoti({product_id})
    if (not b_avail_get) then
        UIManager:toastNotificationRed(Str('이미 받을 수 있는 보상을 모두 수령했습니다.')) 
        return
    end

    local function cb_func(ret)
        self:refresh()

        -- 아이템 획득 결과창
        ItemObtainResult_Shop(ret)
    end

    g_attrTowerPackageData:request_attrTowerPackRewardAll(product_id, cb_func)
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_Package_AttrTower:click_closeBtn()
    local bundle_ui = self.m_bundleUI
    if (bundle_ui ~= nil) then
        bundle_ui:close()
    end

    self:close()
end

-------------------------------------
-- function click_totalBtn
-------------------------------------
function UI_Package_AttrTower:click_totalBtn()
    local bundle_ui = self.m_bundleUI
    if (bundle_ui == nil) then
        require('UI_Package_AttrTowerBundle')
        local attr = g_attrTowerData:getSelAttr()
        local product_id_list = g_attrTowerPackageData:getProductIdList(attr)
        UI_Package_AttrTowerBundle(product_id_list, true)
    end

    self:close()
end

-------------------------------------
-- function request_serverInfo
-------------------------------------
function UI_Package_AttrTower:request_serverInfo()
    local function cb_func()
        self:refresh()
    end

    local product_data = self.m_productInfo
    local product_id = product_data['product_id']

    g_attrTowerPackageData:request_attrTowerPackInfo(product_id, cb_func)
end