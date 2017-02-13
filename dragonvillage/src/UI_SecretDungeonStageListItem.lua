local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_SecretDungeonStageListItem
-------------------------------------
UI_SecretDungeonStageListItem = class(PARENT, {
        m_stageTable = 'table',
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

    --self.root:setDockPoint(cc.p(0, 0))
    --self.root:setAnchorPoint(cc.p(0, 0))
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
    
    -- 드랍 아이템 표시
    self:refresh_dropItem(t_data)
    ]]--
end

-------------------------------------
-- function refresh_dropItem
-- @brief 드랍 아이템 표시
-------------------------------------
function UI_SecretDungeonStageListItem:refresh_dropItem(t_data)
    local vars = self.vars
    local stage_id = self.m_stageTable['stage']

    -- 네스트던전의 보너스 아이템 항목을 얻어옴
    local secret_dungeon_id = g_secretDungeonData:getDungeonIDFromStateID(stage_id)
    local t_secret_dungeon_info = g_secretDungeonData.m_secretDungeonInfoMap[secret_dungeon_id]
    local l_bonus_item = {}
    if (t_secret_dungeon_info['bonus_rate'] > 0) then
        l_bonus_item = seperate(t_secret_dungeon_info['bonus_value'], ',')
    end

    local drop_helper = DropHelper(stage_id)
    local l_item_list = drop_helper:getDisplayItemList()

    for i=1, 4 do
        local item_id = l_item_list[i]
        if item_id then
            local ui = UI_ItemCard(item_id)
            vars['rewardNode' .. i]:addChild(ui.root)
            ui.root:setSwallowTouch(false)
            ui.root:setScale(0.55)

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
function UI_SecretDungeonStageListItem:enterButton()
    local stage_id = self.m_stageTable['stage']
    UI_AdventureStageInfo(stage_id)
end