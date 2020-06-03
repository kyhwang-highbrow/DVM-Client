local PARENT = Structure

-------------------------------------
-- class StructHighbrowProduct
-------------------------------------
StructHighbrowProduct = class(PARENT, {
        -- 서버에서 받는 정보
        type = '',
        name = '',
        code = '',
        game_key = '',
        done = '',

        -- 사용 안함
        cnt = '',
        limit = '',

        -- 테이블에서 받아오는 정보
        desc = '',
        res = '',  
        price_type = '',
        price_value = '',
    })

local THIS = StructHighbrowProduct

-------------------------------------
-- function init
-------------------------------------
function StructHighbrowProduct:init(data)
    self:mergeTable()
end

-------------------------------------
-- function getClassName
-------------------------------------
function StructHighbrowProduct:getClassName()
    return 'StructHighbrowProduct'
end

-------------------------------------
-- function getThis
-------------------------------------
function StructHighbrowProduct:getThis()
    return THIS
end

-------------------------------------
-- function mergeTable
-------------------------------------
function StructHighbrowProduct:mergeTable()
    local t_item = TableHighbrow:find(self:getGameKey(), self:getCode())
    
    self.desc = Str(t_item['t_desc'])
    self.res = t_item['res']
    self.price_type = t_item['price_type']
    self.price_value = t_item['price_value']
end

-------------------------------------
-- function buyProduct
-------------------------------------
function StructHighbrowProduct:buyProduct(finish_cb)
    if (not self:checkBuyable()) then
        return
    end

    local code = self:getCode()
    local game_key = self:getGameKey()

    -- 튜토리얼 보상 구매
    if (self:isTutorialProduct()) then
        g_highbrowData:request_buyHBProductTutorial(code, game_key, finish_cb)
        self.done = true

    -- 일반 상품 구매
    else
        g_highbrowData:request_buyHbProcduct(code, game_key, finish_cb)
    end
end

-------------------------------------
-- function checkBuyable
-------------------------------------
function StructHighbrowProduct:checkBuyable()
    local price_type = self['price_type']
    local price_value = self['price_value']

    return UIHelper:checkPrice(price_type, price_value)
end










-------------------------------------
-- function getFullName
-------------------------------------
function StructHighbrowProduct:getFullName()
    return TableHighbrow:getFullName(self.game_key, self:getName()) 
end

-------------------------------------
-- function getName
-------------------------------------
function StructHighbrowProduct:getName()
    return Str(self.name)
end

-------------------------------------
-- function getDesc
-------------------------------------
function StructHighbrowProduct:getDesc()
    return self.desc
end

-------------------------------------
-- function getPrice
-------------------------------------
function StructHighbrowProduct:getPrice()
    return self.price_value
end

-------------------------------------
-- function getIcon
-------------------------------------
function StructHighbrowProduct:getIcon()
    return IconHelper:getIcon(self.res)
end

-------------------------------------
-- function getCode
-------------------------------------
function StructHighbrowProduct:getCode()
    return self.code
end

-------------------------------------
-- function getGameKey
-------------------------------------
function StructHighbrowProduct:getGameKey()
    return self.game_key
end

-------------------------------------
-- function isDone
-------------------------------------
function StructHighbrowProduct:isDone()
    return self.done
end

-------------------------------------
-- function isTutorialProduct
-------------------------------------
function StructHighbrowProduct:isTutorialProduct()
    return (self.type == 1)
end