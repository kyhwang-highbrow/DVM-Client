local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ClanWarLeagueMatchListItem
-------------------------------------
UI_ClanWarLeagueMatchListItem = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarLeagueMatchListItem:init(data)
    local vars = self:load('clan_war_lobby_item_league.ui')
    if (not data) then
        return
    end
    
    -- 날짜 사이마다 간격이 있는 것 처럼 보여주기위해  더미 UI를 하나 찍음
    if (data['my_clan_id'] == 'blank') then
        vars['entireMenu']:setVisible(false)
        return
    end

    -- 클랜 상세 정보 입력
    for idx = 1, 2 do
        self:setClanInfo(idx, data)
    end

    local match_number = data['day']

    -- 끝난 경기만 승/패 표시
    if (match_number < tonumber(data['match_day'])) then
        -- 왼쪽, 오른쪽 클랜중 어느쪽 클랜이 이겼는지 표시
		local struct_league_item = data['clan1']
        if (struct_league_item['league_clan_info']) then
	        local is_win = struct_league_item:isMatchWin(match_number) -- 첫 번째 클랜 기준
	        self:setResult(is_win)
        end
    end

	local clan_group_cnt = 4
	if (g_clanWarData:getGroupCnt() == 4) then
		clan_group_cnt = 3
	end

	local idx = data['idx']
	-- 하루에 치뤄지는 3개의 경기 중 첫번째 경기에만 날짜 정보 표시하는 menu 활성화
	if (((idx - 1)%clan_group_cnt) == 0) then
		vars['dateMenu']:setVisible(true)
	else
		vars['dateMenu']:setVisible(false)   
		return
	end
	local day_idx = (idx - 1)/clan_group_cnt + 1

	-- 현재 날짜, N번째 경기 정보 표기
	local cur_time = Timer:getServerTime()
	local t_day = {'월', '화', '수', '목', '금', '토', '일'}

	-- 총 5개를 찍어주는데 월요일은 경기를 안해서 화요일 부터 찍어야함
	local week_str = (tostring(day_idx)) .. '차 경기(' .. Str(t_day[tonumber(match_number)]) .. ')' -- 2차 경기 (수요일)

	-- n번째 날짜의 경기
	if (g_clanWarData.m_clanWarDay == tonumber(data['day'])) then
	    vars['todaySprite']:setVisible(true)
		if (g_clanWarData:getClanWarState() == ServerData_ClanWar.CLANWAR_STATE['OPEN']) then
			week_str = week_str .. ' - 경기 진행중'
		end
		vars['dateLabel']:setColor(COLOR['BLACK'])
	end
	-- 날짜 정보 라벨 세팅
	vars['dateLabel']:setString(week_str)

	day_idx = day_idx + 1
end

-------------------------------------
-- function setClanInfo
-------------------------------------
function UI_ClanWarLeagueMatchListItem:setClanInfo(idx, data)
     local vars = self.vars
     local struct_league_item = data['clan' .. idx]

     local match_number = data['day'] + 1
     local blank_clan = function()
        if (vars['clanNameLabel'..idx]) then
            vars['clanNameLabel'..idx]:setString('-')
        end

		-- 정보가 없다면 유령 클랜으로 패배 처리
        if (vars['defeatSprite'..idx]) then
            vars['defeatSprite'..idx]:setVisible(true)
        end

        if (vars['scoreLabel' .. idx]) then
            vars['scoreLabel' .. idx]:setString('0')
        end
     end
     
     -- 서버에서 임의로 추가한 유령 클랜의 경우
     if (not struct_league_item) then
        blank_clan()
        return
     end

     -- 서버에서 임의로 추가한 유령 클랜의 경우
     if (not struct_league_item['league_clan_info']) then
        blank_clan()
        return
     end
     
     -- 서버에서 임의로 추가한 유령 클랜의 경우
     local struct_clan_rank = struct_league_item:getClanInfo()
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
    
    local set_history
    local win, lose
    local win_cnt 
    if (match_number == tonumber(data['match_day'])) then
        -- 그 경기를 몇 처치로 이겼는지
        win_cnt = struct_league_item:getMatchWinCnt(match_number)       
    else
	    win_cnt = struct_league_item:isMatchWin_Past(match_number)
    end

    vars['scoreLabel' .. idx]:setString(tostring(win_cnt))

    -- 내 클랜 표시
    if (data['my_clan_id'] == struct_league_item:getClanId()) then
        vars['leagueMeNode']:setVisible(true)
    end


    -- 미래 경기는 팝업 보여주지 않음
    if (match_number - 1 <= tonumber(data['match_day'])) then
        vars['popupBtn']:registerScriptTapHandler(function() UI_ClanWarLeagueMatchInfoPopup(data) end)
    else
        vars['popupBtn']:registerScriptTapHandler(function() MakeSimplePopup(POPUP_TYPE.OK, Str('공격전 기록이 없습니다.')) end)
        vars['scoreLabel1']:setString('')
        vars['scoreLabel2']:setString('')
    end
end

-------------------------------------
-- function setResult
-------------------------------------
function UI_ClanWarLeagueMatchListItem:setResult(result) -- A가 win : true,  lose : false
    local vars = self.vars

    vars['defeatSprite1']:setVisible(not result)
    vars['defeatSprite2']:setVisible(result)
    vars['winSprite2']:setVisible(not result)
    vars['winSprite1']:setVisible(result)
end






local PARENT = UI

-------------------------------------
-- class UI_ClanWarLeagueMatchInfoPopup
-------------------------------------
UI_ClanWarLeagueMatchInfoPopup = class(PARENT, {
     })


-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarLeagueMatchInfoPopup:init(data)
    local vars = self:load('clan_war_tournament_popup.ui')
    UIManager:open(self, UIManager.POPUP)
    for i = 1, 2 do
        self:setClanInfoPopup(i, data)
    end

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClanWarLeagueMatchInfoPopup')

    self.vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function setClanInfoPopup
-------------------------------------
function UI_ClanWarLeagueMatchInfoPopup:setClanInfoPopup(idx, data)
     local vars = self.vars
     local struct_league_item = data['clan' .. idx]

     local match_number = data['day'] + 1
     local blank_clan = function()
        if (vars['clanNameLabel'..idx]) then
            vars['clanNameLabel'..idx]:setString('-')
        end

        local l_label = {'resultScore', 'creationLabel', 'clanLvExpLabel', 'matchNumLabel', 'setScoreLabel', 'victoryLabel'}
        for i, label in ipairs(l_label) do
            if (vars[label .. idx]) then
                vars[label .. idx]:setString('-')
            end
        end
     end
     
     -- 서버에서 임의로 추가한 유령 클랜의 경우
     if (not struct_league_item) then
        blank_clan()
        return
     end

     -- 서버에서 임의로 추가한 유령 클랜의 경우
     if (not struct_league_item['league_clan_info']) then
        blank_clan()
        return
     end
     
     -- 서버에서 임의로 추가한 유령 클랜의 경우
     local struct_clan_rank = struct_league_item:getClanInfo()
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
    
    local set_history
    local win, lose
    local win_cnt 
    if (match_number == tonumber(data['match_day'])) then
        -- 그 경기를 몇 처치로 이겼는지
        win_cnt = struct_league_item:getMatchWinCnt(match_number)
        lose = struct_league_item:getGameLose(match_number)
        win = struct_league_item:getGameWin(match_number)
        set_history = tostring(win) .. '-' .. tostring(lose)     
    else
	    win_cnt = struct_league_item:isMatchWin_Past(match_number)
    	win, lose = struct_league_item:getMatchSetScore(match_number)
        set_history = tostring(win) .. '-' .. tostring(lose)
    end

    vars['victoryLabel' .. idx]:setString(tostring(win_cnt))
    vars['resultScore' .. idx]:setString(tostring(win_cnt))
    vars['setScoreLabel' .. idx]:setString(set_history)
    
    -- 클랜 정보 (레벨, 경험치, 참여인원)
    local clan_lv = struct_clan_rank:getClanLv() or ''
    local clan_lv_exp = string.format('Lv.%d (%.2f%%)', clan_lv, struct_clan_rank['exp']/10000)
    local max_member = struct_league_item:getPlayMemberCnt()
	vars['matchNumLabel' .. idx]:setString(max_member)
	vars['clanLvExpLabel' .. idx]:setString(clan_lv_exp) 
	vars['creationLabel' .. idx]:setString(struct_clan_rank['create_date'])


    -- 끝난 경기만 승/패 표시
    if (match_number < tonumber(data['match_day'])) then
        -- 왼쪽, 오른쪽 클랜중 어느쪽 클랜이 이겼는지 표시
		local struct_league_item = data['clan1']
        if (struct_league_item['clan_info']) then
	        local is_win = struct_league_item:isMatchWin(match_number) -- 첫 번째 클랜 기준
            local pos_x_1 = vars['resultNode1']:getPositionX()
            local pos_x_2 = vars['resultNode2']:getPositionX()
            cclog(pos_x_1, pos_x_2, is_win)
            if (not is_win) then
                vars['resultNode1']:setPositionX(pos_x_2)
                vars['resultNode2']:setPositionX(pos_x_1)
            end	        
        end
    else
        vars['resultNode1']:setVisible(false)
        vars['resultNode2']:setVisible(false)
    end


    local round = g_clanWarData:getTodayRound()
    if (round) then
        vars['roundLabel']:setString(Str('{1}강', round))
    else
        vars['roundLabel']:setString(Str('조별리그'))
    end
end

