-------------------------------------
-- function make_child_menu
-------------------------------------
local make_child_menu = function(ui_name, ui_depth)
    -- 클랜 던전
    if (ui_name == 'help_clan_dungeon_summary.ui') then
        return UI_HelpClanDungeonSummary(ui_name, false, ui_depth, self) -- param : ui_name, is_root, ui_depth, struct_tab_ui

    -- 클랜 던전 보상
    elseif (ui_name == 'help_clan_dungeon_reward.ui') then
        return UI_HelpClanDungeonReward(ui_name, false, ui_depth, self) -- param : ui_name, is_root, ui_depth, struct_tab_ui
        
    end
end

-------------------------------------
-- function UI_HelpClan
-------------------------------------
function UI_HelpClan(...)
    local struct_tab_ui = StructTabUI()
    struct_tab_ui:setPrefix('help_')
    struct_tab_ui:setDefaultTab(...)
    struct_tab_ui:setMakeChildMenuFunc(make_child_menu)
    return UI_TabUI_AutoGeneration('help_clan2.ui', true, 1, struct_tab_ui) -- param ui_name, is_root, ui_depth, struct_tab_ui
end


-- # 접두어로 'help_'가 붙음
-- clan
--      clan_summary
--      clan_level
--      clan_dungeon
--          clan_dungeon_summary
--              cldg_summary
--              cldg_boss_info
--              cldg_attr_bonus
--              cldg_finalblow
--          clan_dungeon_reward
--              cldg_reward1(한 판 보상)
--              cldg_reward2(보스 처치 보상)
--              cldg_reward3(시즌 보상)
--      rune_guardian_dungeon
--          rune_guardian_summary
--          rune_guardian_probability