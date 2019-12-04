local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ClanWarMatchInfoDetailPopup
-------------------------------------
UI_ClanWarMatchInfoDetailPopup = class(PARENT, {
--[[
		@instance clan_match_info_left/right 데이터 구조
		local clan_match_info = {}
		clan_match_info['clan_id'] = data['a_clan_id']
		clan_match_info['member_win_cnt'] = data['a_member_win_cnt']
		clan_match_info['lose_cnt'] = data['a_lose_cnt']
		clan_match_info['win_cnt'] = data['a_win_cnt']
		clan_match_info['group_stage'] = data['group_stage']
        clan_match_info['play_member_cnt'] = data['a_play_member_cnt']
--]]
		m_tLeftClanInfo = 'table',
		m_tRightClanInfo = 'table',

	
--[[
		@instance match_info 데이터 구조
		local match_info = {}
	    match_info['season'] = data['season']
	    match_info['win_condition'] = data['win_condition']
        match_info['win_clan'] = data['win_clan']
	    match_info['group_stage'] = data['group_stage']
	    match_info['league'] = data['league']
	    match_info['match_no'] = data['match_no']
	    match_info['day'] = data['day']
--]]
		m_tMatchInfo = 'table',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarMatchInfoDetailPopup:init(ui_res, clan_match_info_left, clan_match_info_right, match_info)
    local ui_res = ui_res or 'clan_war_match_info_popup.ui'
	local vars = self:load(ui_res)
    UIManager:open(self, UIManager.POPUP)

	-- 맴버 변수
	self.m_tLeftClanInfo = clan_match_info_left
	self.m_tRightClanInfo = clan_match_info_right
	self.m_tMatchInfo = match_info

	-- UI 세팅
    self:initUI(clan_match_info_left, clan_match_info_right, match_info)
    self:initButton()
    self:refresh()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClanWarMatchInfoDetailPopup')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)
end

------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWarMatchInfoDetailPopup:initUI(clan_match_info_left, clan_match_info_right, match_info)
    local vars = self.vars

	-- 초기화
	vars['resultNode']:setVisible(false)
	local l_label = {'resultScore', 'creationLabel', 'clanLvExpLabel', 'playMemberCntLabel', 'gameWinLabel', 'victoryLabel'}
    for idx, label in ipairs(l_label) do
        if (vars[label .. '1']) then
            vars[label .. '1']:setString('-')
        end
		if (vars[label .. '2']) then
            vars[label .. '2']:setString('-')
        end
    end

    -- rich, lua_name 있어서 번역 안들어 가는 부분 초기화
    local win_condition_text = Str('{@yellow}세트 스코어{@default}가 동점일 경우 아래의 조건을 순서대로 비교해 승리 클랜을 결정합니다.')
    if (vars['winConditionLabel']) then
        vars['winConditionLabel']:setString(win_condition_text)
    end

    local function getUIIdx(is_left)
        -- 왼쪽 = 1, 오른쪽 = 2 
	    -- ex) lable1, label2
	    local ui_idx = 1
	    if (is_left) then
	    	ui_idx = 1
	    else
	    	ui_idx = 2
	    end

        return ui_idx
    end

	-- 왼쪽 클랜 세팅
	local is_left = true
	local is_valid_clan = self:setClanInfo(getUIIdx(is_left), self.m_tLeftClanInfo)
	if (is_valid_clan) then
	    self:setDetail(getUIIdx(is_left), self.m_tLeftClanInfo)
	end

	-- 오른쪽 클랜 세팅
	is_left = false
	local is_valid_clan = self:setClanInfo(getUIIdx(is_left), self.m_tRightClanInfo)
	if (is_valid_clan) then
	    self:setDetail(getUIIdx(is_left), self.m_tRightClanInfo)
	end

	self:setResult()
	self:highLightWinCondition()
end

------------------------------------
-- function initButton
-------------------------------------
function UI_ClanWarMatchInfoDetailPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

------------------------------------
-- function refresh
-------------------------------------
function UI_ClanWarMatchInfoDetailPopup:refresh()
    local vars = self.vars
end

-------------------------------------
-- function setClanInfo
-------------------------------------
function UI_ClanWarMatchInfoDetailPopup:setClanInfo(ui_idx, clan_match_info)
     local vars = self.vars
	 
	 local match_info = self.m_tMatchInfo
     
     if (vars['roundLabel']) then
		local round = match_info['group_stage'] -- group_stage가 있다면 토너먼트 정보
		if (round) then
			local round_text = g_clanWarData:getRoundText(round)
		    vars['roundLabel']:setString(round_text)
		else
		    vars['roundLabel']:setString(Str('조별리그'))
		end
     end

     local blank_clan = function()
        if (vars['clanNameLabel'..ui_idx]) then
            vars['clanNameLabel'..ui_idx]:setString('-')
        end
     end
     
 	 local clan_id = clan_match_info['clan_id']
     if (not clan_id) then
        blank_clan()
        return
     end

     -- 서버에서 임의로 추가한 유령 클랜의 경우
     if (clan_id == 'loser') then
        blank_clan()
        return
     end

	 local struct_clan_rank = g_clanWarData:getClanInfo(clan_id)
     -- 서버에서 임의로 추가한 유령 클랜의 경우
     if (not struct_clan_rank) then
        blank_clan()
        return
     end

     -- 클랜 이름
     local clan_name = struct_clan_rank:getClanName() or ''
     if (vars['clanNameLabel'..ui_idx]) then
        vars['clanNameLabel'..ui_idx]:setString(clan_name)
     end

     -- 클랜 마크
     local clan_icon = struct_clan_rank:makeClanMarkIcon()
     if (clan_icon) then
        if (vars['clanMarkNode'..ui_idx]) then
            vars['clanMarkNode'..ui_idx]:addChild(clan_icon)
        end

        if (vars['clanBtn' .. ui_idx]) then
            vars['clanBtn' .. ui_idx]:registerScriptTapHandler(function() g_clanData:requestClanInfoDetailPopup(clan_id) end)
        end
    end

    -- 클랜 정보 (레벨, 경험치, 참여인원)
    local clan_lv = struct_clan_rank:getClanLv() or ''
    local clan_lv_exp = string.format('Lv.%d (%.2f%%)', clan_lv, struct_clan_rank['exp']/10000)
	vars['clanLvExpLabel' .. ui_idx]:setString(clan_lv_exp) 
	vars['creationLabel' .. ui_idx]:setString(struct_clan_rank:getCreateAtText())

    -- 참여 클랜원 수
    local member_cnt = clan_match_info['play_member_cnt']
    vars['playMemberCntLabel' .. ui_idx]:setString(tostring(member_cnt))

    return true
end

-------------------------------------
-- function highLightWinCondition
-------------------------------------
function UI_ClanWarMatchInfoDetailPopup:highLightWinCondition()
    local vars = self.vars
    local match_info = self.m_tMatchInfo

    -- 승리한 조건 텍스트
    local win_condition_str = match_info['win_condition'] -- ex) win_member_cnt
	if (not win_condition_str) then
		return
	end

    local win_condition_text = self:getWinConditionText(win_condition_str)

	-- 이긴 클랜 정보
    local win_clan_id = match_info['win_clan']
    local struct_clan_rank = g_clanWarData:getClanInfo(win_clan_id)
    if (not struct_clan_rank) then
        return
    end

	-- 텍스트 조합
    local win_clan_name = struct_clan_rank:getClanName()
    win_condition_text = Str(win_condition_text, win_clan_name) -- {이긴 클랜}이 {승리한 조건}으로 승리하였습니다.

	-- 이긴 조건이 없을 경우 예외처리
    if (not win_condition_text) then
        win_condition_text = Str('{@yellow}세트 스코어{@default}가 동점일 경우 아래의 조건을 순서대로 비교해 승리 클랜을 결정합니다.')
    end

    if (vars['winConditionLabel'])then
        vars['winConditionLabel']:setString(win_condition_text)
    end
	
	-- 이긴 조건에 하이라이트
    -- [value] = 'lua_name'
    local t_label = {['member_win_cnt'] = 'resultScore', ['win_cnt'] = 'gameWin', ['play_member_cnt'] = 'playMemberCnt', ['clan_lv'] = 'clanLvExp', ['clan_created_date'] = 'creation'}
	for condition, lua_name in pairs(t_label) do
        if (condition == win_condition_str) then
            if (vars[lua_name ..'ConditionLabel']) then
                vars[lua_name ..'ConditionLabel']:setColor(COLOR['yellow'])
            end

            -- 세트 스코어 라벨에만 노란색 표시 하지 않음
            if (lua_name ~= 'resultScore') then
                local label_lua_name = lua_name .. 'Label'
                if (vars[label_lua_name .. '1']) then
			        vars[label_lua_name .. '1']:setColor(COLOR['yellow'])
			    end

			    if (vars[label_lua_name .. '2']) then
			    	vars[label_lua_name .. '2']:setColor(COLOR['yellow'])
			    end 
            end
        end
    end
end

-------------------------------------
-- function setYesterdayWinResult
-------------------------------------
function UI_ClanWarMatchInfoDetailPopup:setYesterdayWinResult()
	local vars = self.vars
    local match_info = self.m_tMatchInfo
		
	-- 이긴 클랜 정보
    local win_clan_id = match_info['win_clan']
    local struct_clan_rank = g_clanWarData:getClanInfo(win_clan_id)
    if (not struct_clan_rank) then
        return
    end
	
    -- 내 클랜이 이겼다면 승리/졌다면 패배
	local my_clan_id = g_clanWarData:getMyClanId()
    local my_clan_win = (win_clan_id == my_clan_id)
    vars['winNode']:setVisible(my_clan_win)
    vars['defeatNode']:setVisible(not my_clan_win)
    vars['resultNode']:setVisible(true)

	vars['resultNode']:setVisible(true)
    vars['roundLabel']:setString(Str('어제의 경기 결과'))
end

-------------------------------------
-- function setDetail
-------------------------------------
function UI_ClanWarMatchInfoDetailPopup:setDetail(ui_idx, clan_match_info)
    local vars = self.vars

	-- 게임 스코어
    local win, lose = clan_match_info['win_cnt'] or 0, clan_match_info['lose_cnt'] or 0
    local set_history = tostring(win)
	
	-- 세트 스코어
	local win_cnt = clan_match_info['member_win_cnt'] or 0
    vars['victoryLabel' .. ui_idx]:setString(tostring(win_cnt))
    vars['resultScore' .. ui_idx]:setString(tostring(win_cnt))
    vars['gameWinLabel' .. ui_idx]:setString(set_history)
end

-------------------------------------
-- function setResult
-------------------------------------
function UI_ClanWarMatchInfoDetailPopup:setResult() -- 왼쪽 클랜 기준으로
	local vars = self.vars
	local clan_match_info = self.m_tLeftClanInfo
	vars['leftWinNode']:setVisible(false)
	vars['rightLoseNode']:setVisible(false)
	vars['leftLoseNode']:setVisible(false)
	vars['rightWinNode']:setVisible(false)
	
	local match_info = self.m_tMatchInfo
	local is_end_match = false
    if (match_info['day']) then
        local match_number = match_info['day'] or 0
        is_end_match = (match_number < g_clanWarData.m_clanWarDay)
    else
        local round = match_info['group_stage']
        local cur_round = g_clanWarData:getTodayRound() or 0
        is_end_match = (round > cur_round)
    end
	
	-- 끝난 경기만 승/패 표시
    if (is_end_match) then
        -- 어느쪽 클랜이 이겼는지 표시
		local win_clan_id = match_info['win_clan']
		if (win_clan_id) then
			local is_win = (win_clan_id == clan_match_info['clan_id'])
			if (is_win) then
				vars['leftWinNode']:setVisible(true)
				vars['rightLoseNode']:setVisible(true)
			else
				vars['leftLoseNode']:setVisible(true)
				vars['rightWinNode']:setVisible(true)			
			end
		end
	end
end

-------------------------------------
-- function getWinConditionText
-------------------------------------
function UI_ClanWarMatchInfoDetailPopup:getWinConditionText(win_condition_str)
    -- 세트 승리
    if (win_condition_str == 'member_win_cnt') then
        return nil
    -- 게임 승리
    elseif(win_condition_str == 'win_cnt') then
        return Str('{1} 클랜이 더 많은 게임을 획득하여 승리하였습니다.')
    -- 클랜원이 더 많음
    elseif(win_condition_str == 'play_member_cnt') then
        return Str('{1} 클랜이 더 많은 클랜원이 참여하여 승리하였습니다.')
    -- 클랜 레벨/경험치가 더 많음 
	elseif(win_condition_str == 'clan_lv') then
        return Str('{1} 클랜이 승리하였습니다. (클랜 레벨 기준)')
    -- 생성일이 더 빠름
    elseif(win_condition_str == 'clan_created_date') then
        return Str('{1} 클랜이 승리하였습니다. (클랜 생성일 기준)')
    end

    return nil
end


---------------------------------------
-- function createMatchInfoPopup
-------------------------------------
function UI_ClanWarMatchInfoDetailPopup.createMatchInfoPopup(data, ui_res, set_my_clan_left)
    local ui_res = nil -- clan_war_match_info_popup.ui
	
    if (not data) then
        return
    end

	local clan_match_info_left = {}
    clan_match_info_left['clan_id'] = data['a_clan_id']
    clan_match_info_left['member_win_cnt'] = data['a_member_win_cnt']
    clan_match_info_left['lose_cnt'] = data['a_lose_cnt']
    clan_match_info_left['win_cnt'] = data['a_win_cnt']
    clan_match_info_left['play_member_cnt'] = data['a_play_member_cnt']

    local clan_match_info_right = {}
    clan_match_info_right['clan_id'] = data['b_clan_id']
    clan_match_info_right['member_win_cnt'] = data['b_member_win_cnt']
    clan_match_info_right['lose_cnt'] = data['b_lose_cnt']
    clan_match_info_right['win_cnt'] = data['b_win_cnt']
    clan_match_info_right['play_member_cnt'] = data['b_play_member_cnt']

	local match_info = {}
	-- 공통으로 받는 값
	match_info['season'] = data['season']
	match_info['win_condition'] = data['win_condition']
    match_info['win_clan'] = data['win_clan']

	-- 토너먼트일 경우에만 받는 값
	match_info['group_stage'] = data['group_stage']
	
	-- 조별리그일 경우에만 받는 값
	match_info['league'] = data['league']
	match_info['match_no'] = data['match_no']
	match_info['day'] = data['day']

	-- 내 클랜을 왼쪽으로 두고 싶을 경우 // set_my_clan_left = true
	-- 내 클랜이 오른쪽에 있는 경우에만 왼/오른쪽을 뒤집어 줌
	local my_clan_id = g_clanWarData:getMyClanId()
	if (set_my_clan_left) then
		if (clan_match_info_right['clan_id'] == my_clan_id) then
			local ui = UI_ClanWarMatchInfoDetailPopup(ui_res, clan_match_info_right, clan_match_info_left, match_info)
		    return ui
        end		
	end

	local ui = UI_ClanWarMatchInfoDetailPopup(ui_res, clan_match_info_left, clan_match_info_right, match_info)
    return ui
end

---------------------------------------
-- function createMatchInfoMini
-------------------------------------
function UI_ClanWarMatchInfoDetailPopup.createMatchInfoMini(data)
	local ui_res = 'clan_war_match_scene_mini_popup.ui'
	local ui = UI_ClanWarMatchInfoDetailPopup.createMatchInfoPopup(data, ui_res, true) -- param : data, ui_res, set_my_clan_left
    return ui
end

---------------------------------------
-- function createYesterdayResultPopup
-------------------------------------
function UI_ClanWarMatchInfoDetailPopup.createYesterdayResultPopup(data)
	local ui_res = nil -- clan_war_match_info_popup.ui
	local ui = UI_ClanWarMatchInfoDetailPopup.createMatchInfoPopup(data, ui_res) -- param : data, ui_res, set_my_clan_left
	ui:setYesterdayWinResult()
    return ui
end