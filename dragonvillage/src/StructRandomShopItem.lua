local PARENT = Structure

-------------------------------------
-- class StructRandomShopItem
-------------------------------------
StructRandomShopItem = class(PARENT, {
        pid = 'number', -- table_random_shop_list의 pid 값
        item_id = 'number',
        count = 'number',
        sale = 'number',
        stock = 'number',
        price_1 = 'number',
        price_type_1 = 'string',
        discounted_price_1 = 'number',

        price_2 = 'number',
        price_type_2 = 'string',
        discounted_price_2 = 'number',

        rune = 'StructRuneObject',

        product_idx = 'number',
    })

local THIS = StructRandomShopItem

-------------------------------------
-- function init
-------------------------------------
function StructRandomShopItem:init(data)
    if data then
        self:applyTableData(data)
    end
end

-------------------------------------
-- function applyTableData
-- @breif 단순 데이터 table에서 struct로 맴버 변수를 설정하는 함수
-------------------------------------
function StructRandomShopItem:applyTableData(data)
    -- 서버에서 key값을 줄여서 쓴 경우가 있어서 변환해준다
    local replacement = {}
    replacement['itemid'] = 'item_id'

	-- 구조를 살짝 바꿔준다
    for i,v in pairs(data) do
        local key = replacement[i] and replacement[i] or i
        self[key] = v
    end
end

-------------------------------------
-- function getClassName
-------------------------------------
function StructRandomShopItem:getClassName()
    return 'StructRandomShopItem'
end

-------------------------------------
-- function getThis
-------------------------------------
function StructRandomShopItem:getThis()
    return THIS
end

-------------------------------------
-- function isRuneItem
-------------------------------------
function StructRandomShopItem:isRuneItem()
    return (self['rune'] ~= nil) and true or false
end

-------------------------------------
-- function isRelationItem
-------------------------------------
function StructRandomShopItem:isRelationItem()
    local item_id = self:getItemID()
    local item_type = TableItem:getItemType(item_id)
    if (item_type == 'relation_point') then
        return true
    end

    return false
end

-------------------------------------
-- function isSale
-------------------------------------
function StructRandomShopItem:isSale()
    return (self:getSaleValue() > 0) and true or false
end

-------------------------------------
-- function isBuyable
-- @brief 구매 가능한지
-------------------------------------
function StructRandomShopItem:isBuyable()
    return (self['stock'] > 0) and true or false
end

-------------------------------------
-- function getSaleValue
-------------------------------------
function StructRandomShopItem:getSaleValue()
    return self['sale'] 
end

-------------------------------------
-- function getCount
-------------------------------------
function StructRandomShopItem:getCount()
    return self['count'] 
end

-------------------------------------
-- function getItemID
-------------------------------------
function StructRandomShopItem:getItemID()
    return self['item_id']
end

-------------------------------------
-- function getName
-------------------------------------
function StructRandomShopItem:getName()
    return TableItem:getItemName(self['item_id'])
end

-------------------------------------
-- function getDesc
-------------------------------------
function StructRandomShopItem:getDesc()
    return TableItem:getItemDesc(self['item_id'])
end

-------------------------------------
-- function getProductIdx
-------------------------------------
function StructRandomShopItem:getProductIdx()
    return self['product_idx']
end

-------------------------------------
-- function getRuneData
-------------------------------------
function StructRandomShopItem:getRuneData()
    return StructRuneObject(self['rune'])
end

-------------------------------------
-- function getPriceInofList
-------------------------------------
function StructRandomShopItem:getPriceInofList()
    local available_cnt = 2 -- 최대 2가지 재화로 구매 가능

    local l_price_type = {} -- 재화 종류
    local l_final_price = {} -- 최종 판매 가격
    local l_origin_price = {} -- 원래 판매 가격

    local is_sale = self:isSale()
    local sale_value = self:getSaleValue()

    for i = available_cnt, 1, -1 do
        local price = self['price_'..i]
        local pirce_type = self['price_type_'..i]

        if (price ~= 0) then    
            table.insert(l_price_type, pirce_type)
            table.insert(l_origin_price, tonumber(price))
            local final_price
            if (is_sale) then
                -- final_price = comma_value(math_floor(price * (100 - sale_value)/100))
                final_price = tonumber(self['discounted_price_'..i])
            else
                final_price = tonumber(price)
            end
            table.insert(l_final_price, final_price)
        end
    end

    return l_price_type, l_final_price, l_origin_price
end

-------------------------------------
-- function getCard
-------------------------------------
function StructRandomShopItem:getCard()
    local t_sub_data

    -- 룬인 경우 능력치 표시
    if (self:isRuneItem()) then
        t_sub_data = self:getRuneData()
    end

    local item_card = UI_ItemCard(self['item_id'], self['count'], t_sub_data)
    -- 터치 불가능하게 수정
    item_card.vars['clickBtn']:setEnabled(false)

    return item_card
end