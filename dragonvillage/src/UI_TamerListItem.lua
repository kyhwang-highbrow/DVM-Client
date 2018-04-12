local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_TamerListItem
-------------------------------------
UI_TamerListItem = class(PARENT, {
        m_tamerData = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_TamerListItem:init(tamer_data)
    local vars = self:load('tamer_manage_scene_item.ui')
    self.m_tamerData = tamer_data

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_TamerListItem:initUI()
    local vars = self.vars
    local tamer_data = self.m_tamerData

    -- 이름
    vars['tamerNameLabel']:setString(Str(tamer_data['t_name']))
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_TamerListItem:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_TamerListItem:refresh()
    local vars = self.vars
    local tamer_data = self.m_tamerData

    -- 이미지 (적용중인 코스튬 있을 경우 코스튬 SD 이미지로)
    local tid = tamer_data['tid']
    local coustume_data = g_tamerCostumeData:getUsedStructCostumeData(tid)
    local icon = coustume_data:getTamerSDIcon()
	if (icon) then
        vars['tamerNode']:removeAllChildren(true)
		vars['tamerNode']:addChild(icon)
	end

    -- 잠금
    local has_tamer = g_tamerData:hasTamer(tid)
    vars['lockSprite']:setVisible(not has_tamer)

    -- 사용중
    local is_use = (g_tamerData:getCurrTamerID() == tid)
    vars['useSprite']:setVisible(is_use)
end