local PARENT = UI_GameResultNew
----------------------------------------------------------------------------
-- class UI_GameResult_StoryDungeon
----------------------------------------------------------------------------
UI_GameResult_StoryDungeon = class(PARENT, {
})

-------------------------------------
-- function init_difficultyIcon
-- @brief 스테이지 난이도를 표시
--        모험모드에서 사용하므로 네스트던전에선 off
-------------------------------------
function UI_GameResult_StoryDungeon:init_difficultyIcon(stage_id)
    local vars = self.vars
    vars['difficultySprite']:setVisible(false)
    vars['gradeLabel']:setVisible(false)
    vars['titleLabel']:setPositionX(0)
    vars['titleLabel']:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
end


-------------------------------------
-- function click_prevBtn
-------------------------------------
function UI_GameResult_StoryDungeon:click_prevBtn()
    -- 이전 스테이지 ID 지정
    local stage_id = self.m_stageID
    local prev_stage_id = g_eventDragonStoryDungeon:getPrevStageID(stage_id)
    if prev_stage_id then
        g_stageData:setFocusStage(prev_stage_id)
    end

    local function close_cb()
        UINavigator:goTo('story_dungeon', prev_stage_id)
    end

    if prev_stage_id then
        UINavigator:goTo('battle_ready', prev_stage_id, close_cb)

    -- 이전 스테이지 없는 경우엔 모험맵으로 이동
    else
        UINavigator:goTo('story_dungeon', stage_id)
    end
end


-------------------------------------
-- function click_nextBtn
-------------------------------------
function UI_GameResult_StoryDungeon:click_nextBtn()
    -- 다음 스테이지 ID 지정
    local stage_id = self.m_stageID
    local next_stage_id = g_stageData:getNextStage(stage_id)
    if next_stage_id then
        g_stageData:setFocusStage(next_stage_id)
    end

    local function close_cb()
        UINavigator:goTo('story_dungeon', next_stage_id)
    end

    if next_stage_id then
        UINavigator:goTo('battle_ready', next_stage_id, close_cb)
        
    -- 다음 스테이지 없는 경우엔 모험맵으로 이동
    else
        UINavigator:goTo('story_dungeon', stage_id)
    end
end

-------------------------------------
-- function click_againBtn
-------------------------------------
function UI_GameResult_StoryDungeon:click_againBtn()
    -- 다음 스테이지 ID 지정
    local stage_id = self.m_stageID

    local function close_cb()
        UINavigator:goTo('story_dungeon', stage_id)
    end

    UINavigator:goTo('battle_ready', stage_id, close_cb)
end

-------------------------------------
-- function click_backBtn
-- @brief 모드별 백버튼은 여기서 처리
-------------------------------------
function UI_GameResult_StoryDungeon:click_backBtn()

    local game_mode = g_gameScene.m_gameMode
    local dungeon_mode = g_gameScene.m_dungeonMode
    local condition = self.m_stageID
    QuickLinkHelper.gameModeLink(game_mode, dungeon_mode, condition)
end

