local PARENT = UI_GameResultNew

-------------------------------------
-- class UI_GameResult_Adventure
-------------------------------------
UI_GameResult_Adventure = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_GameResult_Adventure:init(stage_id, is_success, time, gold, t_tamer_levelup_data, l_dragon_list, box_grade, l_drop_item_list, secret_dungeon)
	-- @ TUTORIAL : 강종을 대비해서 튜토리얼 step만 저장한다
	TutorialManager.getInstance():saveTutorialStepInAdventureResult(stage_id)
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

        local stage_id = self.m_stageID
        local stage_info = g_adventureData:getStageInfo(stage_id)
        local num_of_stars = stage_info:getNumberOfStars()

        SoundMgr:playBGM('bgm_dungeon_victory', false)    
        vars['successVisual']:changeAni('success_0' .. num_of_stars, false)
        vars['successVisual']:addAniHandler(function()
            vars['successVisual']:changeAni('success_idle_0' .. num_of_stars, true)
        end)
    else
        SoundMgr:playBGM('bgm_dungeon_lose', false)
        vars['successVisual']:changeAni('fail')
    end
end