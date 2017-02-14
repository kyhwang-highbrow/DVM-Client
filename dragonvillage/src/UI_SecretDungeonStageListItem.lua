local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_SecretDungeonStageListItem
-------------------------------------
UI_SecretDungeonStageListItem = class(PARENT, {
        m_stageTable = 'table',
        m_remainTimeText = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_SecretDungeonStageListItem:init(t_data)
    local vars = self:load('secret_dungeon_stage_list_item.ui')

    self.m_stageTable = t_data

    self:initUI(t_data)
    self:initButton()
    self:refresh(t_data)

    -- UI가 enter로 진입되었을 때 update함수 호출
    self.root:registerScriptHandler(function(event)
        if (event == 'enter') then
            self.root:scheduleUpdateWithPriorityLua(function(dt) return self:update(dt) end, 0)
        end
    end)
end
-------------------------------------
-- function initUI
-------------------------------------
function UI_SecretDungeonStageListItem:initUI(t_data)
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SecretDungeonStageListItem:initButton()
    local vars = self.vars
    vars['enterButton']:registerScriptTapHandler(function() self:enterButton() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SecretDungeonStageListItem:refresh(t_data)
    local vars = self.vars

    do -- 스테이지 이름
        local name = Str(self.m_stageTable['t_name'])
        vars['dungeonNameLabel']:setString(name)
    end

    do -- 스태미나 갯수 표시
        local cost_value = self.m_stageTable['cost_value']
        vars['actingPowerLabel']:setString(comma_value(cost_value))
    end

    do -- 오픈 여부
        local stage_id = self.m_stageTable['stage']
        local is_open = g_stageData:isOpenStage(stage_id)

        vars['lockNode']:setVisible(not is_open)
        vars['enterButton']:setVisible(is_open)
    end

    --[[
    do -- 보스 썸네일 표시
        local table_stage_desc = TableStageDesc()
        local stage_id = self.m_stageTable['stage']
        local icon = table_stage_desc:getLastMonsterIcon(stage_id)
        vars['iconNode']:addChild(icon.root)
    end
    ]]--

    do -- 제한 인원
        vars['numberLabel']:setString('0 / 10')
    end
end

-------------------------------------
-- function update
-------------------------------------
function UI_SecretDungeonStageListItem:update(dt)
    local stage_id = self.m_stageTable['stage']
    local text = g_secretDungeonData:getSecretDungeonRemainTimeText(stage_id)

    -- 텍스트가 변경되었을 때에만 문자열 변경
    if (self.m_remainTimeText ~= text) then
        self.m_remainTimeText = text
        self.vars['timeLabel']:setString(text)
        
        do -- 텍스트 변경됨을 알리는 액션
            self.vars['timeLabel']:stopAllActions()
            local start_action = cc.MoveTo:create(0.05, cc.p(-20, -223))
            local end_action = cc.EaseElasticOut:create(cc.MoveTo:create(0.5, cc.p(0, -223)), 0.2)
            self.vars['timeLabel']:runAction(cc.Sequence:create(start_action, end_action))
        end
        
    end
end

-------------------------------------
-- function enterButton
-------------------------------------
function UI_SecretDungeonStageListItem:enterButton()
    local stage_id = self.m_stageTable['stage']
    UI_AdventureStageInfo(stage_id)
end