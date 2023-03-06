-------------------------------------
-- class StructDragonSkin
-- @instance
-------------------------------------
StructDragonSkin = class({
    bStruct = 'boolean',
    skin_id = 'number',
    did = 'number',
    priority = 'number',
    name = 'string',
    desc = 'string',
    attribute = 'string',

    res = 'string',
    res_icon = 'string',

    scale = 'number',

    cash_price = 'number',
    money_price = 'number',
    sku = 'string',

    price_dollar = 'number',
    xsolla_price_dollar = 'number',

    bUsed = 'boolean',
    saleType = 'string', -- package : 패키지 상점에서 구매
    money_product_list = 'List<StructProduct>', -- 현금 상품 리스트
    cash_product_list = 'List<StructProduct>', -- 다이아 상품 리스트

    is_default = 'boolean', -- 기본 스킨일 때만 true
})

-------------------------------------
-- function init
-------------------------------------
function StructDragonSkin:init(data)
    self.bStruct = true
    self.is_default = false

    if data then
        self:applyTableData(data)
    end
end

-------------------------------------
-- function applyTableData
-- @breif 단순 데이터 table에서 struct로 맴버 변수를 설정하는 함수
-------------------------------------
function StructDragonSkin:applyTableData(data)
    
    local replacement = {}
    replacement['skin_id'] = 'skin_id'
    replacement['did'] = 'did'
    replacement['ui_priority'] = 'priority'
    replacement['t_name'] = 'name'
    replacement['t_desc'] = 'desc'
    replacement['attribute'] = 'attribute'

    replacement['res'] = 'res'
    replacement['res_icon'] = 'res_icon'

    replacement['scale'] = 'scale'
    replacement['cash_price'] = 'cash_price'
    replacement['money_price'] = 'money_price'
    replacement['sku'] = 'sku'
    replacement['price_dollar'] = 'price_dollar'
    replacement['xsolla_price_dollar'] = 'xsolla_price_dollar'

    for i,v in pairs(data) do
        local key = replacement[i] and replacement[i] or i
        self[key] = v
    end
end

-------------------------------------
-- function isOpen
-- @brief 열려있는 스킨인지
-------------------------------------
function StructDragonSkin:isOpen()
    -- 기본 스킨은 오픈 상태
    if (self.skin_id%10 == 0) then
        return true
    end

    return g_userData:isDragonSkinOpened(self.skin_id)
end

-------------------------------------
-- function isUsed
-- @brief 사용중인 스킨인지
-------------------------------------
function StructDragonSkin:isUsed()
    local dragon_skin_map = g_dragonsData:getMyDragonsListWithSkin()

    for _,v in pairs(dragon_skin_map) do
        if v['dragon_skin'] == self.skin_id then
            return true
        end
    end

    if self:isDefaultSkin() then
        return true
    end

    return false
end

-------------------------------------
-- function isSale
-- @brief 할인중인지
-------------------------------------
function StructDragonSkin:isSale()
    return false, ''
end

-------------------------------------
-- function isLimit
-- @brief 기간한정인지 (기간한정이라면 남은 기간도 같이 반환)
-------------------------------------
function StructDragonSkin:isLimit()
    return false, ''
end

-------------------------------------
-- function isEnd
-- @brief 판매종료 (서버에서 코스튬 샵정보 안줌)
-------------------------------------
function StructDragonSkin:isEnd()
    return false
end

-------------------------------------
-- function isBuyable
-- @brief 구매가능한가
-------------------------------------
function StructDragonSkin:isBuyable()
    return (not self:isOpen()) and (not self:isEnd())
end

-------------------------------------
-- function isDragonLock
-- @brief 해당 스킨의 드래곤을 보유중인지
-------------------------------------
function StructDragonSkin:isDragonLock()
    -- local tamer_id = self:getTamerID()
    -- 기본 코스튬은 테이머 열려있지 않아도 잠금처리 안함
    if (self.skin_id == TableDragonSkin:getDefaultSkinID(self.did)) then
        return false
    end

    return not g_dragonsData:has(self.did)
end

-------------------------------------
-- function getSkinID
-------------------------------------
function StructDragonSkin:getSkinID()
    -- local dragon_idx = getDigit(self.did, 10, 2)
    -- local dragon_id = tonumber(string.format('1100%02d', dragon_idx))
	-- if (not tamer_id) then
	-- 	tamer_id = self.m_serverData:getRef('user', 'tamer')
	-- end

    return self.skin_id
end

-------------------------------------
-- function getSkinAttribute
-------------------------------------
function StructDragonSkin:getSkinAttribute()
    return self.attribute
end

-------------------------------------
-- function getDragonSkinIcon
-------------------------------------
function StructDragonSkin:getDragonSkinIcon(i)
    local path = string.gsub(self.res_icon, '#', '0' .. i)

    if string.find(path, '@') then
        path = string.gsub(path, '@', self.attribute)
    end
    -- local image = cc.Sprite:create(path)
    -- if (image) then
    --     image:setDockPoint(CENTER_POINT)
    --     image:setAnchorPoint(CENTER_POINT)
    -- end

    return path
end

-------------------------------------
-- function getDragonSkinRes
-------------------------------------
function StructDragonSkin:getDragonSkinRes()
    local res = self.res

    if string.find(res, '@') then
        res = string.gsub(res, '@', self.attribute)
    end

    return res
end

-------------------------------------
-- function getCid
-------------------------------------
function StructDragonSkin:getDid()
    return self.did
end

-------------------------------------
-- function getName
-------------------------------------
function StructDragonSkin:getName()
    return Str(self.name)
end

-------------------------------------
-- function getPrice
-------------------------------------
function StructDragonSkin:getPrice()
    return self.m_price, self.m_price_type
end

-------------------------------------
-- function isDefaultSkin
-- @brief 기본 복장인지 여부
-------------------------------------
function StructDragonSkin:isDefaultSkin()
    if self.skin_id == nil then
        return true
    end

    if self.skin_id == 0 then
        return true
    end

    return false
end

-------------------------------------
-- function makeDefaultSkin
-- @brief 기본 복장인지 여부
-------------------------------------
function StructDragonSkin:makeDefaultSkin(did)
    -- @dhkim 23.03.02 항상 스킨 리스트 첫번째엔 기본 스킨이 포함되야 한다
    local basic_data = {}
    basic_data['skin_id'] = 0
    basic_data['did'] = did
    basic_data['ui_priority'] = 99
    basic_data['t_name'] = Str('기본 스킨')
    basic_data['t_desc'] = ''
    basic_data['attribute'] = TableDragon:getValue(did, 'attr')
    basic_data['res'] = TableDragon:getValue(did, 'res')
    basic_data['res_icon'] = TableDragon:getValue(did, 'icon')
    basic_data['scale'] = 1
    basic_data['cash_price'] = 0
    basic_data['money_price'] = 0
    basic_data['sku'] = ''
    basic_data['price_dollar'] = 0
    basic_data['xsolla_price_dollar'] = 0
    
    local struct_dragon_skin = StructDragonSkin(basic_data)
    struct_dragon_skin:setDefaultStatus(true)

    return struct_dragon_skin
end

function StructDragonSkin:setDefaultStatus(isDefault)
    self.is_default = isDefault
end

-------------------------------------
-- function getDragonSkinDId
-------------------------------------
function StructDragonSkin:getDragonSkinDId()
    local skin_id = self:getSkinID()
    local did = TableDragonSkin:getDragonSkinValue('did', skin_id)
    return did
end

-------------------------------------
-- function insertDragonSkinProduct
-------------------------------------
function StructDragonSkin:insertDragonSkinProduct(struct_product)
    local price_type = struct_product:getPriceType()
    local price_type_str = string.format('%s_product_list', price_type)

    if self[price_type_str] == nil then
        self[price_type_str] = {}
    end

    table.insert(self[price_type_str], struct_product)
end

-------------------------------------
-- function isDragonSkinOwned
-------------------------------------
function StructDragonSkin:isDragonSkinOwned()
    local skin_id = self:getSkinID()
    return g_userData:isDragonSkinOpened(skin_id)
end

-------------------------------------
-- function getDragonSkinProductOriginalPriceStr
-- @brief 할인가 표기를 위한 원가 가격 스트링
-------------------------------------
function StructDragonSkin:getDragonSkinProductOriginalPriceStr(price_type)
    local skin_id = self:getSkinID()
    local t_data = {
        ['sku'] = '' ,
        ['price'] = '',
        ['price_dollar'] = '',
        ['xsolla_price_dollar'] = '',
    }

    for key_name, _ in pairs(t_data) do
        if key_name == 'price' then
            local str = string.format('%s_price', price_type)
            t_data[key_name] = TableDragonSkin:getDragonSkinValue(str, skin_id)
        else
            t_data[key_name] = TableDragonSkin:getDragonSkinValue(key_name, skin_id)
        end
    end

    t_data['price_type'] = price_type
    local struct_product = StructProduct()
    struct_product:applyTableData(t_data)
    return struct_product:getPriceStr(), struct_product:getPrice()
end

-------------------------------------
-- function getDragonSkinProductList
-------------------------------------
function StructDragonSkin:getDragonSkinProductList(price_type)
    local price_type_str = string.format('%s_product_list', price_type)
    if self[price_type_str] == nil then
        return nil
    end

    local product_list = self[price_type_str]
    return product_list
end

-------------------------------------
-- function getDragonSkinProduct
-------------------------------------
function StructDragonSkin:getDragonSkinProduct(price_type)
    local product_list = self:getDragonSkinProductList(price_type)
    if product_list == nil then
        return nil
    end

    -- 가장 싼 가격의 상품을 살 수 있도록 우선 노출시킴
    local cur_price = 0
    local result_struct_product = nil
    for _, struct_product in ipairs(product_list) do
        if cur_price == 0 or struct_product:getPrice() < cur_price  then
            cur_price = struct_product:getPrice()
            result_struct_product = struct_product
        end
    end

    return result_struct_product
end

-------------------------------------
-- function checkDragonSkinPurchaseBuyCount
-- @brief 동일한 스킨 상품들 중에 하나라도 구매했으면 구매 불가 처리
-------------------------------------
function StructDragonSkin:checkDragonSkinPurchaseBuyCount(struct_product_list)
    if struct_product_list == nil then
        return false
    end

    for _, struct_product in ipairs(struct_product_list) do
        if struct_product:isBuyAll() == true then
            return false
        end
    end

    return true
end

-------------------------------------
-- function checkDragonSkinPurchaseValidation
-- @brief 다이아, 현금 모두 구매할 수 있는 상태여야 함
-------------------------------------
function StructDragonSkin:checkDragonSkinPurchaseValidation()
    local struct_product_money_list = self:getDragonSkinProductList('money')
    -- 동일한 스킨 상품들 중에 하나라도 구매했으면 구매 불가 처리
    if self:checkDragonSkinPurchaseBuyCount(struct_product_money_list) == false then
        return false
    end

    local struct_product_cash_list = self:getDragonSkinProductList('cash')
    -- 동일한 스킨 상품들 중에 하나라도 구매했으면 구매 불가 처리    
    if self:checkDragonSkinPurchaseBuyCount(struct_product_cash_list) == false then
        return false
    end

    local count = #struct_product_money_list + #struct_product_cash_list
    if count % 2 ~= 0 then
        return false
    end

    return true
end

-------------------------------------
-- function isDragonSkinSale
-------------------------------------
function StructDragonSkin:isDragonSkinSale()
    if self:checkDragonSkinPurchaseValidation() == false then
        return false        
    end

    local struct_product = self:getDragonSkinProduct('money')
    if struct_product == nil then
        return false
    end

    if struct_product:getProductBadge() ~= 'sale' then
        return false
    end


    return true
end

-------------------------------------
-- function getUIPriority
-------------------------------------
function StructDragonSkin:getUIPriority()
    local order = 1

    local did = self:getDragonSkinDId()

    -- 보유중인 드래곤일 경우
    if g_dragonsData:getNumOfDragonsByDid(did) > 0 then
        order = order + 1000
    end

    -- 소유한 스킨일 경우
    if self:isDragonSkinOwned() == true then
        order = order - 1000
    end

    -- 구매가 가능한 상태일 경우
    if self:checkDragonSkinPurchaseValidation() == true then
        order = order + 10
    end

    return order
end