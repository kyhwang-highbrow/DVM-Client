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
    local vars = self:load('secret_dungeon_stage_item.ui')

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

    do -- 스테이지에 해당하는 스테미나 아이콘 생성
        local stage_id = self.m_stageTable['stage']
        local type = TableDrop:getStageStaminaType(stage_id)
        local icon = IconHelper:getStaminaInboxIcon(type)
        vars['staminaNode']:addChild(icon)
    end
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

    local dungeon_id = self.m_stageTable['id']
    local stage_id = self.m_stageTable['stage']
    local t_drop = TableDrop():get(stage_id)

    do -- 스테이지 이름
        local did = t_data['dragon']
        local dragon_name = TableDragon:getDragonName(did)        
        vars['dungeonNameLabel']:setString(dragon_name)
    end

    do -- 발견자
        local nickname = self.m_stageTable['nick']
        vars['userNameLabel']:setString(Str('발견 : {1}', nickname))
    end

    do -- 스태미나 갯수 표시
        local cost_value = t_drop['cost_value']
        vars['actingPowerLabel']:setString(comma_value(cost_value))
    end

    do -- 오픈 여부
        vars['lockNode']:setVisible(false)
        vars['enterButton']:setVisible(true)
    end

    do -- 보스 썸네일 표시
        local icon = g_secretDungeonData:getLastMonsterIcon(dungeon_id)
        vars['iconNode']:addChild(icon.root)
    end
    
    do -- 제한 인원
        local cnt = self.m_stageTable['players']
        local max_cnt = self.m_stageTable['maximum_playable_user']
        vars['numberLabel']:setString(Str('제한 인원 : {1} / {2}', cnt, max_cnt))
    end
end

-------------------------------------
-- function update
-------------------------------------
function UI_SecretDungeonStageListItem:update(dt)
    local id = self.m_stageTable['id']
    local text = g_secretDungeonData:getSecretDungeonRemainTimeText(id)

    -- 텍스트가 변경되었을 때에만 문자열 변경
    if (self.m_remainTimeText ~= text) then
        self.m_remainTimeText = text
        self.vars['timeLabel']:setString(text)
    end
end

-------------------------------------
-- function enterButton
-------------------------------------
function UI_SecretDungeonStageListItem:enterButton()
    local id = self.m_stageTable['id']
    g_secretDungeonData:selectDungeonID(id)

    local stage_id = self.m_stageTable['stage']
    UI_AdventureStageInfo(stage_id)
end