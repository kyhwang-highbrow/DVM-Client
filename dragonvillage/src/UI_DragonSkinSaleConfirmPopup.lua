local PARENT = UI

-------------------------------------
-- class UI_DragonSkinSaleConfirmPopup
-------------------------------------
UI_DragonSkinSaleConfirmPopup = class(PARENT, {
    m_structDragonSkinSale = 'StructDragonSkinSale',
})

-------------------------------------
-- function init
-------------------------------------
function UI_DragonSkinSaleConfirmPopup:init(struct_dragon_skin_sale)
    local vars = self:load('shop_purchase_dragon_skin.ui')
    self.m_structDragonSkinSale = struct_dragon_skin_sale
    UIManager:open(self, UIManager.POPUP)

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_DragonSkinSaleConfirmPopup')

    self:initUI()
    self:initButton()
    self:refresh()

    self:doActionReset()
    self:doAction()

end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonSkinSaleConfirmPopup:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonSkinSaleConfirmPopup:initButton()
    local vars = self.vars
    -- '닫기' 버튼
	if vars['closeBtn'] then
	    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
	end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonSkinSaleConfirmPopup:refresh()   
end

-------------------------------------
-- function open
-------------------------------------
function UI_DragonSkinSaleConfirmPopup.open(struct_dragon_skin_sale)
    return UI_DragonSkinSaleConfirmPopup(struct_dragon_skin_sale)
end

--@CHECK
UI:checkCompileError(UI_DragonSkinSaleConfirmPopup)