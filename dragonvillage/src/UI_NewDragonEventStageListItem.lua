local PARENT = class(UI, ITableViewCell:getCloneTable(), UI_FevertimeUIHelper:getCloneTable())

-------------------------------------
-- class UI_NewDragonEventStageListItem
-------------------------------------
UI_NewDragonEventStageListItem = class(PARENT, {
    m_stageId = 'number',
})

-------------------------------------
-- function init
-------------------------------------
function UI_NewDragonEventStageListItem:init(stage_id)
    local vars = self:load('dungeon_item.ui')
    self.m_stageId = stage_id
    self:initUI()
    self:initButton()
    self:refresh()
    --self.root:setDockPoint(cc.p(0, 0))
    --self.root:setAnchorPoint(cc.p(0, 0))
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_NewDragonEventStageListItem:initUI()
    local vars = self.vars
    do -- 스테이지에 해당하는 스테미나 아이콘 생성
        local stage_id = self.m_stageId
        local type = TableDrop:getStageStaminaType(stage_id)
        local icon = IconHelper:getStaminaInboxIcon(type)
        vars['staminaNode']:addChild(icon)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_NewDragonEventStageListItem:initButton()
    local vars = self.vars
    vars['enterButton']:registerScriptTapHandler(function() self:enterButton() end)

end

-------------------------------------
-- function refresh
-------------------------------------
function UI_NewDragonEventStageListItem:refresh(t_data)
    local vars = self.vars
    --local game_mode = g_stageData:getGameMode(t_data['stage'])
    local stage_id = self.m_stageId

    do -- 스테이지 이름
        local name = TableStageData():getValue(stage_id, 't_name')
        vars['dungeonNameLabel']:setString(Str(name))
    end

    do -- 티어 표시
        local t_dungeon_id_info = g_nestDungeonData:parseNestDungeonID(stage_id)
        local tier = t_dungeon_id_info['tier']
        local str = Str('{1}단계', tier)

        vars['dungeonLevelLabel']:setString(str)
    end

    do -- 스태미나 갯수 표시
        local type, cost_value = TableDrop:getStageStaminaType(stage_id)
        vars['actingPowerLabel']:setString(comma_value(cost_value))
    end

    do -- 보스 썸네일 표시
        local table_stage_desc = TableStageDesc()
        local icon = table_stage_desc:getLastMonsterIcon(stage_id)
        icon.root:setSwallowTouch(false)
        vars['iconNode']:addChild(icon.root)
    end

    -- 드랍 아이템 표시
    self:refresh_dropItem()
end

-------------------------------------
-- function refresh_dropItem
-- @brief 드랍 아이템 표시
-------------------------------------
function UI_NewDragonEventStageListItem:refresh_dropItem()
    local vars = self.vars
    local stage_id = self.m_stageId
    local drop_helper = DropHelper(stage_id)
    local l_item_list = drop_helper:getDisplayItemList()

    for i=1, 4 do
        local item_id = l_item_list[i]
        if item_id then
            local ui = UI_ItemCard(item_id)
            vars['rewardNode' .. i]:addChild(ui.root)
            ui.root:setSwallowTouch(false)
        end
    end
end

-------------------------------------
-- function enterButton
-------------------------------------
function UI_NewDragonEventStageListItem:enterButton()
    --local stage_id = self.m_stageId
    --UI_AdventureStageInfo(stage_id)
end
