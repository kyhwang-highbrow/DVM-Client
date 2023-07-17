local PARENT = UI_NestDungeonStageListItem

-------------------------------------
-- class UI_NightmareStageListItem
-------------------------------------
UI_NightmareStageListItem = class(PARENT, {
        m_stageTable = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_NightmareStageListItem:init(t_data)
end

-------------------------------------
-- function refresh_dropItem
-- @brief 드랍 아이템 표시
-------------------------------------
function UI_NightmareStageListItem:refresh_dropItem(t_data)
    local vars = self.vars
    local stage_id = self.m_stageTable['stage']
    local game_mode = g_stageData:getGameMode(t_data['stage'])

    local t_dungeon = g_nestDungeonData:parseNestDungeonID(stage_id)

    local tier = t_dungeon['tier']

    local l_icon_res = {}
    if (tier == 1) then
        table.insert(l_icon_res, 'star_23.png')
        table.insert(l_icon_res, 'set_all_03.png')

    elseif (tier == 2) then
        table.insert(l_icon_res, 'star_24.png')
        table.insert(l_icon_res, '02_all_04.png')
        table.insert(l_icon_res, '01_all_04.png')

    elseif (tier == 3) then
        table.insert(l_icon_res, 'star_24.png')
        table.insert(l_icon_res, '04_all_04.png')
        table.insert(l_icon_res, '03_all_04.png')
    
    elseif (tier == 4) then
        table.insert(l_icon_res, 'star_24.png')
        table.insert(l_icon_res, '06_all_04.png')
        table.insert(l_icon_res, '05_all_04.png')
    
    elseif (tier == 5) then
        table.insert(l_icon_res, 'star_35.png')
        table.insert(l_icon_res, 'set_all_05.png')
    
    elseif (tier == 6) then
        table.insert(l_icon_res, 'star_36.png')
        table.insert(l_icon_res, 'set_all_06.png')
    
    elseif (tier == 7) then
        table.insert(l_icon_res, 'star_46.png')
        table.insert(l_icon_res, '02_all_06.png')
        table.insert(l_icon_res, '01_all_06.png')
    
    elseif (tier == 8) then
        table.insert(l_icon_res, 'star_46.png')
        table.insert(l_icon_res, '04_all_06.png')
        table.insert(l_icon_res, '03_all_06.png')
    
    elseif (tier == 9) then
        table.insert(l_icon_res, 'star_46.png')
        table.insert(l_icon_res, '06_all_06.png')
        table.insert(l_icon_res, '05_all_06.png')
    
    elseif (tier >= 10) then
        table.insert(l_icon_res, 'star_46.png')
        table.insert(l_icon_res, 'set_all_06.png')
    end

    for i,res in ipairs(l_icon_res) do
        if (i == 1) then
            local icon = IconHelper:getIcon('res/ui/icons/rune/' .. res)
            vars['rewardNode' .. i]:addChild(icon)
        else
            local frame = IconHelper:getIcon('ui/a2d/card/card_item_frame.png')
            local icon = IconHelper:getIcon('res/ui/icons/rune/' .. res)
            frame:addChild(icon)
            vars['rewardNode' .. i]:addChild(frame)
        end
        
    end

    -- 악몽 던전 소비 활동력 핫타임 관련
    if (game_mode == GAME_MODE_NEST_DUNGEON) then
        local t_dungeon = g_nestDungeonData:parseNestDungeonID(stage_id)
        local dungeonMode = t_dungeon['dungeon_mode']
        if (dungeonMode == NEST_DUNGEON_NIGHTMARE) then
            local type = 'dg_nm_st_dc'
            self:initStaminaFevertimeUI(vars, stage_id, type)
        end
    end
end