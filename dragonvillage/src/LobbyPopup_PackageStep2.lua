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
    local valid_step_package = g_shopData:getValidStepPackage()
    if (valid_step_package ~='package_step_02') then
        return false
    end

    -- 단계별 패키지 product id
    local l_step_pids = g_shopData:getPakcageStepPidList('package_step_02')
    if (#l_step_pids ~= 4) then
        return false
    end

    -- brief 1단계를 구매하고 4단계까지 구매하지 않았을 경우

    -- 1단계를 구매하지 않았을 경우
    if (g_shopData:getBuyCount(l_step_pids[1]) <= 0) then
        return false
    end

    -- 4단계까지 모두 구매했을 경우
    if (g_shopData:getBuyCount(l_step_pids[4]) >= 1) then
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