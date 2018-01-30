local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_PackageTabButton
-------------------------------------
UI_PackageTabButton = class(PARENT, {
        m_structEventPopupTab = 'StructEventPopupTab',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_PackageTabButton:init(struct_event_popup_tab)
    self.m_structEventPopupTab = struct_event_popup_tab

    local vars = self:load('shop_package_list.ui')

    self:initUI()
    self:initButton()

    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_PackageTabButton:initUI()
    local vars = self.vars

    -- 버튼 이름
    local struct_event_popup_tab = self.m_structEventPopupTab
    local tab_btn_name = struct_event_popup_tab:getTabButtonName()
    vars['listLabel']:setString(tab_btn_name)

    -- 패키지 뱃지
    local package_name = struct_event_popup_tab.m_type
    local t_pids = TablePackageBundle:getPidsWithName(package_name)
    if (#t_pids > 0) then
        local l_item_list = g_shopDataNew:getProductList('package')
        local target_pid = tonumber(t_pids[1])
        local struct_product = l_item_list[target_pid]
        if (struct_product) then
            local badge = struct_product:makeBadgeIcon()
            if (badge) then
		        vars['badgeNode']:addChild(badge)
            end
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_PackageTabButton:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_PackageTabButton:refresh()
    local vars = self.vars
end