-------------------------------------
-- function make_child_menu
-------------------------------------
local make_child_menu = function(self, ui_name, ui_depth)
  
end

-------------------------------------
-- function set_after
-------------------------------------
local set_after = function(ui_name, ui)

    if (ui_name == 'rune_guide_popup.ui') then
         local sub_ui = UI()
         sub_ui:load('rune_info_board.ui')
         vars = sub_ui.vars
         ui.vars['runeScNode']:removeAllChildren()
         ui.vars['runeScNode']:addChild(sub_ui.root)

         local t_rune_data = {}
         t_rune_data["lv"] = 15
         t_rune_data["id"] = "59b32f37476c0d2426b52139"
         t_rune_data["mopt"] = "atk_multi;46"
         t_rune_data["created_at"] = 1504915255534
         t_rune_data["sopt_2"] = "cri_dmg_add;6"
         t_rune_data["sopt_4"] = "cri_chance_add;8"
         t_rune_data["rid"] = 710646
         t_rune_data["rarity"] = 4
         t_rune_data["sopt_1"] = "hit_rate_add;6"
         t_rune_data["updated_at"] = 1514044721832
         t_rune_data["sopt_3"] = "hp_multi;7"
         t_rune_data["uopt"] = "avoid_add;4"
         t_rune_data["lock"] = false
         local rune_obj = StructRuneObject(t_rune_data)

         -- 룬 아이콘 삭제
         vars['runeNode']:removeAllChildren()
         vars['useRuneNameLabel']:setString('')
         vars['useMainOptionLabel']:setString('')
         vars['useSubOptionLabel']:setString('')
         vars['useRuneSetLabel']:setString('')

         -- 룬 명칭
         vars['useRuneNameLabel']:setString(rune_obj['name'])

         -- 룬 아이콘
         local rune_icon = UI_RuneCard(rune_obj)
         vars['runeNode']:addChild(rune_icon.root)

         -- 메인, 유니크 옵션
         vars['useMainOptionLabel']:setString(rune_obj:makeRuneDescRichText())

         -- 서브 옵션
         vars['useSubOptionLabel']:setString('')

         -- 세트 옵션
         vars['useRuneSetLabel']:setString(rune_obj:makeRuneSetDescRichText())

         do -- 레어도
             local color = rune_obj:getRarityColor()
             vars['useRuneNameLabel']:setColor(color)
             vars['useRarityNode']:setColor(color)

             local name = rune_obj:getRarityName()
             vars['useRarityLabel']:setString(name)
         end
     end   
end

-------------------------------------
-- function UI_HelpRune
-------------------------------------
function UI_HelpRune(...)
    local struct_tab_ui = StructTabUI()
    struct_tab_ui:setPrefix('help_')
    struct_tab_ui:setDefaultTab(...)
    struct_tab_ui:setAfterFunc(set_after)
    struct_tab_ui:setMakeChildMenuFunc(nil)
    return UI_TabUI_AutoGeneration('rune_guide_popup.ui', true, 1, struct_tab_ui) -- param ui_name, is_root, ui_depth, struct_tab_ui
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