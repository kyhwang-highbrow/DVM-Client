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
function UI_Package_AttrTower:init(bundle_ui, product_id, is_popup)
    self.m_bundleUI = bundle_ui
    self.m_productInfo = g_attrTowerPackageData:getProductInfo(product_id)

    local attr = self.m_productInfo['attr']

    local ui_name = 'package_attr_tower_' .. attr .. '.ui'

    local vars = self:load(ui_name)

    -- 팝업인 경우에
    if (is_popup == true) then
        UIManager:open(self, UIManager.POPUP)
        -- 백키 지정
        g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_Package_AttrTower')
    end

    vars['closeBtn']:setVisible(is_popup)

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
	self:initButton()
    self:refresh_productInfo()
        
    -- 상품 판매 남은 시간에 따라 시간 표시
    self:setLimit()

    -- 패키지 탭에서 누르는 경우 시험의 탑 정보가 저장되어 있지 않을 수 있기 때문에
    -- 정보를 받아오고 UI를 설정해야 함
    local function finish_cb()
        self:init_tableView()
    end

    if (attr ~= g_attrTowerData:getSelAttr()) then
        g_attrTowerData:request_attrTowerInfo(attr, nil, finish_cb)
    
    else
        finish_cb()
    end
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

    cca.pickMePickMe(vars['arrowSprite'], 20)

    -- 상품 합산 계산해서 텍스트 출력하기
    self:initItemText()
end

-------------------------------------
-- function setLimit
-------------------------------------
function UI_Package_AttrTower:setLimit()
    local vars = self.vars
    local product_data = self.m_productInfo
    local product_id = product_data['product_id']
    local struct_product = g_shopData:getTargetProduct(product_id)

    if (vars['limitNode'] == nil) then
        return
    elseif (vars['limitMenu'] == nil) then
        return
    elseif (vars['timeNode'] == nil) then
        return
    end
    
    local is_limit = false
    local remain_time

    -- 현재 판매중인 경우에만 time limit 보여주기
    if (vars['limitNode']) and (struct_product ~= nil) then
        remain_time = struct_product:getTimeRemainingForEndOfSale() * 1000 -- milliseconds로 변경
        local day = math.floor(remain_time / 86400000)
        local can_buy = struct_product:isItBuyable()
        -- 구매 횟수가 남아있고, 판매 기간이 조금 남은 경우
        if (day < 2) and (can_buy) then
            is_limit = true
        end
    end

    if (is_limit) then
        -- 한정 표시
        vars['limitNode']:setVisible(true)
        vars['limitMenu']:setVisible(true)
        vars['limitNode']:runAction(cca.buttonShakeAction(3, 1)) 
        
        local desc_time = datetime.makeTimeDesc_timer_filledByZero(remain_time, false) -- param : milliseconds, from_day
        
        -- 남은 시간 이미지 텍스트로 보여줌
        local remain_time_label = cc.Label:createWithBMFont('res/font/tower_score.fnt', desc_time)
        remain_time_label:setAnchorPoint(cc.p(0.5, 0.5))
        remain_time_label:setDockPoint(cc.p(0.5, 0.5))
        remain_time_label:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        remain_time_label:setAdditionalKerning(0)
        vars['remainLabel'] = remain_time_label
        vars['timeNode']:addChild(remain_time_label)

        self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)

    else
        vars['limitMenu']:setVisible(false)
        vars['limitNode']:setVisible(false)    
    end
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
    
    local function sort_func(a, b)
        return a['item_id'] > b['item_id']
    end

    table.sort(total_item_list, sort_func)

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
    
    --vars['allReceiveBtn']:setVisible(false)
    --vars['readyBtn']:setVisible(false)
    --if (g_attrTowerPackageData:isVisible_attrTowerPackNoti({product_id})) then
        --vars['allReceiveBtn']:setVisible(true)
    --else
        --vars['readyBtn']:setVisible(true)
    --end

    local node = vars['productNode']
    if (g_attrTowerPackageData:isActive(product_id)) then
        node = vars['productNodeLong']
        vars['productNode']:setVisible(false)
        vars['productNodeLong']:setVisible(true)
    else
        vars['productNode']:setVisible(true)
        vars['productNodeLong']:setVisible(false)
    end

    local bundle_ui = self.m_bundleUI

    local function make_func(data)
        local ui = UI_Package_AttrTowerListItem(bundle_ui, product_id, data)
        return ui
    end

    node:removeAllChildren()
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(440, 80+5)
    table_view:setCellUIClass(make_func)
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
    --local lv, idx = g_levelUpPackageDataOld:getFocusRewardLevel(self.m_productId)
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
    -- vars['allReceiveBtn']:registerScriptTapHandler(function() self:click_allReceiveBtn() end)
    -- vars['readyBtn']:registerScriptTapHandler(function() self:click_allReceiveBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)

    local attr = self.m_productInfo['attr']
    local product_id_list = g_attrTowerPackageData:getProductIdList(attr)
    if (table.count(product_id_list) > 1) then
        vars['totalBtn']:registerScriptTapHandler(function() self:click_totalBtn() end)
    else
        vars['totalBtn']:setVisible(false)
    end
end

-------------------------------------
-- function refresh_productInfo
-------------------------------------
function UI_Package_AttrTower:refresh_productInfo()
    local vars = self.vars
    local product_data = self.m_productInfo
    local product_id = product_data['product_id']
    local struct_product = g_shopData:getTargetProduct(product_id)

    if (g_attrTowerPackageData:isActive(product_id)) then
        vars['completeNode']:setVisible(true)
        vars['contractBtn']:setVisible(false)
        vars['buyBtn']:setVisible(false)
        --vars['allReceiveBtn']:setVisible(false)
        --vars['readyBtn']:setVisible(false)
    else
        vars['completeNode']:setVisible(false)
        vars['buyBtn']:setVisible(true)
        --vars['allReceiveBtn']:setVisible(false)
        --vars['readyBtn']:setVisible(false)
    end

    -- 구매 제한
    if vars['buyLabel'] then
        -- 판매중인 경우
        if (struct_product ~= nil) then
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
        
        -- 판매 종료된 경우
        else
            vars['buyLabel']:setString('')
            vars['buyBtn']:setVisible(false)
        end
    end
	
    -- 가격
    if (vars['priceLabel']) and (struct_product ~= nil)then
	    local price = struct_product:getPriceStr()
        vars['priceLabel']:setString(price)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Package_AttrTower:refresh()
    if (self.m_bundleUI) then
        self.m_bundleUI:refresh()
    end
    
    self:init_tableView()

    self:refresh_productInfo()
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_Package_AttrTower:click_buyBtn()
	local product_info = self.m_productInfo
    local product_id = product_info['product_id']
    local struct_product = g_shopData:getTargetProduct(product_id)

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
        UIManager:toastNotificationRed(Str('수령할 수 있는 아이템이 없습니다.')) 
        return
    end

    local function cb_func(ret)
        self:init_tableView()

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
        local attr = self.m_productInfo['attr']
        local product_id_list = g_attrTowerPackageData:getProductIdList(attr)
        UI_Package_AttrTowerBundle(attr)
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

-------------------------------------
-- function update
-------------------------------------
function UI_Package_AttrTower:update(dt)
    local vars = self.vars
    if (not vars['remainLabel']) then
        return
    end
    
    local product_data = self.m_productInfo
    local product_id = product_data['product_id']
    local struct_product = g_shopData:getTargetProduct(product_id)

    if (struct_product ~= nil) then
        local remain_time = struct_product:getTimeRemainingForEndOfSale() * 1000 -- milliseconds로 변경
        local desc_time = datetime.makeTimeDesc_timer_filledByZero(remain_time, false) -- param : milliseconds, from_day

        vars['remainLabel']:setString(desc_time)
    end
end