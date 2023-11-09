local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ChapterSelectListItem
-------------------------------------
UI_ChapterSelectListItem = class(PARENT, {
        m_owner_ui = '',
        m_stageID = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ChapterSelectListItem:init(owner_ui, stage_id)
    self.m_owner_ui = owner_ui
    self.m_stageID = stage_id
    local vars = self:load('adventure_chapter_select_item.ui')

    self:initUI()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ChapterSelectListItem:initUI()
    local vars = self.vars
    local stage_id = self.m_stageID
    local difficulty, chapter, stage = parseAdventureID(stage_id)

    local t_difficulty = {
        'normal',
        'hard',
        'hell',
        'hellFire',
        'abyss_0',
        'abyss_1',
    }

    local target_btn = vars[t_difficulty[difficulty]..'Btn']
    target_btn:setVisible(true)

    -- 지옥 모드 강제로 막음 (어려움 마지막 스테이지 클리어한 상태면 지옥 모드 1 스테이지가 열린 상태임)
    if (g_adventureData:isOpenStage(stage_id) and difficulty <= MAX_ADVENTURE_DIFFICULTY) then
        target_btn:registerScriptTapHandler(function() self:click_selectBtn() end)

        
        local total_star_num = 0
        
        for i = 1, MAX_ADVENTURE_STAGE do
            local adventure_id = makeAdventureID(difficulty, chapter, i)
            local stage_info = g_adventureData:getStageInfo(adventure_id)
            
            total_star_num = total_star_num + stage_info:getNumberOfStars()
        end

        vars['starMenu']:setVisible(true)
        vars['starLabel']:setString(string.format('%d', total_star_num))

    else
        vars['lockSprite']:setVisible(true)
        target_btn:setEnabled(false)
    end

    local target_label = vars[t_difficulty[difficulty]..'Label']
    target_label:setString(string.format('%02d', chapter))
end

-------------------------------------
-- function click_selectBtn
-------------------------------------
function UI_ChapterSelectListItem:click_selectBtn()
    local stage_id = self.m_stageID
    self.m_owner_ui:setRefreshClose(stage_id)
end

