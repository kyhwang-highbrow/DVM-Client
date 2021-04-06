local PARENT = UI_GameResultNew

-------------------------------------
-- class UI_GameResult_DimensionGate
-------------------------------------
UI_GameResult_DimensionGate = class(PARENT, {

})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function UI_GameResult_DimensionGate:init(stage_id, is_success, time, gold, t_tamer_levelup_data, l_dragon_list, box_grade, l_drop_item_list, secret_dungeon, content_open) 
end


-------------------------------------
-- function init_difficultyIcon
-- @param file_name
-- @param body
-------------------------------------
function UI_GameResult_DimensionGate:init_difficultyIcon(stage_id) 
    local vars = self.vars
    vars['difficultySprite']:setVisible(false)
    vars['gradeLabel']:setVisible(false)
    vars['titleLabel']:setPositionX(0)
    vars['titleLabel']:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
end

-------------------------------------
-- function set_modeButton
-------------------------------------
function UI_GameResult_DimensionGate:set_modeButton() 
    local vars = self.vars

    -- 던전에서 사용하지 않는 버튼 숨김
    vars['mapBtn']:setVisible(false)
    vars['prevBtn']:setVisible(false)
    vars['nextBtn']:setVisible(false)

    -- 버튼 위치들 조정
    vars['againBtn']:setPositionX(-110)
    vars['quickBtn']:setPositionX(110)

    -- 던전 버튼 활성화
    vars['contentBtn']:setVisible(true)
    vars['contentLabel']:setString(Str('차원의 문'))
    vars['contentBtn']:registerScriptTapHandler(function() self:click_contentBtn() end)
end

-------------------------------------
-- function direction_showBox
-- @brief PARENT class인 UI_GameResultNew의 보상 관련 연출 function.
-- 차원문의 경우 별도의 보상이 없으므로 보상 연출 삭제를 위함.
-------------------------------------
function UI_GameResult_DimensionGate:direction_showBox()
    self:doNextWork()
end

-------------------------------------
-- function direction_openBox
-- @brief PARENT class인 UI_GameResultNew의 보상 관련 연출 function.
-- 차원문의 경우 별도의 보상이 없으므로 보상 연출 삭제를 위함.
-------------------------------------
function UI_GameResult_DimensionGate:direction_openBox()
    self:doNextWork()
end

-------------------------------------
-- function direction_dropItem
-- @brief PARENT class인 UI_GameResultNew의 보상 관련 연출 function.
-- 차원문의 경우 별도의 보상이 없으므로 보상 연출 삭제를 위함.
-------------------------------------
function UI_GameResult_DimensionGate:direction_dropItem()
    self:doNextWork()
end
-------------------------------------
-- function click_againBtn
-- @brief 바로 재시작
-------------------------------------
function UI_GameResult_DimensionGate:click_againBtn() 
    SceneDimensionGate(self.m_stageID, true):runScene()
end

-------------------------------------
-- function click_contentBtn
-- @brief 
-------------------------------------
function UI_GameResult_DimensionGate:click_contentBtn() 
    SceneDimensionGate():runScene()
end