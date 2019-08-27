local PARENT = UI_GameResultNew

-------------------------------------
-- class UI_GameResult_NestDungeon
-------------------------------------
UI_GameResult_NestDungeon = class(PARENT, {
        m_nestDungeonInfo = 'table',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function UI_GameResult_NestDungeon:init(stage_id, is_success, time, gold, t_tamer_levelup_data, l_dragon_list, box_grade, l_drop_item_list, secret_dungeon, content_open)
    -- 서버에서 받아온 네스트 던전의 정보
    self.m_nestDungeonInfo = g_nestDungeonData:getNestDungeonInfoIndividual(stage_id)
end

-------------------------------------
-- function init_difficultyIcon
-- @brief 스테이지 난이도를 표시
--        모험모드에서 사용하므로 네스트던전에선 off
-------------------------------------
function UI_GameResult_NestDungeon:init_difficultyIcon(stage_id)
    local vars = self.vars
    vars['difficultySprite']:setVisible(false)
    vars['gradeLabel']:setVisible(false)
    vars['titleLabel']:setPositionX(0)
    vars['titleLabel']:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
end

-------------------------------------
-- function click_againBtn
-------------------------------------
function UI_GameResult_NestDungeon:click_againBtn()
    local is_ready = true
    local scene = SceneNestDungeon(self.m_stageID, nil, is_ready)
    scene:runScene()
end

-------------------------------------
-- function click_nextBtn
-------------------------------------
function UI_GameResult_NestDungeon:click_nextBtn()
    local next_stage_id = g_stageData:getNextStage(self.m_stageID) or self.m_stageID
    local is_ready = true
    local scene = SceneNestDungeon(next_stage_id, nil, is_ready)
    scene:runScene()
end

-------------------------------------
-- function click_prevBtn
-------------------------------------
function UI_GameResult_NestDungeon:click_prevBtn()
    local prev_stage_id = g_stageData:getSimplePrevStage(self.m_stageID) or self.m_stageID
    local is_ready = true
    local scene = SceneNestDungeon(prev_stage_id, nil, is_ready)
    scene:runScene()
end

-------------------------------------
-- function direction_end
-- @brief 종료 연출
-------------------------------------
function UI_GameResult_NestDungeon:direction_end()
    UI_GameResultNew.direction_end(self)

    local is_success = self.m_bSuccess
    local vars = self.vars

    local t_dungeon = g_nestDungeonData:parseNestDungeonID(self.m_stageID)
    local dungeonMode = t_dungeon['dungeon_mode']

    if (dungeonMode == NEST_DUNGEON_GOLD) then    
        if (not is_success) then
            local duration = 2
            if g_autoPlaySetting:isAutoPlay() then
                duration = 0.5
            end
            -- 2초 후 자동으로 이동
            self.root:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.CallFunc:create(function()
                self:doNextWork()
            end)))

            vars['skipLabel']:setVisible(true)
            vars['skipBtn']:setVisible(true)

            vars['statsBtn']:setVisible(false)
            vars['againBtn']:setVisible(false)
        end
    end
end

-------------------------------------
-- function direction_masterRoad
-------------------------------------
function UI_GameResult_NestDungeon:direction_masterRoad()
     -- 고대 유적 던전 컨텐츠 오픈 팝업
    if (self.m_content_open) then
        -- 오픈된 상태에서 네스트 던전 정보 다시 받아와야함
        g_nestDungeonData.m_bDirtyNestDungeonInfo = true
        --UI_ContentOpenPopup('ancient_ruin')
    end 

    PARENT.direction_masterRoad(self)
end