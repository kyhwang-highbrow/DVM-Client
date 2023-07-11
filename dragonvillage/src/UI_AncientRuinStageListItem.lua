local PARENT = UI_NestDungeonStageListItem

-------------------------------------
-- class UI_AncientRuinStageListItem
-------------------------------------
UI_AncientRuinStageListItem = class(PARENT, {
        m_stageTable = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_AncientRuinStageListItem:init(t_data)
end

-------------------------------------
-- function refresh_dropItem
-- @brief 드랍 아이템 표시
-------------------------------------
function UI_AncientRuinStageListItem:refresh_dropItem(t_data)
    local vars = self.vars
    local stage_id = self.m_stageTable['stage']
    local game_mode = g_stageData:getGameMode(t_data['stage'])

    -- 네스트던전의 보너스 아이템 항목을 얻어옴
    local nest_dungeon_id = g_nestDungeonData:getDungeonIDFromStateID(stage_id)
    local t_nest_dungeon_info = g_nestDungeonData.m_nestDungeonInfoMap[nest_dungeon_id]
    local l_bonus_item = {}
    if (t_nest_dungeon_info['bonus_rate'] > 0) then
        l_bonus_item = seperate(t_nest_dungeon_info['bonus_value'], ',')
    end

    local drop_helper = DropHelper(stage_id)
    local l_item_list = drop_helper:getDisplayItemList()

    local t_dungeon = g_nestDungeonData:parseNestDungeonID(stage_id)
    local tier = t_dungeon['tier']

    -- 추가로 별표시 
    if (tier == 1) then
        table.insert(l_item_list, 'star_36.png')

    elseif (tier == 2) then
        table.insert(l_item_list, 'star_46.png')

    elseif (tier == 3) then
        table.insert(l_item_list, 'star_46.png')

    elseif (tier == 4) then
        table.insert(l_item_list, 'star_46.png')

    elseif (tier == 5) then
        table.insert(l_item_list, 'star_46.png')

    elseif (tier == 6) then
        table.insert(l_item_list, 'star_56.png')

    elseif (tier == 7) then
        table.insert(l_item_list, 'star_56.png')

    elseif (tier == 8) then
        table.insert(l_item_list, 'star_56.png')

    elseif (tier == 9) then
        table.insert(l_item_list, 'star_56.png')

    elseif (tier == 10) then
        table.insert(l_item_list, 'star_56.png')

    elseif (tier >= 11) then
        table.insert(l_item_list, 'star_56.png')
    end

    -- 고대 유적 던전 소비 활동력 핫타임 관련
    if (game_mode == GAME_MODE_ANCIENT_RUIN) then
        local type = 'dg_ar_st_dc'
        self:initStaminaFevertimeUI(vars, stage_id, type)
    end

    -- 별이 맨 앞으로 가도록 정렬
    table.sort(l_item_list, function(a,b)
        local a_value = string.find(tostring(a), 'star_') and 99 or 0
        local b_value = string.find(tostring(b), 'star_') and 99 or 0
        return a_value > b_value
    end)

    for i = 1, 4 do
        local item_id = l_item_list[i]
        if item_id then
            if string.find(item_id, 'star_') then
                local res = item_id
                local icon = IconHelper:getIcon('res/ui/icons/rune/' .. res)
                vars['rewardNode' .. i]:addChild(icon)
            else
                local ui = UI_ItemCard(item_id)
                vars['rewardNode' .. i]:addChild(ui.root)
                ui.root:setSwallowTouch(false)
            end
        end
    end
end