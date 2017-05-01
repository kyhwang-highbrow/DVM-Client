local PARENT = class(UI, ITableViewCell:getCloneTable())
-------------------------------------
-- class UI_RecommendedDragonInfoListItem_Dungeon
-------------------------------------
UI_RecommendedDragonInfoListItem_Dungeon = class(PARENT,{
		m_dungeonInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_RecommendedDragonInfoListItem_Dungeon:init(info)
    self:load('dragon_ranking_dungeon_item.ui')

	self.m_dungeonInfo = info

    self:initUI()
    self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RecommendedDragonInfoListItem_Dungeon:initUI()
    local vars = self.vars

	local dungeon_name = Str(self.m_dungeonInfo['t_name'])
	vars['dungeonLabel']:setString(dungeon_name)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RecommendedDragonInfoListItem_Dungeon:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RecommendedDragonInfoListItem_Dungeon:refresh(mode_id)
	local is_selected = (mode_id == self.m_dungeonInfo['mode_id'])
	self.vars['dungeonBtn']:setEnabled(not is_selected)
end

--@CHECK
UI:checkCompileError(UI_RecommendedDragonInfoListItem_Dungeon)
