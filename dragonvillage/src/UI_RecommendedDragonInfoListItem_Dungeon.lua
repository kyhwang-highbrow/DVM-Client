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

    vars['btnNode']:removeAllChildren(true)
    local dungeon_btn_spr = self:getDungeonBtnSpr()
    vars['btnNode']:addChild(dungeon_btn_spr)
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
    local vars = self.vars
	local is_selected = (mode_id == self.m_dungeonInfo['mode_id'])
	vars['dungeonBtn']:setEnabled(not is_selected)
    vars['selectSprite']:setVisible(is_selected)
end

-------------------------------------
-- function getDungeonBtnSpr
-------------------------------------
function UI_RecommendedDragonInfoListItem_Dungeon:getDungeonBtnSpr()
    local mode = self.m_dungeonInfo['mode']
    local sub_mode = self.m_dungeonInfo['sub_mode']
    local attr = attributeNumToStr(sub_mode) or 'gem'
    
    local name

    -- dragon
    if (mode == 1) then
        name = string.format('dragon_ranking_%s_%s', 'dragon', attr)
    -- nightmare
    elseif (mode == 2) then
        name = string.format('dragon_ranking_%s', 'nightmare')
    -- tree
    elseif (mode == 3) then
        name = string.format('dragon_ranking_%s_%s', 'tree', attr)
    end
   
    local res = string.format('res/ui/buttons/%s.png', name)
    return IconHelper:getIcon(res)
end

--@CHECK
UI:checkCompileError(UI_RecommendedDragonInfoListItem_Dungeon)
