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
-- function direction_showButton
-------------------------------------
function UI_GameResult_StoryDungeon:direction_showButton()
    local vars = self.vars
	vars['statsBtn']:setVisible(true)
    vars['homeBtn']:setVisible(true)
    vars['againBtn']:setVisible(true)
    vars['nextBtn']:setVisible(false)
    vars['quickBtn']:setVisible(false)    

    self:set_modeButton()
    self:doNextWork()
end

-------------------------------------
-- function click_againBtn
-------------------------------------
function UI_GameResult_StoryDungeon:click_againBtn()
--[[     local stage_id = self.m_stageID
    local function close_cb()
        UINavigator:goTo('secret_relation', stage_id)
    end

    UINavigator:goTo('battle_ready', stage_id, close_cb) ]]
end