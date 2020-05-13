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
-- @param t_data table_supply에서 한 행
-------------------------------------
function UI_SupplyProductListItem:initUI(t_data)
    local vars = self.vars


    -- StructProduct
    local struct_product = g_shopDataNew:getTargetProduct(t_data['product_id'])
    local desc = struct_product:getDesc()
    

    vars['itemLabel']:setString(Str(t_data['t_name']))
    vars['totalRewardLabel']:setString(Str(desc))

    local period = t_data['period']
    local str = Str('유효 기간 : {1}', period)
    vars['periodLabel']:setString(str)


    vars['priceLabel']:setString(struct_product:getPriceStr())
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