local PARENT = UI_GameResultNew

-------------------------------------
-- class UI_GameResult_AncientTower
-------------------------------------
UI_GameResult_AncientTower = class(PARENT, {})

-------------------------------------
-- function click_retryBtn
-------------------------------------
function UI_GameResult_AncientTower:init(stage_id, is_success, time, gold, t_tamer_levelup_data, l_dragon_list, box_grade, l_drop_item_list, secret_dungeon, score_calc)
    local vars = self.vars

    vars['againBtn']:setVisible(false)
    vars['quickBtn']:setVisible(false)
end

-------------------------------------
-- function init_difficultyIcon
-- @brief 스테이지 난이도를 표시
--        모험모드에서 사용하므로 고대의 탑에선 off
-------------------------------------
function UI_GameResult_AncientTower:init_difficultyIcon(stage_id)
    local vars = self.vars
    vars['difficultySprite']:setVisible(false)
    vars['gradeLabel']:setVisible(false)
    vars['titleLabel']:setPositionX(0)
    vars['titleLabel']:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
end

-------------------------------------
-- function click_retryBtn
-------------------------------------
function UI_GameResult_AncientTower:click_retryBtn()
    g_ancientTowerData:goToAncientTowerScene()
end

-------------------------------------
-- function click_backBtn
-------------------------------------
function UI_GameResult_AncientTower:click_backBtn()
    g_ancientTowerData:goToAncientTowerScene()
end

-------------------------------------
-- function click_nextBtn
-------------------------------------
function UI_GameResult_AncientTower:click_nextBtn()
    g_ancientTowerData:goToAncientTowerScene()
end

-------------------------------------
-- function direction_end
-- @brief 종료 연출
-------------------------------------
function UI_GameResult_AncientTower:direction_end()
    PARENT.direction_end(self)

    local vars = self.vars

    vars['againBtn']:setVisible(false)
    vars['quickBtn']:setVisible(false)
end

-------------------------------------
-- function direction_showButton
-------------------------------------
function UI_GameResult_AncientTower:direction_showButton()
    PARENT.direction_showButton(self)

    local vars = self.vars

    vars['againBtn']:setVisible(false)
    vars['quickBtn']:setVisible(false)
end

-------------------------------------
-- function checkAutoPlay
-- @brief
-------------------------------------
function UI_GameResult_AncientTower:checkAutoPlay()
    return
end