local PARENT = class(UI, ITableViewCell:getCloneTable())

-- 나중에는 어딘가 적절한 테이블로 옮길 수도 있다.
local CLAN_BOARD_STR = {
    ['lvup'] = Str('클랜 {1}레벨 달성!'),
    ['join'] = Str('{1}님이 클랜에 가입했습니다. 환영합니다!'),
    ['exit'] = Str('{1}님이 클랜에서 탈퇴했습니다.'),
    ['kicked'] = Str('{1}님이 클랜에서 추방되었습니다.'),
}

-------------------------------------
-- class UI_ClanBoardListItem
-------------------------------------
UI_ClanBoardListItem = class(PARENT,{
        m_owner = '',
		m_tBoard = 'table',
    })

local SYSTEM_NOTICE = 'system'

-------------------------------------
-- function init
-------------------------------------
function UI_ClanBoardListItem:init(owner_ui, t_data)
    -- UI load
	self:load('clan_02_board_item.ui')
    self.m_owner = owner_ui
	self.m_tBoard = t_data

	-- initialize
	if (self.m_tBoard['uid'] == SYSTEM_NOTICE) then
		self:initUI_system()
	else
	    self:initUI()
	end
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanBoardListItem:initUI()
	local vars = self.vars
	local t_data = self.m_tBoard

	-- 작성자 lv + 닉네임
	local lv = t_data['lv']
	local nick = t_data['nick']
	local reviewer = string.format('Lv. %d %s', lv, nick)
	vars['infoLabel']:setString(reviewer)

    -- 대표 드래곤 적용
    vars['profileNode']:removeAllChildren()
    local t_dragon_data = self.m_tBoard['leader']
    local card = UI_DragonCard(StructDragonObject(t_dragon_data))
    local icon = card.root
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
	local review = t_data['text']
	self:setContentWithAdjHeight(review)

	-- 내가 쓴 리뷰 처리
	local is_mine = (t_data['uid'] == g_userData:get('uid'))
	if (is_mine) then
		vars['assessMySprite']:setVisible(true)
	end

    -- 내가 쓰거나 관리자면 삭제 가능
    local member_type = g_clanData:getMyMemberType()
    if (is_mine or member_type == 'master') or (member_type == 'manager') then
        vars['deleteBtn']:setVisible(true)
    end
end

-------------------------------------
-- function initUI_system
-------------------------------------
function UI_ClanBoardListItem:initUI_system()
	local vars = self.vars
	local t_data = self.m_tBoard

	-- 이름
	vars['infoLabel']:setString('{@apricot}SYSTEM')

	-- 프레임 처리
	vars['systemSprite']:setVisible(true)
	vars['profileSprite']:setVisible(false)
	vars['assessSystemSprite']:setVisible(true)

	-- 프사
	local icon = IconHelper:getSystemIcon()
	vars['profileNode']:addChild(icon)

	-- 작성 시간
	local date = pl.Date()
	date:set(t_data['date']/1000)
	local date_format = pl.Date.Format('yyyy.mm.dd')
	local review_time = date_format:tostring(date)
	vars['timeLabel']:setString(review_time)
	
	-- 내용
    do
        local org = t_data['text'] or '' -- "key;value1,value2,value3..."
    
        local l_split = plSplit(org, ';')
        local text_key = l_split[1]
        local l_value = plSplit(l_split[2], ',')

        -- 정의된 타입의 경우
        if (l_value) then
            local text_form = CLAN_BOARD_STR[text_key]
            self:setContentWithAdjHeight(Str(text_form, l_value[1], l_value[2]))

        -- 레거시 또는 오류
        else
            local org_text = t_data['text'] or ''
	        local _, _, lv = org_text:find('클랜 (%d+)레벨 달성!')
            if (lv) then
	            self:setContentWithAdjHeight(Str(CLAN_BOARD_STR['lvup'], lv or 0))
            else
                self:setContentWithAdjHeight('error')
            end
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanBoardListItem:initButton()
    local vars = self.vars
    vars['deleteBtn']:registerScriptTapHandler(function() self:click_deleteBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanBoardListItem:refresh()
	local vars = self.vars
end

-------------------------------------
-- function setContentWithAdjHeight
-------------------------------------
function UI_ClanBoardListItem:setContentWithAdjHeight(review)
	local vars = self.vars

	-- set string (line 수를 알기 위해 사전에 함)
	vars['assessLabel']:setString(review)
	vars['assessLabel']:setLineBreakWithoutSpace(true)
	local line = vars['assessLabel']:getStringNumLines()

	if (line > 1) then
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
-- function click_deleteBtn
-------------------------------------
function UI_ClanBoardListItem:click_deleteBtn(cb_func)
	local board_id = self.m_tBoard['id']
    local finish_cb = function()
        -- 중간 데이터 꼬일 수 있음. 삭제하면 초기화
        self.m_owner.m_offset = 0
        self.m_owner:initBoardTableView()
    end

    local ok_cb = function()
        g_clanData:request_deleteBoard(finish_cb, nil, board_id)
    end

    MakeSimplePopup(POPUP_TYPE.YES_NO, Str('해당 게시글을 삭제하시겠습니까?'), ok_cb)
end

--@CHECK
UI:checkCompileError(UI_ClanBoardListItem)
