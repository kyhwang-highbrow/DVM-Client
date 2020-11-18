local PARENT = UI

-------------------------------------
-- class UI_Package_AttrTowerBundle
-------------------------------------
UI_Package_AttrTowerBundle = class(PARENT,{
        m_lProductIdList = 'list',
        m_lItemUI = 'list',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Package_AttrTowerBundle:init(product_id_list)
    local vars = self:load('package_attr_tower_fire_total.ui')
    
    UIManager:open(self, UIManager.POPUP)
    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_Package_AttrTowerBundle')

	-- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self.m_lProductIdList = product_id_list
    self.m_lItemUI= {}

    self:initUI()
	self:initButton()
    self:refresh()
end


-------------------------------------
-- function initUI
-------------------------------------
function UI_Package_AttrTowerBundle:initUI()
    require('UI_Package_AttrTowerBundleListItem')
    local vars = self.vars

    local product_id_list = self.m_lProductIdList
    for idx, product_id in ipairs(product_id_list) do
        local node = vars['itemNode' .. idx]
        if (node ~= nil) then
            local item_ui = UI_Package_AttrTowerBundleListItem(self, product_id)
            node:addChild(item_ui.root)
            table.insert(self.m_lItemUI, item_ui)    
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Package_AttrTowerBundle:initButton()
    local vars = self.vars

    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Package_AttrTowerBundle:refresh()
    local item_ui_list = self.m_lItemUI
    
    for i, item_ui in ipairs(item_ui_list) do
        item_ui:refresh()
    end
end
