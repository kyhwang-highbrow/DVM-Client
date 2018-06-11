local PARENT = LobbyGuideAbstract

-------------------------------------
-- class LobbyGuide_Arena
-------------------------------------
LobbyGuide_Arena = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function LobbyGuide_Arena:init()
end

-------------------------------------
-- function checkCustomCondition
-- @brief 조건 확인
-------------------------------------
function LobbyGuide_Arena:checkCustomCondition()
    
    -- 오픈 상태 여부 체크 (오픈 시간으로 체크)
    if (not g_arenaData:isOpenArena()) then
        return false
    end

    -- 오픈 상태 여부 체크 (오픈 플래그로 체크)
    if (not g_arenaData:isOpen()) then
        return false
    end

    -- 콜로세움 진입 가능 레벨 체크
    if (g_contentLockData:isContentLock('colosseum')) then
        return false
    end

    -- 주간 참여 보상 20회를 채우지 않은 상태
    local struct_user_info = g_arenaData:getPlayerArenaUserInfo()
    if (struct_user_info) then
        local cnt = struct_user_info:getWinCnt() + struct_user_info:getLoseCnt()
        if (20 <= cnt) then
            return false
        end
    else
        return false
    end

    return true
end


-------------------------------------
-- function startCustomGuide
-- @brief 안내 시작
-------------------------------------
function LobbyGuide_Arena:startCustomGuide()
    UI_LobbyGuideArena()
end

return LobbyGuide_Arena