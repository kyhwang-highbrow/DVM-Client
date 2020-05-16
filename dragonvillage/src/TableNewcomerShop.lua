local PARENT = TableClass

-------------------------------------
-- class TableNewcomerShop
-- @brief 초보자 선물 (신규 유저 전용 상점)
-------------------------------------
TableNewcomerShop = class(PARENT, {
    })

--{
--    "end_date":"",
--    "terms":14,
--    "ncm_id":10001,
--    "start_date":"",
--    "product_id":"120201;120202;120203;120204;120205;120206"
--}

local THIS = TableNewcomerShop

-------------------------------------
-- function init
-------------------------------------
function TableNewcomerShop:init()
    self.m_tableName = 'table_newcomer_shop'
    self.m_orgTable = TABLE:get(self.m_tableName)
end


-------------------------------------
-- function getNewcomerShopProductList
-- @brief 초보자 선물 상품 리스트 (product_id 리스트)
-- @param ncm_id number
-- @return list table(list)
-------------------------------------
function TableNewcomerShop:getNewcomerShopProductList(ncm_id)
    if (self == THIS) then
        self = THIS()
    end

    local product_id_list_str = self:getValue(ncm_id, 'product_id') or ''
    local l_product_id_str = pl.stringx.split(product_id_list_str, ';')
    local l_product_id = {}

    for i,v in ipairs(l_product_id_str) do
        l_product_id[i] = tonumber(v)
    end

    return l_product_id
end