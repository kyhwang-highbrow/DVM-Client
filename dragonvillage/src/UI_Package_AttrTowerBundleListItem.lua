local PARENT = UI

-------------------------------------
-- class UI_Package_AttrTowerBundleListItem
-------------------------------------
UI_Package_AttrTowerBundleListItem = class(PARENT,{
        m_bundleUI = 'UI_Package_AttrTowerBundle',
        m_productInfo = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Package_AttrTowerBundleListItem:init(bundle_ui, product_id)
    local vars = self:load('package_attr_tower_total_item.ui')

	-- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self.m_bundleUI = bundle_ui
    self.m_productInfo = g_attrTowerPackageData:getProductInfo(product_id)

    self:initUI()
	self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Package_AttrTowerBundleListItem:initUI()
    local vars = self.vars
    local product_info = self.m_productInfo

    local challenge_floor = g_attrTowerData:getChallengingFloor()
    local high_floor = challenge_floor - 1
    local start_floor = product_info['start_floor']
    if (start_floor <= high_floor) then
        vars['readyBtn']:setVisible(true)
    end

    self:initItemCard()
end

-------------------------------------
-- function initItemCard
-------------------------------------
function UI_Package_AttrTowerBundleListItem:initItemCard()
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

    for idx, item_info in ipairs(total_item_list) do
        local node = vars['itemNode' .. idx]
        if (node ~= nil) then
            local item_id = item_info['item_id']
            local item_count = item_info['count']
            local item_ui = UI_ItemCard(item_id, item_count)
            node:addChild(item_ui.root)
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Package_AttrTowerBundleListItem:initButton()
    local vars = self.vars

    vars['readyBtn']:registerScriptTapHandler(function() self:click_readyBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Package_AttrTowerBundleListItem:refresh()
    
end


-------------------------------------
-- function click_readyBtn
-------------------------------------
function UI_Package_AttrTowerBundleListItem:click_readyBtn()
    require('UI_Package_AttrTower')
    local bundle_ui = self.m_bundleUI
	local product_info = self.m_productInfo
    local product_id = product_info['product_id']

    local ui = UI_Package_AttrTower(bundle_ui, product_id)
end