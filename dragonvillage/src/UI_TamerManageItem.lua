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
function UI_TamerManageItem:init(t_tamer, new_user)
    local vars = self:load('tamer_manage_scene_item.ui')
	
	self.m_tamerID = t_tamer['tid']
	self.m_tamerTable = t_tamer

    self:initUI()
    self:initButton()

    -- 로그인 하지 않은 상태서 신규 계정 생성시에는 다른 서버 데이터 접근하면서 오류남
    if not new_user then 
        self:refresh() 
    end
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
	local vars = self.vars
	local t_tamer = self.m_tamerTable
	local tid = t_tamer['tid']

    -- 테이머 아이콘도 달아준다
    local name = t_tamer['type']
    local idx = g_tamerData:hasTamer(tid) and 1 or 2 -- 2는 미획득 상태 아이콘
    local res = string.format('res/ui/icons/tamer/tamer_manage_%s_01%02d.png', name, idx)
    local spr = IconHelper:getIcon(res)
    vars['tamerNode']:removeAllChildren()
    vars['tamerNode']:addChild(spr)

    -- noti도 붙이고
	if (g_tamerData:isObtainable(tid)) then
		vars['notiSprite']:setVisible(true)
	else
		vars['notiSprite']:setVisible(false)
	end
end

-------------------------------------
-- function selectTamer
-------------------------------------
function UI_TamerManageItem:selectTamer(is_select)
	-- 선택 표시
	self.vars['selectSprite']:setVisible(is_select)

	-- 선택 액션
	if (is_select) then
		self.root:setLocalZOrder(2)
        self.root:setScale(1)
        self.root:setPositionY(10)
	else
		self.root:setLocalZOrder(1)
        self.root:setScale(0.8)
        self.root:setPositionY(0)
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