local PARENT = UI_Package_LevelUp_01
-------------------------------------
-- class UI_Package_LevelUp_03
-------------------------------------
UI_Package_LevelUp_03 = class(PARENT,{
    })
    
-------------------------------------
-- function init
-------------------------------------
function UI_Package_LevelUp_03:init(struct_product, is_popup)
end

-------------------------------------
-- function initUISetting
-------------------------------------
function UI_Package_LevelUp_03:initUISetting()
    local vars = self:load('package_levelup_03.ui')
    if (self.m_isPopup) then
        UIManager:open(self, UIManager.POPUP)
        -- 백키 지정
        g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_Package_LevelUp_03')
    end
    self.m_productId = LEVELUP_PACKAGE_3_PRODUCT_ID
end