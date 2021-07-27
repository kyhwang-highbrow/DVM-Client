local PARENT = UI_GameResultNew

-------------------------------------
-- class UI_GameResult_AncientRuin
-------------------------------------
UI_GameResult_AncientRuin = class(PARENT, {
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function UI_GameResult_AncientRuin:init(stage_id, is_success, time, gold, t_tamer_levelup_data, l_dragon_list, box_grade, l_drop_item_list, secret_dungeon)
    local vars = self.vars

    -- 메뉴 포지션 변경 (드래곤 레벨업 연출 생략)
    local btn_menu = vars['btnMenu']
    local reward_menu = vars['dropRewardMenu']
    local no_reward_menu = vars['noRewardMenu']
    local reward_visual = vars['boxVisual']
   
    btn_menu:setPositionY( btn_menu:getPositionY() + 260 )
    reward_menu:setPositionY( reward_menu:getPositionY() + 245 )
    no_reward_menu:setPositionY( no_reward_menu:getPositionY() + 245 )
    reward_visual:setPositionY( reward_visual:getPositionY() + 245 )
end

-------------------------------------
-- function init_difficultyIcon
-- @brief 스테이지 난이도를 표시
--        모험모드에서 사용하므로 네스트던전에선 off
-------------------------------------
function UI_GameResult_AncientRuin:init_difficultyIcon(stage_id)
    local vars = self.vars
    vars['difficultySprite']:setVisible(false)
    vars['gradeLabel']:setVisible(false)
    vars['titleLabel']:setPositionX(0)
    vars['titleLabel']:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
end

-------------------------------------
-- function click_againBtn
-------------------------------------
function UI_GameResult_AncientRuin:click_againBtn()
    local is_ready = true
    local scene = SceneNestDungeon(self.m_stageID, nil, is_ready)
    scene:runScene()
end

-------------------------------------
-- function click_nextBtn
-------------------------------------
function UI_GameResult_AncientRuin:click_nextBtn()
    local next_stage_id = g_stageData:getNextStage(self.m_stageID) or self.m_stageID
    local is_ready = true
    local scene = SceneNestDungeon(next_stage_id, nil, is_ready)
    scene:runScene()
end

-------------------------------------
-- function click_prevBtn
-------------------------------------
function UI_GameResult_AncientRuin:click_prevBtn()
    local prev_stage_id = g_stageData:getSimplePrevStage(self.m_stageID) or self.m_stageID
    local is_ready = true
    local scene = SceneNestDungeon(prev_stage_id, nil, is_ready)
    scene:runScene()
end

-------------------------------------
-- function direction_start
-- @brief 시작 연출
-------------------------------------
function UI_GameResult_AncientRuin:direction_start()
    local is_success = self.m_bSuccess
    local vars = self.vars
    
    vars['titleNode']:setVisible(true)
    vars['resultMenu']:setVisible(true)

    self:setSuccessVisual()

	vars['statsBtn']:setVisible(false)
    vars['homeBtn']:setVisible(false)
    vars['nextBtn']:setVisible(false)
    vars['quickBtn']:setVisible(false)

    vars['skipLabel']:setVisible(false)
    vars['againBtn']:setVisible(false)

    -- 드래곤 레벨업 연출 node
    vars['dragonResultNode']:setVisible(true)

    -- 플레이 시간, 획득 골드
    self.m_lNumberLabel['time']:setNumber(self.m_time)
    self.m_lNumberLabel['gold']:setNumber(self.m_gold)

    -- 자동 재화 회득 
    local stage_id = self.m_stageID
    local game_mode = g_stageData:getGameMode(stage_id)

    -- 레벨업 연출 스킵
    self:doNextWork()

    -- 테이머 경험치 연출
    self:startLevelUpDirector()
end
-------------------------------------
-- function direction_moveMenu
-------------------------------------
function UI_GameResult_AncientRuin:direction_moveMenu()
    self:show_staminaInfo()
    self:doNextWork()
end

-------------------------------------
-- function direction_dragonGuide
-------------------------------------
function UI_GameResult_AncientRuin:direction_dragonGuide()
    -- 고대 유적 던전은 패배시 성장 가이드 노출 X - 10마리 가이드 불가..
    self:doNextWork()
end