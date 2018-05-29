local PARENT = LobbyPopupAbstract

-------------------------------------
-- class LobbyPopup_PackageStep
-------------------------------------
LobbyPopup_PackageStep = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function LobbyPopup_PackageStep:init()
end

-------------------------------------
-- function checkCustomCondition
-- @brief 조건 확인
-------------------------------------
function LobbyPopup_PackageStep:checkCustomCondition()
    -- 단계별 패키지 product id
    local t_step_pids = {90105, 90106, 90107, 90108}

    -- 1단계 상품도 구매하지 않았을 경우
    if (g_shopDataNew:getBuyCount(90105) <= 0) then
        return true
    end

    return false
end


-------------------------------------
-- function startCustomGuide
-- @brief 안내 시작
-------------------------------------
function LobbyPopup_PackageStep:startCustomGuide()
end

return LobbyPopup_PackageStep