local PARENT = TableClass

-------------------------------------
-- class TableFleaShop
-- @brief 벼룩시장 선물
-------------------------------------
TableFleaShop = class(PARENT, {
    })

--{
--    "end_date":"",
--    "terms":14,
--    "ncm_id":10001,
--    "start_date":"",
--    "product_id":"120201;120202;120203;120204;120205;120206"
--}

local THIS = TableFleaShop

-------------------------------------
-- function init
-------------------------------------
function TableFleaShop:init()
    self.m_tableName = 'table_flea_market'
    self.m_orgTable = TABLE:get(self.m_tableName)
end


-------------------------------------
-- function getFleaShopProductList
-- @brief 벼룩시장 선물 상품 리스트 (product_id 리스트)
-- @param ncm_id number
-- @return list table(list)
-------------------------------------
function TableFleaShop:getFleaShopProductList(ncm_id)
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