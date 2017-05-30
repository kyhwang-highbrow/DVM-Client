local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_DragonBoardListItem
-------------------------------------
UI_DragonBoardListItem = class(PARENT,{
		m_tBoard = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonBoardListItem:init(t_data)
    -- UI load
	self:load('dragon_board_item.ui')
	self.m_tBoard = t_data
	ccdump(t_data)
	
	-- initialize
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonBoardListItem:initUI()
	local vars = self.vars
	local t_data = self.m_tBoard

	-- 작성자 lv + 닉네임
	local lv = t_data['lv']
	local nick = t_data['nick']
	local reviewer = string.format('Lv. %d %s', lv, nick)
	vars['infoLabel']:setString(reviewer)

	-- 테이머 아이콘 갱신
    local type = g_tamerData:getCurrTamerTable('type')
    local icon = IconHelper:getTamerProfileIcon(type)
    vars['profileNode']:removeAllChildren()
    vars['profileNode']:addChild(icon)

	-- 작성 시간
	local date = pl.Date()
	date:set(t_data['date']/1000)
	local date_format = pl.Date.Format('yyyy.mm.dd')
	local review_time = date_format:tostring(date)
	vars['timeLabel']:setString(review_time)
	
	-- 내용
	local review = t_data['review']
	vars['assessLabel']:setString(review)

	-- 배경 처리
	local is_mine = (nick == g_userData:get('nick'))
	if (is_mine) then
		vars['assessMySprite']:setVisible(true)
	end

	-- 좋아요
	local like_cnt = t_data['like']
	vars['recommandLabel']:setString(like_cnt)

	-- 좋아요 버튼 처리
	local is_likeable = (t_data['likeable'] and (not is_mine))
	vars['recommandBtn']:setEnabled(is_likeable)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonBoardListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonBoardListItem:refresh()
end

--@CHECK
UI:checkCompileError(UI_DragonBoardListItem)
