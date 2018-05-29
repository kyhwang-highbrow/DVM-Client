local PARENT = LobbyPopupAbstract

-------------------------------------
-- class LobbyPopup_PackageStep2
-------------------------------------
LobbyPopup_PackageStep2 = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function LobbyPopup_PackageStep2:init()
end

-------------------------------------
-- function checkCustomCondition
-- @brief 조건 확인
-------------------------------------
function LobbyPopup_PackageStep2:checkCustomCondition()
    -- 단계별 패키지 product id
    local t_step_pids = {90105, 90106, 90107, 90108}

    -- 1단계는 구매했고 4단계는 구매하지 않았을 경우
    if (1 <= g_shopDataNew:getBuyCount(90105)) and (g_shopDataNew:getBuyCount(90108) < 1) then
        return true
    end

    return false
end


-------------------------------------
-- function startCustomGuide
-- @brief 안내 시작
-------------------------------------
function LobbyPopup_PackageStep2:startCustomGuide()
end

return LobbyPopup_PackageStep2