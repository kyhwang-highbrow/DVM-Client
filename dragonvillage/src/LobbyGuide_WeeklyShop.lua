local PARENT = LobbyGuideAbstract

-------------------------------------
-- class LobbyGuide_WeeklyShop
-------------------------------------
LobbyGuide_WeeklyShop = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function LobbyGuide_WeeklyShop:init()
end

-------------------------------------
-- function checkCustomCondition
-- @brief 조건 확인
-------------------------------------
function LobbyGuide_WeeklyShop:checkCustomCondition()
    local product_honor = g_shopData:getProduct('honor', 50006)
    if (not product_honor) then
        return false
    end

    local product_clancoin = g_shopData:getProduct('clancoin', 60010)
    if (not product_clancoin) then
        return false
    end


    if (not product_honor:isItBuyable()) and (not product_clancoin:isItBuyable()) then
        return false
    end

    return true
end


-------------------------------------
-- function startCustomGuide
-- @brief 안내 시작
-------------------------------------
function LobbyGuide_WeeklyShop:startCustomGuide()
    UI_LobbyGuideWeeklyShop()
end

return LobbyGuide_WeeklyShop