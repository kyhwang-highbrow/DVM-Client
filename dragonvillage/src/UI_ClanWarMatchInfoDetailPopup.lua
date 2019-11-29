local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ClanWarMatchInfoDetailPopup
-------------------------------------
UI_ClanWarMatchInfoDetailPopup = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarMatchInfoDetailPopup:init(data, is_yesterday_result)
    local vars = self:load('clan_war_tournament_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    
    self:initUI(data, is_yesterday_result)

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClanWarLeagueMatchInfoPopup')

    self.vars['closeBtn']:registerScriptTapHandler(function() self:close() end)

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)
end

------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWarMatchInfoDetailPopup:initUI(data, is_yesterday_result)
    local vars = self.vars

	-- 초기화
	local l_label = {'resultScore', 'creationLabel', 'clanLvExpLabel', 'matchNumLabel', 'setScoreLabel', 'victoryLabel'}
    for idx, label in ipairs(l_label) do
        if (vars[label .. '1']) then
            vars[label .. '1']:setString('-')
        end
		if (vars[label .. '2']) then
            vars[label .. '2']:setString('-')
        end
    end

    for i = 1, 2 do    
		local is_valid_clan = self.setClanInfoPopup(vars, i, data)
        if (is_valid_clan) then
		    self.setDetail(vars, i, data)

            if (is_yesterday_result) then
                self:setDetailForYesterday(data)
            end
        end
    end

    -- rich, lua 있어서 번역 안들어 가는 부분
    local win_condition_text = Str('{@yellow}세트 스코어{@default}가 동점일 경우 아래의 조건을 순서대로 비교해 승리 클랜을 결정합니다.')
    if (vars['winConditionLabel']) then
        vars['winConditionLabel']:setString(win_condition_text)
    end
    local l_win_condition = {'승리한 게임 수', '참여 클랜원 수', '클랜 레벨(경험치)', '클랜 생성일'}
    for i, label in ipairs(l_win_condition) do
        if (vars['conditionLabel' .. i+1]) then
            vars['conditionLabel' .. i+1]:setString(Str(label))
        end
    end
end

-------------------------------------
-- function setClanInfoPopup
-------------------------------------
function UI_ClanWarMatchInfoDetailPopup.setClanInfoPopup(vars, idx, data, my_clan_is_b)
     local round = g_clanWarData:getTodayRound()
     local round_text = g_clanWarData:getTodayRoundText()
     if (not data) then
        return
     end
     
     if (vars['roundLabel']) then
        if (round) then
            if (data['group_stage']) then
                vars['roundLabel']:setString(Str('{1}강', data['group_stage']))
            else
                vars['roundLabel']:setString(Str('조별리그'))
            end
        else
            vars['roundLabel']:setString(Str('조별리그'))
        end
     end

	 local prefix = 'a_'
     -- a_my_clan_id 가 내 클랜일 경우/아닐 경우 유아이 반대로 찍어야함
     if (not my_clan_is_b) then
        if (idx == 1) then
            prefix = 'a_'
        else
            prefix = 'b_'
        end
     else
        if (idx == 1) then
            prefix = 'b_'
        else
            prefix = 'a_'
        end	 
     end

     local blank_clan = function()
        if (vars['clanNameLabel'..idx]) then
            vars['clanNameLabel'..idx]:setString('-')
        end
     end
     
 	 local clan_id = data[prefix .. 'clan_id']
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
     if (vars['clanNameLabel'..idx]) then
        vars['clanNameLabel'..idx]:setString(clan_name)
     end

     -- 클랜 마크
     local clan_icon = struct_clan_rank:makeClanMarkIcon()
     if (clan_icon) then
        if (vars['clanMarkNode'..idx]) then
            vars['clanMarkNode'..idx]:addChild(clan_icon)
        end
    end

    -- 클랜 정보 (레벨, 경험치, 참여인원)
    local clan_lv = struct_clan_rank:getClanLv() or ''
    local clan_lv_exp = string.format('Lv.%d (%.2f%%)', clan_lv, struct_clan_rank['exp']/10000)
	vars['clanLvExpLabel' .. idx]:setString(clan_lv_exp) 
	vars['creationLabel' .. idx]:setString(struct_clan_rank:getCreateAtText())

    -- 참여 클랜원 수
    local member_cnt = data[prefix .. 'play_member_cnt']
    vars['matchNumLabel' .. idx]:setString(tostring(member_cnt))

	return true
end

-------------------------------------
-- function setDetailForYesterday
-------------------------------------
function UI_ClanWarMatchInfoDetailPopup:setDetailForYesterday(data)
    local vars = self.vars
    vars['roundLabel']:setString(Str('어제의 경기 결과'))

    -- 승리한 조건 설명
    local win_condition = data['win_condition'] or 'member_win_cnt'
    local table_win_condition = {['member_win_cnt'] = 1, ['win_cnt'] = 2, ['play_member_cnt'] = 3, ['clan_lv'] = 4, ['clan_created_date'] = 5}
    local win_condition_idx = table_win_condition[win_condition]


    local win_condition_text = self:getWinConditionText(win_condition_idx)

    local win_clan_id = data['win_clan']
    local struct_clan_rank = g_clanWarData:getClanInfo(win_clan_id)
    if (not struct_clan_rank) then
        return
    end

    local win_clan_name = struct_clan_rank:getClanName()
    win_condition_text = Str(win_condition_text, win_clan_name)

    if (not win_condition_text) then
        win_condition_text = Str('{@yellow}세트 스코어{@default}가 동점일 경우 아래의 조건을 순서대로 비교해 승리 클랜을 결정합니다.')
    end

    if (vars['winConditionLabel'])then
        vars['winConditionLabel']:setString(win_condition_text)
    end

    for i = 1, 5 do
        if (win_condition_idx == i) then
            if (vars['conditionLabel' .. i]) then
                vars['conditionLabel' .. i]:setColor(COLOR['yellow'])
            end
        end
    end

    local my_clan_id = g_clanWarData:getMyClanId()
    local my_clan_win = (win_clan_id == my_clan_id)
    vars['winNode']:setVisible(my_clan_win)
    vars['defeatNode']:setVisible(not my_clan_win)
    vars['resultNode']:setVisible(true)
end

-------------------------------------
-- function setDetail
-------------------------------------
function UI_ClanWarMatchInfoDetailPopup.setDetail(vars, idx, data)
 	
	local prefix = 'a_'
	if (idx == 2) then
		prefix = 'b_'
	end   

    local match_number
    if (data['day']) then
        match_number = data['day'] or 0
    else
        local round = data['group_stage']
        match_number = g_clanWarData:getDayByRound(round)
    end

	-- 게임 스코어
    local win, lose = data[prefix .. 'win_cnt'] or 0, data[prefix .. 'lose_cnt'] or 0
    local set_history = tostring(win)
	
	-- 세트 스코어
	local win_cnt = data[prefix .. 'member_win_cnt'] or 0

    vars['victoryLabel' .. idx]:setString(tostring(win_cnt))
    vars['resultScore' .. idx]:setString(tostring(win_cnt))
    vars['setScoreLabel' .. idx]:setString(set_history)

    if (idx == 1) then
        return
    end

    if (not vars['resultNode1']) or (not vars['resultNode2']) then
        return
    end
	-- 끝난 경기만 승/패 표시
	vars['resultNode1']:setVisible(false)
    vars['resultNode2']:setVisible(false)
    if (match_number < g_clanWarData.m_clanWarDay) then
        -- 어느쪽 클랜이 이겼는지 표시
		local win_clan_id = data['win_clan']
		if (win_clan_id) then
			local is_win = (win_clan_id == data['a_clan_id'])
			local pos_x_1 = vars['resultNode1']:getPositionX()
			local pos_x_2 = vars['resultNode2']:getPositionX()

			if (not is_win) then
			    vars['resultNode1']:setPositionX(pos_x_1 + 600)
			    vars['resultNode2']:setPositionX(pos_x_2 - 600)
			end
		end
		vars['resultNode1']:setVisible(true)
        vars['resultNode2']:setVisible(true)
	end
end

-------------------------------------
-- function getWinConditionText
-------------------------------------
function UI_ClanWarMatchInfoDetailPopup:getWinConditionText(win_condition)
    -- 세트 승리
    if (win_condition == 1) then
        return nil
    -- 게임 승리
    elseif(win_condition == 2) then
        return Str('{1} 클랜이 더 많은 게임을 획득하여 승리하였습니다.')
    -- 클랜원이 더 많음
    elseif(win_condition == 3) then
        return Str('{1} 클랜이 더 많은 클랜원이 참여하여 승리하였습니다.')
    -- 클랜 레벨/경험치가 더 많음 
	elseif(win_condition == 4) then
        return Str('{1} 클랜이 승리하였습니다. (클랜 레벨 기준)')
    -- 생성일이 더 빠름
    else
        return Str('{1} 클랜이 승리하였습니다. (클랜 생성일 기준)')
    end
end






local PARENT = UI

-------------------------------------
-- class UI_ClanWarMatchInfoDetailMiniPopup
-------------------------------------
UI_ClanWarMatchInfoDetailMiniPopup = class(PARENT, {
     })


-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarMatchInfoDetailMiniPopup:init(data, is_yesterday_result, close_cb)
    local vars = self:load('clan_war_match_scene_mini_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    self:initUI(data)

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn(close_cb) end, 'UI_ClanWarMatchInfoDetailMiniPopup')

    self.vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn(close_cb) end)

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_ClanWarMatchInfoDetailMiniPopup:click_closeBtn(close_cb)
    if (close_cb) then
        close_cb()
    end
    
    self:close()
end

------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWarMatchInfoDetailMiniPopup:initUI(data)
    local vars = self.vars

	-- 초기화
	local l_label = {'resultScore', 'creationLabel', 'clanLvExpLabel', 'matchNumLabel', 'setScoreLabel', 'victoryLabel'}
    for idx, label in ipairs(l_label) do
        if (vars[label .. '1']) then
            vars[label .. '1']:setString('-')
        end
		if (vars[label .. '2']) then
            vars[label .. '2']:setString('-')
        end
    end

    local my_clan_is_b = false
    local my_clan_id = g_clanWarData:getMyClanId()
    if (data['b_clan_id'] == my_clan_id) then
        my_clan_is_b = true
    end

    for i = 1, 2 do    
		local is_valid_clan = UI_ClanWarMatchInfoDetailPopup.setClanInfoPopup(vars, i, data, my_clan_is_b)
        if (is_valid_clan) then
		    UI_ClanWarMatchInfoDetailPopup.setDetail(vars, i, data)
        end
    end
end