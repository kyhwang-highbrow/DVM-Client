local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_TamerManageItem
-------------------------------------
UI_TamerManageItem = class(PARENT, {
        m_tamerID = 'number',
		m_tamerTable = 'table',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_TamerManageItem:init(t_tamer)
    local vars = self:load('tamer_manage_scene_item.ui')
	
	self.m_tamerID = t_tamer['tid']
	self.m_tamerTable = t_tamer

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_TamerManageItem:initUI()
	local vars = self.vars
	local t_tamer = self.m_tamerTable

	-- 테이머 초상
	local tamer_type = t_tamer['type']
	local profile_icon = IconHelper:getTamerProfileIcon(tamer_type)
    vars['tamerNode']:addChild(profile_icon)

	-- 테이머 이름
	local tamer_name = t_tamer['t_name']
	vars['tamerNameLabel']:setString(Str(tamer_name))
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_TamerManageItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_TamerManageItem:refresh()
end

-------------------------------------
-- function selectTamer
-------------------------------------
function UI_TamerManageItem:selectTamer(is_select)
	-- 선택 표시
	self.vars['selectSprite']:setVisible(is_select)

	-- 선택 액션
	self.root:stopAllActions()
	local time = 0.2
	if (is_select) then
		local move_action = cc.EaseIn:create(cc.MoveTo:create(time, cc.p(0, 20)), 2)
		self.root:runAction(move_action)
	else
		local move_action = cc.EaseIn:create(cc.MoveTo:create(time, cc.p(0, 0)), 2)
		self.root:runAction(move_action)
	end
end

-------------------------------------
-- function setUseTamer
-------------------------------------
function UI_TamerManageItem:setUseTamer(is_use)
	-- 사용중 표시
	self.vars['useSprite']:setVisible(is_use)
end

-------------------------------------
-- function getTamerId
-------------------------------------
function UI_TamerManageItem:getTamerId()
	return self.m_tamerID
end

-------------------------------------
-- function getTamerTable
-------------------------------------
function UI_TamerManageItem:getTamerTable()
	return self.m_tamerTable
end