local PARENT = UI_NestDungeonStageListItem

-------------------------------------
-- class UI_IllusionStageListItem
-------------------------------------
UI_IllusionStageListItem = class(PARENT, {
    })

UI_IllusionStageListItem.DIFF = {['normal'] = Str('보통'), ['hard'] = Str('어려움'), ['hell'] = Str('지옥'), ['hellfire'] = Str('불지옥') } 

-------------------------------------
-- function refresh
-------------------------------------
function UI_IllusionStageListItem:refresh(t_data)
    local vars = self.vars
    local table_stage = TABLE:get('stage_data')
    local stage_id = t_data['stage']

    do -- 난이도 별 최고 점수
        local diff_number = g_illusionDungeonData:parseStageID(stage_id)
        local best_score = g_illusionDungeonData:getBestScoreByDiff(diff_number)      
        vars['dungeonNameLabel']:setString(Str('내 최고 점수 : {1}점', comma_value(best_score)))
    end

    do -- 난이도
        local diff_str = table_stage[stage_id]['r_difficult']
        local diff_color = COLOR['diff_' .. diff_str]
        vars['dungeonLevelLabel']:setString(UI_IllusionStageListItem.DIFF[diff_str])
        vars['dungeonLevelLabel']:setColor(diff_color)
    end

    do -- 스태미나 갯수 표시
        local stamina_type, cost_value = TableDrop:getStageStaminaType(stage_id)
        vars['actingPowerLabel']:setString(comma_value(cost_value))
    end

    do -- 오픈 여부
        local struct_illusion = g_illusionDungeonData:getEventIllusionInfo()
        local last_stage_id = struct_illusion:getIllusionLastStage()
        if (g_illusionDungeonData:getNextStage(last_stage_id)) then
            local is_open = tonumber(stage_id) <= g_illusionDungeonData:getNextStage(last_stage_id)
            vars['lockNode']:setVisible(not is_open)
            vars['enterButton']:setVisible(is_open)
        -- 다음 스테이지 없을 경우, 무조건 풀어줌
        else
            vars['lockNode']:setVisible(false)
            vars['enterButton']:setVisible(true)
        end
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
    local stage_id = t_data['stage']

    local table_drop = TABLE:get('drop')
    local t_drop = table_drop[stage_id]

    local ui = UI_ItemCard(t_drop['item_1_id'], t_drop['item_1_min'])
    vars['rewardNode1']:addChild(ui.root)
    ui.root:setSwallowTouch(false)
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