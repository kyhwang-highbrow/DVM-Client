local PARENT = UI

-------------------------------------
-- class UI_Package_AttrTowerPopup
-------------------------------------
UI_Package_AttrTowerPopup = class(PARENT,{
        m_isPopup = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Package_AttrTowerPopup:init(is_popup)
    local vars = self:load('package_attr_tower.ui')
    self.m_isPopup = is_popup or false
	
	self.m_uiName = 'package_attr_tower.ui'

    if (is_popup) then
        UIManager:open(self, UIManager.POPUP)
        -- 백키 지정
        g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_Package_AttrTowerPopup')
    end

    self:initUI()
	self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Package_AttrTowerPopup:initUI()
    local vars = self.vars
    
    if (not self.m_isPopup) then
        vars['closeBtn']:setVisible(false)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Package_AttrTowerPopup:initButton()
    local vars = self.vars

    vars['buyBtn1']:registerScriptTapHandler(function() self:click_buyBtn('fire') end)
    vars['buyBtn2']:registerScriptTapHandler(function() self:click_buyBtn('water') end)
    vars['buyBtn3']:registerScriptTapHandler(function() self:click_buyBtn('earth') end)
    vars['buyBtn4']:registerScriptTapHandler(function() self:click_buyBtn('light') end)
    vars['buyBtn5']:registerScriptTapHandler(function() self:click_buyBtn('dark') end)

    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Package_AttrTowerPopup:refresh()
    local vars = self.vars

    self:refresh_packageNoti()
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_Package_AttrTowerPopup:click_buyBtn(attr)
    local huddle = g_attrTowerPackageData:getHuddleFloor(attr)
    local clear_floor = g_attrTowerData:getClearFloor()
    local product_id_list = g_attrTowerPackageData:getProductIdList(attr)

    -- 허들 이상 클리어한 경우
    local ui
    if ((table.count(product_id_list) > 1) and (clear_floor >= huddle)) then
        require('UI_Package_AttrTowerBundle')
        ui = UI_Package_AttrTowerBundle(attr)

    else 
        require('UI_Package_AttrTower')
        local first_product_id = product_id_list[1]
        ui = UI_Package_AttrTower(nil, first_product_id)
    end

    ui:setCloseCB(function() self:refresh_packageNoti() end)
end

-------------------------------------
-- function refresh_packageNoti
-------------------------------------
function UI_Package_AttrTowerPopup:refresh_packageNoti()
    local vars = self.vars

    local l_attr_list = {'fire', 'water', 'earth', 'light', 'dark'}

    -- noti
    --for i, attr in ipairs(l_attr_list) do
        --local product_id_list = g_attrTowerPackageData:getProductIdList(attr)
        --local sprite_name = ''
        --if (g_attrTowerPackageData:isVisible_attrTowerPackNoti(product_id_list)) then
            --vars[sprite_name]:setVisible(true)
        --else
            --vars[sprite_name]:setVisible(false)
        --end
    --end
end