local PARENT = UI_GameResultNew

local TUTORIAL_STAGE_ID_1 = 1110101
local TUTORIAL_STAGE_ID_2 = 1110102
-------------------------------------
-- class UI_GameResult_Adventure
-------------------------------------
UI_GameResult_Adventure = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_GameResult_Adventure:init(stage_id, is_success, time, gold, t_tamer_levelup_data, l_dragon_list, box_grade, l_drop_item_list, secret_dungeon)
end

-------------------------------------
-- function setSuccessVisual
-- @brief 성공 연출
-------------------------------------
function UI_GameResult_Adventure:setSuccessVisual()
    local is_success = self.m_bSuccess
    local vars = self.vars

    vars['successVisual']:setVisible(true)

    -- 성공 or 실패
    if (is_success == true) then
        SoundMgr:playBGM('bgm_dungeon_victory', false)

        local stage_id = self.m_stageID

        -- 깜짝 출현 챕터 예외처리
        if (isAdventStageID(stage_id)) then
            vars['successVisual']:changeAni('success', false)
            vars['successVisual']:addAniHandler(function()
                vars['successVisual']:changeAni('success_idle', true)
            end)

        else
            local stage_info = g_adventureData:getStageInfo(stage_id)
            local num_of_stars = stage_info:getNumberOfStars()
            vars['successVisual']:changeAni('success_0' .. num_of_stars, false)
            vars['successVisual']:addAniHandler(function()
                vars['successVisual']:changeAni('success_idle_0' .. num_of_stars, true)
            end)
        end
    else
        SoundMgr:playBGM('bgm_dungeon_lose', false)
        vars['successVisual']:changeAni('fail')
    end
end

-------------------------------------
-- function checkIsTutorial
-------------------------------------
function UI_GameResult_Adventure:checkIsTutorial()
    -- 1-2를 클리어 했다면 return false 버튼 막지 않음
    if (g_adventureData:isClearStage(TUTORIAL_STAGE_ID_2)) then
        return false
    end

    -- 1-1 스테이지 아니라면 return false 버튼 막지 않음
    if (self.m_stageID ~= TUTORIAL_STAGE_ID_1) then
        return false
    end

    return true
end
