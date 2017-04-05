-------------------------------------
-- function getSkillDescStr
-------------------------------------
function UI_RuneCard(t_rune_data)
    local rid = t_rune_data['rid']
    local item_count = 1
    local ui = UI_ItemCard(rid, item_count, t_rune_data)
    return ui
end