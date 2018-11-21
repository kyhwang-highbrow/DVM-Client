local PARENT = UI_GameResultNew

-------------------------------------
-- class UI_GameResult_RuneGuardianDungeon
-------------------------------------
UI_GameResult_RuneGuardianDungeon = class(PARENT, {
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function UI_GameResult_RuneGuardianDungeon:init(stage_id, is_success, time, gold, t_tamer_levelup_data, l_dragon_list, box_grade, l_drop_item_list, secret_dungeon, content_open)
end

-------------------------------------
-- function init_difficultyIcon
-- @brief 스테이지 난이도를 표시
--        모험모드에서 사용하므로 네스트던전에선 off
-------------------------------------
function UI_GameResult_RuneGuardianDungeon:init_difficultyIcon(stage_id)
    local vars = self.vars
    vars['difficultySprite']:setVisible(false)
    vars['gradeLabel']:setVisible(false)
    vars['titleLabel']:setPositionX(0)
    vars['titleLabel']:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
end

-------------------------------------
-- function click_againBtn
-------------------------------------
function UI_GameResult_RuneGuardianDungeon:click_againBtn()
    local scene = SceneRuneGuardianDungeon(self.m_stageID)
    scene:runScene()
end

-------------------------------------
-- function click_contentBtn
-------------------------------------
function UI_GameResult_RuneGuardianDungeon:click_contentBtn()
    local scene = SceneRuneGuardianDungeon()
    scene:runScene()
end

-------------------------------------
-- function set_modeButton
-- @brief 모드별 버튼 정리
-------------------------------------
function UI_GameResult_RuneGuardianDungeon:set_modeButton()
    local vars = self.vars

    -- 룬 수호자 던전에서 사용하지 않는 버튼 숨김
    vars['mapBtn']:setVisible(false)
    vars['prevBtn']:setVisible(false)
    vars['nextBtn']:setVisible(false)

    -- 버튼 위치들 조정
    vars['againBtn']:setPositionX(-110)
    vars['quickBtn']:setPositionX(110)

    -- 룬 수호자 던전 버튼 활성화
    vars['contentBtn']:setVisible(true)
    vars['contentLabel']:setString(Str('룬 수호자 던전'))
    vars['contentBtn']:registerScriptTapHandler(function() self:click_contentBtn() end)
end