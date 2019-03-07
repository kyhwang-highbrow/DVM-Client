local PARENT = UI

-------------------------------------
-- class UI_Package_New_Dragon
-------------------------------------
UI_Package_New_Dragon = class(PARENT,{
        m_data = 'table',
        m_pids = 'table',

        m_package_name = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Package_New_Dragon:init(package_name, is_popup)
    self.m_package_name = package_name
    self.m_data = TablePackageBundle:getDataWithName(package_name) 
    self.m_pids = TablePackageBundle:getPidsWithName(package_name)

    local vars = self:load('package_new_dragon.ui')
    if (is_popup) then
        UIManager:open(self, UIManager.POPUP)
        -- 백키 지정
        g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_Package_New_Dragon')
    end
	
	-- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
	self:initButton(is_popup)
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Package_New_Dragon:initUI()
    local vars = self.vars

    local ui_product1 = openPackage_New_Dragon(self.m_pids[1])
    local ui_product2 = openPackage_New_Dragon(self.m_pids[2])

    vars['productNode1']:addChild(ui_product1.root)
    vars['productNode2']:addChild(ui_product2.root)
    
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Package_New_Dragon:refresh()
    
end

-------------------------------------
-- function init_tableView
-------------------------------------
function UI_Package_New_Dragon:init_tableView()
    local vars = self.vars
    
end
