local PARENT = LobbyGuideAbstract

-------------------------------------
-- class LobbyGuide_AttrTower
-------------------------------------
LobbyGuide_AttrTower = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function LobbyGuide_AttrTower:init()
end

-------------------------------------
-- function checkCustomCondition
-- @brief 조건 확인
-------------------------------------
function LobbyGuide_AttrTower:checkCustomCondition()
    
    -- 시험의 탑이 이미 오픈되어 있을 경우 skip
    if (g_attrTowerData:isContentOpen()) then
        return false
    end

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

    -- 30층까지 클리어하지 못했을 경우
    if (g_ancientTowerData:getClearFloor() < 30) then
        return false
    end

    return true
end


-------------------------------------
-- function startCustomGuide
-- @brief 안내 시작
-------------------------------------
function LobbyGuide_AttrTower:startCustomGuide()
    UI_LobbyGuideAttrTower()
end

return LobbyGuide_AttrTower