local PARENT = LobbyGuideAbstract

-------------------------------------
-- class LobbyGuide_AncientTower
-------------------------------------
LobbyGuide_AncientTower = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function LobbyGuide_AncientTower:init()
end

-------------------------------------
-- function checkCustomCondition
-- @brief 조건 확인
-------------------------------------
function LobbyGuide_AncientTower:checkCustomCondition()
    -- 오픈 상태 여부 체크 (오픈 시간으로 체크)
    if (not g_ancientTowerData:isOpenAncientTower()) then
        return false
    end

    -- 오픈 상태 여부 체크 (오픈 플래그로 체크)
    if (not g_ancientTowerData:isOpen()) then
        return false
    end

    -- 고대의 탑 진입 가능 레벨 체크
    if (g_contentLockData:isContentLock('ancient')) then
        return false
    end

    -- 50층까지 클리어 완료
    if (50 <= g_ancientTowerData:getClearFloor()) then
        return false
    end

    return true
end


-------------------------------------
-- function startCustomGuide
-- @brief 안내 시작
-------------------------------------
function LobbyGuide_AncientTower:startCustomGuide()
    UI_LobbyGuideAncientTower()
end

return LobbyGuide_AncientTower