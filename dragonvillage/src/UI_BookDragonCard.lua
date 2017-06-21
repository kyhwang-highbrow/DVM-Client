------------------------------------
-- function UI_BookDragonCard
-- @brief UI_characterCard ëí
-------------------------------------
function UI_BookDragonCard(t_dragon)
	local did = t_dragon['did']
	local evo = t_dragon['evolution'] or 1
	local grade_factor = (evo > 1) and 1 or 0
	
	local t_data = {}
	t_data['evolution'] = evo
	t_data['grade'] = t_dragon['birthgrade'] + grade_factor

    local ui = MakeSimpleDragonCard(did, t_data)
    local function func()
		UI_BookDetailPopup(t_dragon, t_data)
    end
    ui.vars['clickBtn']:registerScriptTapHandler(func)

    return ui
end