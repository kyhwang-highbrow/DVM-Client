local PARENT = UI

-------------------------------------
-- class UI_AdventureStageButton
-------------------------------------
UI_AdventureStageButton = class(PARENT, {
        m_bOpenStage = 'boolean',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_AdventureStageButton:init(parent_ui, stage_id)
    local vars = self:load('adventure_stage_icon.ui')

    local t_stage_data = g_adventureData:getStageData(stage_id)
    local difficulty, chapter, stage = parseAdventureID(stage_id)

    vars['stageLabel']:setString(chapter .. '-' .. stage)

    --cclog(luadump(t_stage_data))

    local clear_cnt = t_stage_data['clear_cnt']
    self.m_bOpenStage = false

    if (0 < clear_cnt) then
        vars['completeSprite']:setVisible(true)
        vars['lockSprite']:setVisible(false)
        vars['openSprite']:setVisible(false)
        self.m_bOpenStage = true
    else
        vars['completeSprite']:setVisible(false)

        local is_open = g_adventureData:isOpenStage(stage_id)
        self.m_bOpenStage = is_open
        do
            vars['lockSprite']:setVisible(not is_open)
            vars['openSprite']:setVisible(is_open)
        end
    end

    do -- юс╫ц
        vars['selectSprite']:setVisible(false)
        vars['arrowSprite']:setVisible(false)
    end

    vars['stageBtn']:registerScriptTapHandler(function() parent_ui:click_stageBtn(stage_id, self.m_bOpenStage) end)

    

    --[[
    t_stage_data['']

    stageBtn
    selectSprite
    arrowSprite
    openSprite
    lockSprite
    completeSprite
    --]]
end