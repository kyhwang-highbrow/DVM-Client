local PARENT = TableClass

-------------------------------------
-- class TableSpotSale
-- @breif 깜짝 할인 상품
-------------------------------------
TableSpotSale = class(PARENT, {
    })

local THIS = TableSpotSale

-- column
-- id	priority	product_id	item	condition	user_lv	cooldown	r_desc	ui_idx  on_sale

-------------------------------------
-- function init
-------------------------------------
function TableSpotSale:init()
    self.m_tableName = 'table_spot_sale' 
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getSortedSpotSaleList
-- @brief priority값이 낮은 순서로 정렬된 table_spot_sale
-------------------------------------
function TableSpotSale:getSortedSpotSaleList()
    if (self == THIS) then
        self = THIS()
    end

    local table_spot_sale = self.m_orgTable

    local t_spot_sale = {}

    -- table_spot_sale에서 start_date, end_date 값에 알맞는 상품만 판매 시작
    for pid, data in pairs(table_spot_sale) do
        if (data['start_date'] and data['end_date']) then
            local is_valid = CheckValidDateFromTableDataValue(data['start_date'], data['end_date'])
            if (is_valid == true) then
                t_spot_sale[pid] = data
            end
        end
    end

    -- 정렬을 위해 list형태로 변환
    local l_spot_sale = table.MapToList(t_spot_sale)

    -- priority가 낮은 순서로 정렬
	function sortByPriority(a, b)
		return a['priority'] < b['priority']
	end
	table.sort(l_spot_sale, sortByPriority)
	return l_spot_sale
end

-------------------------------------
-- function getItemID
-- @brief 깜짝 할인 상품의 대상 아이템 (다이아, 골드, 날개 등의 item_id)
-------------------------------------
function TableSpotSale:getItemID(spot_sale_id)
    if (self == THIS) then
        self = THIS()
    end

    return self:getValue(spot_sale_id, 'item')
end

-------------------------------------
-- function getCondition
-- @brief 깜짝 할인 상품 발동 수량 (이 값보다 적은 경우 상품 발동)
-------------------------------------
function TableSpotSale:getCondition(spot_sale_id)
    if (self == THIS) then
        self = THIS()
    end

    return self:getValue(spot_sale_id, 'condition')
end

-------------------------------------
-- function getRequiredLevel
-- @brief 깜짝 할인 상품 발동 필요 레벨
-------------------------------------
function TableSpotSale:getRequiredLevel(spot_sale_id)
    if (self == THIS) then
        self = THIS()
    end

    return self:getValue(spot_sale_id, 'user_lv')
end

-------------------------------------
-- function getProductID
-- @brief 깜짝 할인 상품의 product_id
-------------------------------------
function TableSpotSale:getProductID(spot_sale_id)
    if (self == THIS) then
        self = THIS()
    end

    return self:getValue(spot_sale_id, 'product_id')
end

-------------------------------------
-- function getBonusRate
-- @brief 깜짝 할인 상품의 보너스 비율
-------------------------------------
function TableSpotSale:getBonusRate(spot_sale_id)
    if (self == THIS) then
        self = THIS()
    end

    return self:getValue(spot_sale_id, 'bonus_rate') or 0
end

-------------------------------------
-- function getUIIdx
-- @brief 깜짝 할인 상품별 UI에서 사용하는 index
-- ex)
-- itemLabel1 -> 다이아
-- itemLabel2 -> 골드
-- itemLabel3 -> 날개
-------------------------------------
function TableSpotSale:getUIIdx(spot_sale_id)
    if (self == THIS) then
        self = THIS()
    end

    return self:getValue(spot_sale_id, 'ui_idx')
end

-------------------------------------
-- function getUIIdxList
-- @brief 깜짝 할인 상품의 ui_idx 리스트
-------------------------------------
function TableSpotSale:getUIIdxList()
    if (self == THIS) then
        self = THIS()
    end

    local ui_idx_list = {}
    local max = 0
    for i,v in pairs(self.m_orgTable) do
        local ui_idx = v['ui_idx']
        table.insert(ui_idx_list, ui_idx)

        if (max < ui_idx) then
            max = ui_idx
        end
    end

    return ui_idx_list, max
end