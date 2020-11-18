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
    -- 모험돌파 패키지 구매 전, 기능 설정하지않고 return UI만 출력
    --if (struct_product) then
        --self.vars['closeBtn']:setVisible(false)
        --self.vars['closeBtn']:setEnabled(false)
        --return
    --end

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

    

    --self:initUI()
	self:initButton()
    self:init_tableView()
    --self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Package_AttrTower:initUI()
    local vars = self.vars

    --vars['closeBtn']:setVisible(true)
    --vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    --vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
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
-- function initTableView
-------------------------------------
function UI_Package_AttrTower:getItemList()
    local product_info = self.m_productInfo
    local reward_info_table = product_info['reward_info']
    
    local item_list = {}    
    for floor, reward_info in pairs(reward_info_table) do
        local item_info = {['floor'] = floor, ['reward_info'] = reward_info,}
        table.insert(item_list, item_info)
    end
    
    return item_list
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Package_AttrTower:initButton()
    local vars = self.vars

    -- vars['closeBtn']:setVisible(true)
    -- vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    -- vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
     vars['totalBtn']:registerScriptTapHandler(function() self:click_bundleBtn() end)
     vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Package_AttrTower:refresh()
    self:init_tableView()

    local vars = self.vars
    local product_data = self.m_productInfo
    local product_id = product_data['product_id']
    if (g_attrTowerPackageData:isActive(product_id)) then
        --vars['completeNode']:setVisible(true)
        --vars['contractBtn']:setVisible(false)
        --vars['buyBtn']:setVisible(false)
    else
        --vars['completeNode']:setVisible(false)
        --vars['buyBtn']:setVisible(true)
    end
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_Package_AttrTower:click_buyBtn()
	local struct_product = self.m_structProduct

    if (not struct_product) then
        return
    end

	local function cb_func(ret)
        if (self.m_cbBuy) then
            self.m_cbBuy(ret)
        end

        -- 아이템 획득 결과창
        ItemObtainResult_Shop(ret)

        -- 갱신
        self:request_serverInfo()
	end

	struct_product:buy(cb_func)
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
-- function click_bundleBtn
-------------------------------------
function UI_Package_AttrTower:click_bundleBtn()
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

    g_adventureClearPackageData03:request_adventureClearInfo(product_id)
end