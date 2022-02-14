local PARENT = UI_Package_LevelUp_01

-------------------------------------
-- class UI_Package_LevelUp_02
-------------------------------------
UI_Package_LevelUp_02 = class(PARENT,{
    })
    
-------------------------------------
-- function init
-------------------------------------
function UI_Package_LevelUp_02:init(struct_product, is_popup)
end

-------------------------------------
-- function initUISetting
-------------------------------------
function UI_Package_LevelUp_02:initUISetting()
    local vars = self:load('package_levelup_02.ui')
    if (self.m_isPopup) then
        UIManager:open(self, UIManager.POPUP)
        -- 백키 지정
        g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_Package_LevelUp_02')
    end
    self.m_productId = LEVELUP_PACKAGE_2_PRODUCT_ID
end
