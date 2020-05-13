local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_SupplyProductListItem
-------------------------------------
UI_SupplyProductListItem = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_SupplyProductListItem:init(t_data)
	-- UI load
	local ui_name = 'supply_product_list_item.ui' 
	self:load(ui_name)

	-- initialize
    self:initUI(t_data)
    self:initButton()
    self:refresh(t_data)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_SupplyProductListItem:initUI(t_data)
    local vars = self.vars

    vars['itemLabel']:setString(Str(t_data['t_name']))
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SupplyProductListItem:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SupplyProductListItem:refresh(t_data)
end