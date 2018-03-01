local PARENT = LobbyGuideAbstract

-------------------------------------
-- class LobbyGuide_Adventure
-------------------------------------
LobbyGuide_Adventure = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function LobbyGuide_Adventure:init()
end

-------------------------------------
-- function checkCustomCondition
-- @brief 조건 확인
-------------------------------------
function LobbyGuide_Adventure:checkCustomCondition()
    -- 보통 12-7 스테이지 클리어 못했으면 skip
    if (not g_adventureData:isClearStage(1111207)) then
        return false
    end
    
    -- 지옥 12-7 스테이지를 클리어 했을 경우 skip
    if g_adventureData:isClearStage(1131207) then
        return false
    end

    return true
end


-------------------------------------
-- function startCustomGuide
-- @brief 안내 시작
-------------------------------------
function LobbyGuide_Adventure:startCustomGuide()
    UI_LobbyGuideAdventure()
end

return LobbyGuide_Adventure