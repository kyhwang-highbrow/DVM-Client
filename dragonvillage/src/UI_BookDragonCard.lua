------------------------------------
-- function UI_BookDragonCard
-- @brief UI_characterCard ëí
-------------------------------------
function UI_BookDragonCard(t_dragon)
	local did = t_dragon['did']

	local t_data = {}
	t_data['evolution'] = t_dragon['evolution']
	t_data['grade'] = t_dragon['grade']

    local ui = MakeSimpleDragonCard(did, t_data)
    local function func()
		UI_BookDetailPopup(t_dragon, t_data)
    end
    ui.vars['clickBtn']:registerScriptTapHandler(func)

    return ui
end