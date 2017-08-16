local PARENT = Structure

-------------------------------------
-- class StructHighbrowProduct
-------------------------------------
StructHighbrowProduct = class(PARENT, {
        code = '',
        cnt = '',

        type = '',
        name = '',
        limit = '',

        desc = '',
        icon = '',
        price = '',
        game_key = '',
    })

local THIS = StructHighbrowProduct

-------------------------------------
-- function init
-------------------------------------
function StructHighbrowProduct:init(data)
    self.price = 100
    self.icon = 'res/ui/shop_gacha0102.png'
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
-- function buyProduct
-------------------------------------
function StructHighbrowProduct:buyProduct(finish_cb)
    if (not self:checkBuyable()) then
        return
    end

    local code = self:getCode()
    local game_key = self:getGameKey()
    g_highbrowData:request_buyHbProcduct(code, game_key, finish_cb)
end

-------------------------------------
-- function checkBuyable
-------------------------------------
function StructHighbrowProduct:checkBuyable()
    local capsule = g_userData:get('capsule')
    if (capsule < self.price) then
        MakeSimplePopup(POPUP_TYPE.OK, Str('캡슐이 부족합니다.'))
        return false
    end

    return true
end











-------------------------------------
-- function getName
-------------------------------------
function StructHighbrowProduct:getName()
    return self.name
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
    return self.price
end

-------------------------------------
-- function getIconRes
-------------------------------------
function StructHighbrowProduct:getIconRes()
    return self.icon
end

-------------------------------------
-- function getIcon
-------------------------------------
function StructHighbrowProduct:getIcon()
    return IconHelper:getIcon(self.icon)
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