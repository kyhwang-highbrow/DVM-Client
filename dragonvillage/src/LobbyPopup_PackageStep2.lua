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

    -- 현재 유효하지 않은 상품일 경우
    local valid_step_package = g_shopDataNew:getValidStepPackage()
    if (valid_step_package ~='package_step_02') then
        return false
    end

    -- 단계별 패키지 product id
    local t_step_pids = {110201, 110202, 110203, 110204}

    -- 1단계 상품을 구매했을 경우
    if (g_shopDataNew:getBuyCount(110201) > 0) then
        return false
    end

    -- 4단계까지 모두 구매했을 경우
    if (g_shopDataNew:getBuyCount(110204) >= 1) then
        return false
    end

    return true
end


-------------------------------------
-- function startCustomGuide
-- @brief 안내 시작
-------------------------------------
function LobbyPopup_PackageStep2:startCustomGuide()
end

return LobbyPopup_PackageStep2