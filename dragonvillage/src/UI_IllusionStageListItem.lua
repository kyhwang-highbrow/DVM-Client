local PARENT = UI_NestDungeonStageListItem

-------------------------------------
-- class UI_IllusionStageListItem
-------------------------------------
UI_IllusionStageListItem = class(PARENT, {
    })

UI_IllusionStageListItem.DIFF = {['normal'] = Str('쉬움'), ['hard'] = Str('보통'), ['hell'] = Str('지옥'), ['hellfire'] = Str('불지옥') } 

-------------------------------------
-- function refresh
-------------------------------------
function UI_IllusionStageListItem:refresh(t_data)
    local vars = self.vars
    local table_stage = TABLE:get('stage_data')
    local stage_id = t_data['stage']

    do -- 스테이지 이름
        local name = g_stageData:getStageName(stage_id)
        vars['dungeonNameLabel']:setString(name)
    end

    do -- 난이도
        local diff_str = table_stage[stage_id]['r_difficult']
        local diff_color = COLOR['diff_' .. diff_str]
        vars['dungeonLevelLabel']:setString(UI_IllusionStageListItem.DIFF[diff_str])
        vars['dungeonLevelLabel']:setColor(diff_color)
        vars['dungeonNameLabel']:setVisible(false)
    end

    do -- 스태미나 갯수 표시
        local stamina_type, cost_value = TableDrop:getStageStaminaType(stage_id)
        vars['actingPowerLabel']:setString(comma_value(cost_value))
    end

    do -- 오픈 여부
        --[[
        local stage_id = self.m_stageTable['stage']
        local is_open = g_stageData:isOpenStage(stage_id)

        vars['lockNode']:setVisible(not is_open)
        vars['enterButton']:setVisible(is_open)
        --]]
    end

    do -- 보스 썸네일 표시
        local table_stage_desc = TableStageDesc()
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
function UI_IllusionStageListItem:refresh_dropItem(t_data)
    local vars = self.vars
    --[[
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
    --]]
end

-------------------------------------
-- function enterButton
-------------------------------------
function UI_IllusionStageListItem:enterButton()
    local stage_id = self.m_stageTable['stage']
    self:click_dungeonBtn(stage_id)
end

-------------------------------------
-- function click_dungeonBtn
-------------------------------------
function UI_IllusionStageListItem:click_dungeonBtn(stage_id)
    -- 선택한 스테이지 저장
    local struct_illusion = g_illusionDungeonData:getEventIllusionInfo()
    struct_illusion:setCurIllusionStageId(stage_id)
    
    UI_AdventureStageInfo_IllusionDungeon(stage_id)
end