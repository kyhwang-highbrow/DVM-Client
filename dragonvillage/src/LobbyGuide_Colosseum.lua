local PARENT = LobbyGuideAbstract

-------------------------------------
-- class LobbyGuide_Colosseum
-------------------------------------
LobbyGuide_Colosseum = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function LobbyGuide_Colosseum:init()
end

-------------------------------------
-- function checkCustomCondition
-- @brief 조건 확인
-------------------------------------
function LobbyGuide_Colosseum:checkCustomCondition()
    
    -- 오픈 상태 여부 체크 (오픈 시간으로 체크)
    if (not g_colosseumData:isOpenColosseum()) then
        return false
    end

    -- 오픈 상태 여부 체크 (오픈 플래그로 체크)
    if (not g_colosseumData:isOpen()) then
        return false
    end

    -- 콜로세움 진입 가능 레벨 체크
    if (g_contentLockData:isContentLock('colosseum')) then
        return false
    end

    -- 주간 승리 보상 20승을 채우지 않은 상태
    local struct_user_info = g_colosseumData:getPlayerColosseumUserInfo()
    local curr_win = struct_user_info:getWinCnt()
    if (20 < curr_win) then
        return false
    end

    return true
end


-------------------------------------
-- function startCustomGuide
-- @brief 안내 시작
-------------------------------------
function LobbyGuide_Colosseum:startCustomGuide()
    UI_LobbyGuideColosseum()
end

return LobbyGuide_Colosseum