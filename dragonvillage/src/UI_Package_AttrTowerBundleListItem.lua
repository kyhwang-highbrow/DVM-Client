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
    local start_floor = product_info['start_floor']
    local end_floor = product_info['end_floor']
    
    vars['attrLabel']:setString(Str('{1}~{2}층 정복', start_floor, end_floor))

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

    local function sort_func(a, b)
        return a['item_id'] > b['item_id']
    end

    table.sort(total_item_list, sort_func)

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
    vars['completeBtn']:registerScriptTapHandler(function() self:click_readyBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Package_AttrTowerBundleListItem:refresh()
    local vars = self.vars
    local product_info = self.m_productInfo
    local product_id = product_info['product_id']

    vars['notiSprite']:setVisible(false)
    vars['completeSprite']:setVisible(false)
    vars['lockSprite']:setVisible(false)
    vars['readyBtn']:setVisible(false)
    vars['completeBtn']:setVisible(false)

    do -- 상태에 따른 버튼 변화
        -- 구입한 상태
        if (g_attrTowerPackageData:isActive(product_id)) then
            vars['completeSprite']:setVisible(true)
            
            -- 모든 상품을 수령한 상태
            if (g_attrTowerPackageData:availReceive(product_id)) then
                vars['completeBtn']:setVisible(true)

            else
                vars['readyBtn']:setVisible(true)

                -- 수령할 아이템이 존재하는 상태
                if (g_attrTowerPackageData:isVisible_attrTowerPackNoti({product_id})) then
                    vars['notiSprite']:setVisible(true)
                end
            end
 
        -- 구입 안한 상태
        else
            local challenge_floor = g_attrTowerData:getChallengingFloor()
            local start_floor = product_info['start_floor']
            local end_floor = product_info['end_floor']
        
            -- 패키지 확인 가능한 상태
            if (start_floor <= challenge_floor) then
                vars['readyBtn']:setVisible(true)
                        
            else
                vars['lockSprite']:setVisible(true)
            end
        end
    end
end


-------------------------------------
-- function click_readyBtn
-------------------------------------
function UI_Package_AttrTowerBundleListItem:click_readyBtn()
    require('UI_Package_AttrTower')
    local bundle_ui = self.m_bundleUI
	local product_info = self.m_productInfo
    local product_id = product_info['product_id']

    local ui = UI_Package_AttrTower(bundle_ui, product_id, true)
end