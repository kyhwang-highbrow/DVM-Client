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
function UI_GameResult_NestDungeon:init(stage_id, is_success, time, gold, t_tamer_levelup_data, l_dragon_list, box_grade, l_drop_item_list, secret_dungeon)
    
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
-- function makeRewardItem
-------------------------------------
function UI_GameResult_NestDungeon:makeRewardItem(i, v)
    local item_card = PARENT.makeRewardItem(self, i, v)

    -- 등록된 보너스 아이템이 없을 경우 리턴
    local l_bonus_value = seperate(self.m_nestDungeonInfo['bonus_value'], ',')
    if (not l_bonus_value) or (#l_bonus_value <= 0) then
        return item_card
    end

    local item_id = v[1]

    -- 보너스 보상 비율 표시
    for i,v in ipairs(l_bonus_value) do
        if (item_id == tonumber(v)) then
            item_card.vars['bonusSprite']:setVisible(true)
            local bonus_rate = 1 + (self.m_nestDungeonInfo['bonus_rate'] / 100)
            item_card.vars['bonusLabel']:setString('X' .. bonus_rate)
            break
        end
    end

    return item_card
end