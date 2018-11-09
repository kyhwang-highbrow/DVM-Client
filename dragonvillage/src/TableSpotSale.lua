local PARENT = TableClass

-------------------------------------
-- class TableSpotSale
-- @breif ��¦ ���� ��ǰ
-------------------------------------
TableSpotSale = class(PARENT, {
    })

local THIS = TableSpotSale

-- column
-- id	priority	product_id	item	condition	user_lv	cooldown	r_desc	ui_idx

-------------------------------------
-- function init
-------------------------------------
function TableSpotSale:init()
    self.m_tableName = 'table_spot_sale'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getSortedSpotSaleList
-- @brief priority���� ���� ������ ���ĵ� table_spot_sale
-------------------------------------
function TableSpotSale:getSortedSpotSaleList()
    if (self == THIS) then
        self = THIS()
    end

    local table_spot_sale = self.m_orgTable

    -- ������ ���� list���·� ��ȯ
    local l_spot_sale = table.MapToList(table_spot_sale)

    -- priority�� ���� ������ ����
	function sortByPriority(a, b)
		return a['priority'] < b['priority']
	end
	table.sort(l_spot_sale, sortByPriority)
	return l_spot_sale
end

-------------------------------------
-- function getItemID
-- @brief ��¦ ���� ��ǰ�� ��� ������ (���̾�, ���, ���� ���� item_id)
-------------------------------------
function TableSpotSale:getItemID(spot_sale_id)
    if (self == THIS) then
        self = THIS()
    end

    return self:getValue(spot_sale_id, 'item')
end

-------------------------------------
-- function getCondition
-- @brief ��¦ ���� ��ǰ �ߵ� ���� (�� ������ ���� ��� ��ǰ �ߵ�)
-------------------------------------
function TableSpotSale:getCondition(spot_sale_id)
    if (self == THIS) then
        self = THIS()
    end

    return self:getValue(spot_sale_id, 'condition')
end

-------------------------------------
-- function getRequiredLevel
-- @brief ��¦ ���� ��ǰ �ߵ� �ʿ� ����
-------------------------------------
function TableSpotSale:getRequiredLevel(spot_sale_id)
    if (self == THIS) then
        self = THIS()
    end

    return self:getValue(spot_sale_id, 'user_lv')
end

-------------------------------------
-- function getProductID
-- @brief ��¦ ���� ��ǰ�� product_id
-------------------------------------
function TableSpotSale:getProductID(spot_sale_id)
    if (self == THIS) then
        self = THIS()
    end

    return self:getValue(spot_sale_id, 'product_id')
end