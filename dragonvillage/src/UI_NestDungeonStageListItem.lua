local PARENT = class(UI, ITableViewCell:getCloneTable(), UI_FevertimeUIHelper:getCloneTable())

-------------------------------------
-- class UI_NestDungeonStageListItem
-------------------------------------
UI_NestDungeonStageListItem = class(PARENT, {
        m_stageTable = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_NestDungeonStageListItem:init(t_data)
    local vars = self:load('dungeon_stage_item.ui')

    if (not t_data['stage']) then
        return
    end
    self.m_stageTable = t_data

    self:initUI(t_data)
    self:initButton()
    self:refresh(t_data)

    --self.root:setDockPoint(cc.p(0, 0))
    --self.root:setAnchorPoint(cc.p(0, 0))
end
-------------------------------------
-- function initUI
-------------------------------------
function UI_NestDungeonStageListItem:initUI(t_data)
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
function UI_NestDungeonStageListItem:initButton()
    local vars = self.vars
    vars['enterButton']:registerScriptTapHandler(function() self:enterButton() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_NestDungeonStageListItem:refresh(t_data)
    local vars = self.vars
    local game_mode = g_stageData:getGameMode(t_data['stage'])
    local stage_id = self.m_stageTable['stage']

    do -- 스테이지 이름
        local name = Str(self.m_stageTable['t_name'])
        vars['dungeonNameLabel']:setString(name)
    end

    do -- 티어 표시
        local stage_id = self.m_stageTable['stage']
        local t_dungeon_id_info = g_nestDungeonData:parseNestDungeonID(stage_id)
        local tier = t_dungeon_id_info['tier']
        local str = Str('{1}단계', tier)

        vars['dungeonLevelLabel']:setString(str)
    end

    do -- 스태미나 갯수 표시
        local cost_value = self.m_stageTable['cost_value']
        vars['actingPowerLabel']:setString(comma_value(cost_value))
    end

    -- 거목 던전 소비 활동력 핫타임 관련
    if (game_mode == GAME_MODE_NEST_DUNGEON) then
        local t_dungeon = g_nestDungeonData:parseNestDungeonID(stage_id)
        local dungeonMode = t_dungeon['dungeon_mode']
        if (dungeonMode == NEST_DUNGEON_TREE) then
            local type = 'dg_gt_st_dc'
            self:initStaminaFevertimeUI(vars, stage_id, type)
        end
    end

    -- 거대용 던전 소비 활동력 핫타임 관련
    if (game_mode == GAME_MODE_NEST_DUNGEON) then
        local t_dungeon = g_nestDungeonData:parseNestDungeonID(stage_id)
        local dungeonMode = t_dungeon['dungeon_mode']
        if (dungeonMode == NEST_DUNGEON_EVO_STONE) then
            local type = 'dg_gd_st_dc'
            self:initStaminaFevertimeUI(vars, stage_id, type)
        end
    end

    do -- 오픈 여부
        local stage_id = self.m_stageTable['stage']
        local is_open = g_stageData:isOpenStage(stage_id)

        vars['lockNode']:setVisible(not is_open)
        vars['enterButton']:setVisible(is_open)
    end

    do -- 보스 썸네일 표시
        local table_stage_desc = TableStageDesc()
        local stage_id = self.m_stageTable['stage']
        local icon = table_stage_desc:getLastMonsterIcon(stage_id)
        icon.root:setSwallowTouch(false)
        vars['iconNode']:addChild(icon.root)
    end

    -- 드랍 아이템 표시
    self:refresh_dropItem(t_data)
end

-------------------------------------
-- function refresh_dropItem
-- @brief 드랍 아이템 표시
-------------------------------------
function UI_NestDungeonStageListItem:refresh_dropItem(t_data)
    local vars = self.vars
    local stage_id = self.m_stageTable['stage']

    -- 네스트던전의 보너스 아이템 항목을 얻어옴
    local nest_dungeon_id = g_nestDungeonData:getDungeonIDFromStateID(stage_id)
    local t_nest_dungeon_info = g_nestDungeonData.m_nestDungeonInfoMap[nest_dungeon_id]
    local l_bonus_item = {}
    if (t_nest_dungeon_info['bonus_rate'] > 0) then
        l_bonus_item = seperate(t_nest_dungeon_info['bonus_value'], ',')
    end

    local drop_helper = DropHelper(stage_id)
    local l_item_list = drop_helper:getDisplayItemList()

    for i=1, 4 do
        local item_id = l_item_list[i]
        if item_id then
            local ui = UI_ItemCard(item_id)
            vars['rewardNode' .. i]:addChild(ui.root)
            ui.root:setSwallowTouch(false)
            --ui.root:setScale(0.55)

            -- 보너스 아이템일 경우 @TODO sgkim 보너스 뱃지 붙여줄 것
            if table.find(l_bonus_item, tostring(item_id)) then
                --cclog('###### find!! ' .. item_id)
            end
        end
    end
end

-------------------------------------
-- function enterButton
-------------------------------------
function UI_NestDungeonStageListItem:enterButton()
    local stage_id = self.m_stageTable['stage']
    UI_AdventureStageInfo(stage_id)
end