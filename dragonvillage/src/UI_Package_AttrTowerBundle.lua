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
function UI_Package_AttrTowerBundle:init(attr)
    
    -- 패키지 탭에서 누르는 경우 시험의 탑 정보가 저장되어 있지 않을 수 있기 때문에
    -- 정보를 받아오고 UI를 설정해야 함
    local function finish_cb()
        local ui_name = 'package_attr_tower_' .. attr .. '_total.ui'
        local vars = self:load(ui_name)
    
        UIManager:open(self, UIManager.POPUP)
        -- 백키 지정
        g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_Package_AttrTowerBundle')

	    -- @UI_ACTION
        self:doActionReset()
        self:doAction(nil, false)

        self.m_lProductIdList = g_attrTowerPackageData:getProductIdList(attr)
        self.m_lItemUI= {}

        self:initUI()
	    self:initButton()
        self:refresh()
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
