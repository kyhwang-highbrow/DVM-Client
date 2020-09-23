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

-------------------------------------
-- function checkAutoPlayCondition
-- @override
-------------------------------------
function UI_GameResult_Adventure:checkAutoPlayCondition()
	local auto_play_stop, msg = PARENT.checkAutoPlayCondition(self)

    -- 승리 시 다음층으로 이동
	if (g_autoPlaySetting:get('adv_next_stage')) then  
        -- 패배했다면 더이상 조건체크 안함
        if (not self.m_bSuccess) then
            auto_play_stop = true
            msg = Str('패배로 인해 연속 전투가 종료되었습니다.')
        else
            local next_stage_id = g_adventureData:getNextStageID(self.m_stageID)

            -- 다음 스테이지 없음
            if (next_stage_id == nil) then
                auto_play_stop = true
                msg = Str('연속 전투가 종료되었습니다.')
            end
        end        
	end

	return auto_play_stop, msg
end

-------------------------------------
-- function startGame
-- @override
-------------------------------------
function UI_GameResult_Adventure:startGame()
    -- 연속 전투 : 승리시 다음 스테이지 진행 설정 시 스테이지 ID 증가
	if (g_autoPlaySetting:isAutoPlay()) then
	    if (g_autoPlaySetting:get('adv_next_stage')) then
	    	if (self.m_bSuccess) then
                self.m_stageID = g_stageData:getNextStage(self.m_stageID)
            end
        end
    end

    PARENT.startGame(self)
end