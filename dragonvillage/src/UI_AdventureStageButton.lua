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

    local stage_info = g_adventureData:getStageInfo(stage_id)

    local difficulty, chapter, stage = parseAdventureID(stage_id)

    vars['stageLabel']:setString(chapter .. '-' .. stage)

    local clear_cnt = stage_info['clear_cnt']
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

    do
        vars['selectSprite']:setVisible(false)
        vars['arrowSprite']:setVisible(false)
    end

    do -- 난이도에 따라 sprite표시
        if (difficulty == 1) then
            vars['easySprite']:setVisible(true)

        elseif (difficulty == 2) then
            vars['easySprite']:setVisible(false)
            vars['normalSprite']:setVisible(true)

        elseif (difficulty == 3) then
            vars['easySprite']:setVisible(false)
            vars['hardSprite']:setVisible(true)

        else
            error('difficulty : ' .. difficulty)
        end
    end
    
    do -- 별 횟득 갯수 표시
        local stage_info = g_adventureData:getStageInfo(stage_id)
        local num_of_stars = stage_info:getNumberOfStars()
        local star_icon = cc.Sprite:create('res/ui/icon/stage_star_0' .. num_of_stars .. '.png')
        star_icon:setDockPoint(cc.p(0.5, 0.5))
        star_icon:setAnchorPoint(cc.p(0.5, 0.5))
        vars['starNode']:addChild(star_icon)
    end

    vars['stageBtn']:registerScriptTapHandler(function() parent_ui:click_stageBtn(stage_id, self.m_bOpenStage) end)
end