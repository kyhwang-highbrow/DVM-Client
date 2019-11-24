local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ClanWarMatchInfoDetailPopup
-------------------------------------
UI_ClanWarMatchInfoDetailPopup = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarMatchInfoDetailPopup:init(data, is_league)
    local vars = self:load('clan_war_tournament_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    
    self:initUI(data, is_league)

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
function UI_ClanWarMatchInfoDetailPopup:initUI(data, is_league)
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
		local is_valid_clan = self:setClanInfoPopup(i, data, is_league)
        if (is_valid_clan) then
		    self:setDetail(i, data)
        end
    end
end

-------------------------------------
-- function setClanInfoPopup
-------------------------------------
function UI_ClanWarMatchInfoDetailPopup:setClanInfoPopup(idx, data, is_league)
     local vars = self.vars
     local round = g_clanWarData:getTodayRound()
     local round_text = g_clanWarData:getTodayRoundText()
     if (round) then
        if (data['group_stage']) then
            vars['roundLabel']:setString(Str('{1}강', data['group_stage']))
        else
            vars['roundLabel']:setString(Str('조별리그'))
        end
     else
         vars['roundLabel']:setString(Str('조별리그'))
     end

	 local prefix = 'a_'
	 if (idx == 2) then
		prefix = 'b_'
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

	return true
end

-------------------------------------
-- function setDetail
-------------------------------------
function UI_ClanWarMatchInfoDetailPopup:setDetail(idx, data)
    local vars = self.vars
 	
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