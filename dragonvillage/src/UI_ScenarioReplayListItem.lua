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
    local chapter 

    -- 챕터 & 스테이지
    if string.find(scenario_name, 'prologue') then
        vars['chapterLabel']:setString('-')
    else
        chapter = string.gsub(scenario_name, 'scen_', '')
        chapter = string.gsub(chapter, '_s', '')
        chapter = string.gsub(chapter, '_e', '')
        chapter = string.gsub(chapter, '0', '')
        chapter = string.gsub(chapter, '_', '-')

        local str_sub = string.find(scenario_name, '_s') and Str('시작') or Str('종료')
        local str_chpater = string.format('%s %s', chapter, str_sub)
        vars['chapterLabel']:setString(str_chpater)
    end

    -- 타이틀
    local title
    if (TABLE:isFileExist('scenario/'..scenario_name, '.csv')) then
        local t_data = TABLE:loadCSVTable('scenario/'..scenario_name, '.csv', nil, 'page')
        for _, v in pairs(t_data) do
            local effect = v['effect_1']
            if string.find(effect, 'title') then
                local l_str = TableClass:seperate(effect, ';')
                title = Str(l_str[2])
                break
            end
        end
    end

    if (title) then
        vars['titleLabel']:setString(title)
    end

    -- 잠금 (열려있는 스테이지의 시나리오만 볼 수 있음)
    if (chapter) then
        local l_str = seperate(chapter, '-')
        if (not l_str) then 
            return
        end

        -- 보통 난이도 stage_id 로 체크
        local stage_id = string.format('111%02d%02d', tonumber(l_str[1]), tonumber(l_str[2]))
        local is_open = g_stageData:isOpenStage(stage_id)
        vars['lockSprite']:setVisible(not is_open)
        vars['replayBtn']:setEnabled(is_open)
    end
end