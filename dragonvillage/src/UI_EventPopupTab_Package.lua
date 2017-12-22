local PARENT = UI

-------------------------------------
-- class UI_EventPopupTab_Package
-------------------------------------
UI_EventPopupTab_Package = class(PARENT,{
        m_package_name = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_Package:init(package_name)
    local vars = self:load('event_shop.ui')
    self.m_package_name = package_name

    self:initUI()
	self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventPopupTab_Package:initUI()
    local vars = self.vars
	local package_name = self.m_package_name

    local is_popup = false
    local ui = PackageManager:getTargetUI(package_name, is_popup)

    if (ui) then
        local node = vars['shopNode']
        node:addChild(ui.root)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventPopupTab_Package:initButton()
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventPopupTab_Package:onEnterTab()
end
