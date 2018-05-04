local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ScenarioReplayListItem
-------------------------------------
UI_ScenarioReplayListItem = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ScenarioReplayListItem:init(scenario_name)
	self:load('scenario_replay_item.ui')
    self:initUI(scenario_name)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ScenarioReplayListItem:initUI(scenario_name)
    local vars = self.vars
    local is_prologue = string.find(scenario_name, 'prologue') and true or false

    local str_chapter = string.gsub(scenario_name, 'scen_', '')
    str_chapter = string.gsub(str_chapter, '_s', '')
    str_chapter = string.gsub(str_chapter, '_e', '')
    str_chapter = string.gsub(str_chapter, '_', '-')
    l_str = seperate(str_chapter, '-')

    local chapter = tonumber(l_str[1])
    local stage = tonumber(l_str[2])
    
    -- 챕터 & 스테이지
    if (is_prologue) then
        vars['chapterLabel']:setString('-')
    else
        local str_chpater = string.format('%d-%d', chapter, stage)
        vars['chapterLabel']:setString(str_chpater)
    end

    -- 타이틀
    local title
    local t_data = TABLE:loadCSVTable('scenario/'..scenario_name, '.csv', nil, 'page')
    for _, v in pairs(t_data) do
        local effect = v['effect_1']
        if string.find(effect, 'title') then
            local l_str = TableClass:seperate(effect, ';')
            title = Str(l_str[2])
            break
        end
    end
    
    if (title) then
        if (is_prologue) then
            vars['titleLabel']:setString(title)
        else
            local str_sub = string.find(scenario_name, '_s') and ' I' or ' II'
            vars['titleLabel']:setString(title .. str_sub)
        end
    end

    -- 배경 & 캐릭터 썸네일
    local bg_path = (is_prologue) and 'sc_0.png' or string.format('sc_%d.png', chapter)
    if (bg_path) then
        local bg_icon = cc.Sprite:createWithSpriteFrameName(bg_path)
        bg_icon:setAnchorPoint(ZERO_POINT)
        bg_icon:setDockPoint(ZERO_POINT)
        vars['bgNode']:addChild(bg_icon)
    end
    
    local char_path = (is_prologue) and '' or string.format('sc_%d_%d.png', chapter, stage)
    if (char_path ~= '') then
        local char_icon = cc.Sprite:createWithSpriteFrameName(char_path)
        char_icon:setAnchorPoint(ZERO_POINT)
        char_icon:setDockPoint(ZERO_POINT)
        vars['chaNode']:addChild(char_icon)
    end

    -- 잠금 (열려있는 스테이지의 시나리오만 볼 수 있음)
    if (not is_prologue) then
        -- 보통 난이도 stage_id 로 체크
        local stage_id = string.format('111%02d%02d', chapter, stage)
        local is_open = g_stageData:isOpenStage(stage_id)
        vars['lockSprite']:setVisible(not is_open)
        vars['replayBtn']:setEnabled(is_open)
    end
end