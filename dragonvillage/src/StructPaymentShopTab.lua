-------------------------------------
-- class StructPaymentShopTab
-- @brief 현금 상점의 탭 구성 정보를 관리하는 구조체
-------------------------------------
StructPaymentShopTab = class({
        m_uniqueKey = 'string',
        m_displayName = 'string',
        m_uiPriority = 'number',
        m_iconRes = 'string',
        m_funcGetBadgeCount = 'number function()',
        m_funcMakeTabContent = 'UI function()',

        --m_type = 'string',
        --m_sortIdx = 'number',
        --m_eventData = 'map',
        --m_hasNoti = '',
    })

-------------------------------------
-- function init
-------------------------------------
function StructPaymentShopTab:init()
end

-------------------------------------
-- function getDisplayName
-------------------------------------
function StructPaymentShopTab:getDisplayName()
	return self.m_displayName or ''
end

-------------------------------------
-- function getTabIcon
-- @return Animator
-------------------------------------
function StructPaymentShopTab:getTabIcon()
    local file_name = self.m_iconRes

    if (file_name and (file_name ~= '')) then
        local animator = MakeAnimator(file_name)
        return animator
    end
    return nil
end

-------------------------------------
-- function getBadgeCount
-------------------------------------
function StructPaymentShopTab:getBadgeCount()
    local count = 0

    if self.m_funcGetBadgeCount then
        count = self.m_funcGetBadgeCount()
    end

    return count
end

-------------------------------------
-- function getUIPriority
-------------------------------------
function StructPaymentShopTab:getUIPriority()
    return self.m_uiPriority
end

-------------------------------------
-- function makeTabContentUI
-------------------------------------
function StructPaymentShopTab:makeTabContentUI()
    if self.m_funcMakeTabContent then
        return self.m_funcMakeTabContent()
    end

    return nil
end

-------------------------------------
-- function Create
-------------------------------------
function StructPaymentShopTab:Create(unique_key, display_name, ui_priority, icon_res, func_get_badge_count, func_make_tab_content)
    local struct_payment_shop_tab = StructPaymentShopTab()
    struct_payment_shop_tab.m_uniqueKey = unique_key
    struct_payment_shop_tab.m_displayName = display_name
    struct_payment_shop_tab.m_uiPriority = ui_priority
    struct_payment_shop_tab.m_iconRes = icon_res
    struct_payment_shop_tab.m_funcGetBadgeCount = func_get_badge_count
    struct_payment_shop_tab.m_funcMakeTabContent = func_make_tab_content

    return struct_payment_shop_tab
end
