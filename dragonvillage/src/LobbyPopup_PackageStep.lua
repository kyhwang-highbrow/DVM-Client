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

    -- 현재 유효하지 않은 상품일 경우
    local valid_step_package = g_shopDataNew:getValidStepPackage()

    if (not valid_step_package) then
        return false
    end

    if (valid_step_package ~= 'package_step_02') then
        return false
    end

    -- 단계별 패키지 product id
    local l_step_pids = g_shopDataNew:getPakcageStepPidList('package_step_02')

    if (#l_step_pids ~= 4) then
        return false
    end
    
    -- 1단계 상품을 구매했을 경우
    if (g_shopDataNew:getBuyCount(l_step_pids[1]) > 0) then
        return false
    end

    return true
end


-------------------------------------
-- function startCustomGuide
-- @brief 안내 시작
-------------------------------------
function LobbyPopup_PackageStep:startCustomGuide()
end

return LobbyPopup_PackageStep