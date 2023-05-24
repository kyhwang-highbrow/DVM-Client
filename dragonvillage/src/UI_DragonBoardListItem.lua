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
	local tid = t_data['tamer']
	if (tid == 0) then
		tid = 110002
	end
    -- 코스튬 적용
    local icon
    local costume_id = t_data['costume']
    if (costume_id) then
        icon = IconHelper:getTamerProfileIconWithCostumeID(costume_id)
    else
        local type = TableTamer:getTamerType(tid)
        icon = IconHelper:getTamerProfileIcon(type)
    end

    vars['profileNode']:removeAllChildren()
    if (icon) then
        vars['profileNode']:addChild(icon)
    end
    
	-- 작성 시간
	local date = pl.Date()
	date:set(t_data['date']/1000)
	local date_format = pl.Date.Format('yyyy.mm.dd')
	local review_time = date_format:tostring(date)
	vars['timeLabel']:setString(review_time)
	
	-- 내용
	local review = ConvertBanWordOverlay(t_data['review'])
	self:setContentWithAdjHeight(review)

	-- 내가 쓴 리뷰 처리
	local is_mine = (t_data['uid'] == g_userData:get('uid'))
	if (is_mine) then
		vars['assessMySprite']:setVisible(true)
		vars['recommandBtn']:setVisible(false)
		vars['deleteBtn']:setVisible(true)
	end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonBoardListItem:initButton()
	local vars = self.vars

	vars['recommandBtn']:registerScriptTapHandler(function() self:click_recommandBtn() end)
	-- vars['deleteBtn'] -> 외부에서 등록
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonBoardListItem:refresh()
	local vars = self.vars
	local t_data = self.m_tBoard

	-- 좋아요
	local like_cnt = t_data['like']
	vars['recommandLabel']:setString(like_cnt)
end

-------------------------------------
-- function setContentWithAdjHeight
-------------------------------------
function UI_DragonBoardListItem:setContentWithAdjHeight(review)
	local vars = self.vars

	-- set string (line 수를 알기 위해 사전에 함)
	vars['assessLabel']:setString(review)
	vars['assessLabel']:setLineBreakWithoutSpace(true)
	local line = vars['assessLabel']:getStringNumLines()

	if (line > 3) then
		-- line수에 따라 label 영역 계산
		local label_size = vars['assessLabel'].m_node:getContentSize()
		local label_height = vars['assessLabel']:getTotalHeight()
		vars['assessLabel'].m_node:setDimensions(label_size['width'], label_height)

		-- label 보다 길도록 배경 사이즈 조정
		local bg_size = vars['assessSprite']:getContentSize()
		local bg_height = label_height + 15
		vars['assessSprite']:setNormalSize(bg_size['width'], bg_height)
		vars['assessMySprite']:setNormalSize(bg_size['width'], bg_height)

		-- 배경보다 길도록 container 사이즈 조정
		local con_size = vars['container']:getContentSize()
		local con_height = bg_height + 50
		local new_size = cc.size(con_size['width'], con_height)
		vars['container']:setNormalSize(con_size['width'], con_height)
		
		-- cell size 저장
		self:setCellSize(new_size)
	end
end

-------------------------------------
-- function click_recommandBtn
-------------------------------------
function UI_DragonBoardListItem:click_recommandBtn()
	if (not self.m_tBoard['likeable']) then
		UIManager:toastNotificationGreen(Str('이미 추천하셨어요.'))
		return
	end

	local function cb_func(t_data)
		self.m_tBoard = t_data
		self:refresh()
	end
	local revid = self.m_tBoard['id']
	g_boardData:request_likeBoard(nil, revid , cb_func)
end

-------------------------------------
-- function click_deleteBtn
-------------------------------------
function UI_DragonBoardListItem:click_deleteBtn(cb_func)
	local like_cnt = self.m_tBoard['like']
	local revid = self.m_tBoard['id']
	local function delete_func()
		g_boardData:request_deleteBoard(revid, nil)
		cb_func()
	end

	if (like_cnt > 0) then
		MakeSimplePopup(POPUP_TYPE.YES_NO, Str('추천이 존재합니다. 정말 삭제하시겠습니까?'), delete_func, nil)
	else
		delete_func()
	end
end

--@CHECK
UI:checkCompileError(UI_DragonBoardListItem)
