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
-- function click_retryBtn
-------------------------------------
function UI_GameResult_NestDungeon:click_retryBtn()
    local scene = SceneNestDungeon(self.m_stageID)
    scene:runScene()
end

-------------------------------------
-- function click_backBtn
-------------------------------------
function UI_GameResult_NestDungeon:click_backBtn()
    local scene = SceneNestDungeon(self.m_stageID)
    scene:runScene()
end

-------------------------------------
-- function click_nextBtn
-------------------------------------
function UI_GameResult_NestDungeon:click_nextBtn()
    local next_stage_id = g_stageData:getNextStage(self.m_stageID) or self.m_stageID
    local scene = SceneNestDungeon(next_stage_id)
    scene:runScene()
end

-------------------------------------
-- function click_quickBtn
-------------------------------------
function UI_GameResult_NestDungeon:click_quickBtn()
    if (not g_staminasData:checkStageStamina(self.m_stageID)) then
        local msg = Str('입장권을 모두 소모하여 빠른 시작을 할 수 없습니다.')
        MakeSimplePopup(POPUP_TYPE.OK, msg)
        return
    end

    PARENT.click_quickBtn(self)
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