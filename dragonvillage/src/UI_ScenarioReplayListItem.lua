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

    if (is_prologue) then
        self:setPrologue(scenario_name)
    else
        self:setChapter(scenario_name)
    end
end

-------------------------------------
-- function setPrologue
-------------------------------------
function UI_ScenarioReplayListItem:setPrologue(scenario_name)
    local vars = self.vars
    local title = ''
    local stage = ''
    local chapter = ''

    -- 프롤로그, 악몽1, 인트로 전투, 악몽2 하드코딩
    if (scenario_name == 'scenario_prologue') then
        title = '프롤로그'
        stage = '' -- stage가 비어있다면 고대신룡/다크닉스
        chapter = ''
    elseif (scenario_name == 'scenario_prologue_nightmare_1') then
        title = '악몽 I'
        stage = 7
        chapter = 1 -- 누리가 주인공인 챕터
    elseif (scenario_name == 'scenario_prologue_intro_battle') then
        title = '시나리오 전투'
        stage = '' -- stage가 비어있다면 고대신룡/다크닉스
        chapter = ''
    elseif (scenario_name == 'scenario_prologue_nightmare_2') then
        title = '악몽 II'    
        stage = 1
        chapter = 1-- 고니가 주인공인 챕터
    end

    vars['chapterLabel']:setString('-')
    vars['titleLabel']:setString(Str(title))

    -- 배경 & 캐릭터 썸네일
    local bg_path = (stage == '') and 'sc_0.png' or string.format('sc_%d.png', chapter)
    if (bg_path) then
        local bg_icon = cc.Sprite:createWithSpriteFrameName(bg_path)
        bg_icon:setAnchorPoint(ZERO_POINT)
        bg_icon:setDockPoint(ZERO_POINT)
        vars['bgNode']:addChild(bg_icon)
    end
    
    local char_path = (stage == '') and '' or string.format('sc_%d_%d.png', chapter, stage)
    if (char_path ~= '') then
        local char_icon = cc.Sprite:createWithSpriteFrameName(char_path)
        char_icon:setAnchorPoint(ZERO_POINT)
        char_icon:setDockPoint(ZERO_POINT)
        vars['chaNode']:addChild(char_icon)
    end
end

-------------------------------------
-- function setChapter
-------------------------------------
function UI_ScenarioReplayListItem:setChapter(scenario_name)
    local vars = self.vars
    
    local str_chapter = string.gsub(scenario_name, 'scen_', '')
    str_chapter = string.gsub(str_chapter, '_s', '')
    str_chapter = string.gsub(str_chapter, '_e', '')
    str_chapter = string.gsub(str_chapter, '_', '-')
    l_str = seperate(str_chapter, '-')

    local chapter = tonumber(l_str[1])
    local stage = tonumber(l_str[2])
    
    -- 챕터 & 스테이지
    local str_chpater = string.format('%d-%d', chapter, stage)
    vars['chapterLabel']:setString(str_chpater)

    -- 타이틀
    local title
    local t_data = TABLE:loadCSVTable('scenario/'..scenario_name, '.csv', nil, 'page')
    if (t_data) then
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
        local str_sub = string.find(scenario_name, '_s') and ' I' or ' II'
        vars['titleLabel']:setString(title .. str_sub)
    end

	-- 메모리 부족하면 spriteFrame 메모리 날아가기 때문에 사용직전에 등록해
    cc.SpriteFrameCache:getInstance():addSpriteFrames('res/ui/a2d/sc_thumb/sc_thumb.plist')

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