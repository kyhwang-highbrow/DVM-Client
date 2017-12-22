local PARENT = UI

-------------------------------------
-- class UI_EventPopupTab_Shop
-------------------------------------
UI_EventPopupTab_Shop = class(PARENT,{
        m_structProduct = 'StructBannerData',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_Shop:init(struct_product)
    local vars = self:load('event_shop.ui')
    self.m_structProduct = struct_product

    self:initUI()
	self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventPopupTab_Shop:initUI()
    local vars = self.vars
	local struct_product = self.m_structProduct

    local is_popup = false
    local ui = PackageManager:getTargetUI(struct_product, is_popup)

    if (ui) then
        local node = vars['shopNode']
        node:addChild(ui.root)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventPopupTab_Shop:initButton()
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventPopupTab_Shop:onEnterTab()
end
