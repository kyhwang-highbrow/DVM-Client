local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_PaymentShopTabButton
-------------------------------------
UI_PaymentShopTabButton = class(PARENT, {
        m_struct = 'StructPaymentShopTab',
    })

-------------------------------------
-- function init
-- @param struct_payment_shop_tab StructPaymentShopTab
-------------------------------------
function UI_PaymentShopTabButton:init(struct_payment_shop_tab)
    self.m_struct = struct_payment_shop_tab

    local vars = self:load('patyment_shop_tab_btn.ui')

    self:initUI()
    self:initButton()

    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_PaymentShopTabButton:initUI()
    local vars = self.vars
    local struct = self.m_struct

    -- �� ��ư �̸�
    vars['nameLabel']:setString(struct:getDisplayName())

    -- ������ ����
    local animator = struct:getTabIcon()
    if (animator and animator.m_node) then
        vars['iconNode']:addChild(animator.m_node)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_PaymentShopTabButton:initButton()
    local vars = self.vars
    vars['listBtn']:registerScriptTapHandler(function() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_PaymentShopTabButton:refresh()
    local vars = self.vars

    --local struct_event_popup_tab = self.m_structEventPopupTab
    --local type = struct_event_popup_tab.m_type
    --local tab_btn_name = struct_event_popup_tab:getTabButtonName()
    --vars['eventLabel']:setString(tab_btn_name)
end