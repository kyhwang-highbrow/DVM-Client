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
            vars['scoreLabel' .. idx]:setString('')
        end

        if (idx == 1) then
            vars['defeatSprite1']:setVisible(true)
            vars['winSprite2']:setVisible(true)
        else
            vars['defeatSprite2']:setVisible(true)
            vars['winSprite1']:setVisible(true)
        end

        -- 둘 다 유령 클랜일 경우 다 진 것으로 표기
        if (vars['defeatSprite1']:isVisible() and vars['defeatSprite2']:isVisible()) then
            vars['winSprite1']:setVisible(false)
            vars['winSprite2']:setVisible(false)
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
     if (not struct_league_item['league_clan_info']['id'] == 'loser') then
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
        vars['popupBtn']:registerScriptTapHandler(function() UI_ClanWarMatchInfoDetailPopup(data, true) end)
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

