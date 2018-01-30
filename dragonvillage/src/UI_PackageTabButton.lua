local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_PackageTabButton
-------------------------------------
UI_PackageTabButton = class(PARENT, {
        m_struct_product = 'StructProduct',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_PackageTabButton:init(struct_product)
    self.m_struct_product = struct_product

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

    -- 버튼 이름 (패키지 번들 참조)
    local struct_product = self.m_struct_product
    local pid = struct_product['product_id']
    local desc = TablePackageBundle:getPackageDescWithPid(pid)
    if (desc) then
        vars['listLabel']:setString(desc)
    end

    -- 패키지 뱃지
    local badge = struct_product:makeBadgeIcon()
    if (badge) then
		vars['badgeNode']:addChild(badge)
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