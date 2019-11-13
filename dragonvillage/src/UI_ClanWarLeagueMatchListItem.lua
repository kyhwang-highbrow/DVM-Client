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

    -- 클랜 상세 정보 입력
    for idx = 1, 2 do
        self:setClanInfo(idx, data)
    end

    local match_number = data['day'] + 1

    -- 끝난 경기만 승/패 표시
    if (match_number < tonumber(data['match_day'])) then
        -- 왼쪽, 오른쪽 클랜중 어느쪽 클랜이 이겼는지 표시
		local struct_league_item = data['clan1']
        if (struct_league_item['clan_info']) then
	        local is_win = struct_league_item:isMatchWin(match_number) -- 첫 번째 클랜 기준
	        self:setResult(is_win)
        end
    end

    -- 현재 날짜, N번째 경기 정보 표기
    local cur_time = Timer:getServerTime()
    local t_day = {'월', '화', '수', '목', '금', '토', '일'}

    -- 총 5개를 찍어주는데 월요일은 경기를 안해서 화요일 부터 찍어야함
	local week_str = (tostring(match_number) - 1) .. '차 경기(' .. Str(t_day[tonumber(match_number)]) .. ')' -- 2차 경기 (수요일)

    -- n번째 날짜의 경기
    if (match_number == tonumber(data['match_day'])) then
        vars['todaySprite']:setVisible(true)
		week_str = week_str .. ' - 경기 진행중'
		vars['dateLabel']:setColor(COLOR['BLACK'])
    end

    -- 하루에 치뤄지는 3개의 경기 중 첫번째 경기에만 날짜 정보 표시하는 menu 활성화
    if (data['idx'] == 1) then
        vars['dateMenu']:setVisible(true)
    else
        vars['dateMenu']:setVisible(false)   
    end

    -- 날짜 정보 라벨 세팅
    vars['dateLabel']:setString(week_str)
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
     if (not struct_league_item['clan_info']) then
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
    if (match_number == tonumber(data['match_day'])) then
 	    lose = struct_league_item:getGameLose(match_number)
        win = struct_league_item:getGameWin(match_number)
        set_history = tostring(win) .. '-' .. tostring(lose)       
    else
        -- 해당 경기 세트 스코어
	    win, lose = struct_league_item:getMatchSetScore(match_number)
        set_history = tostring(win) .. '-' .. tostring(lose)
	    
    end
    vars['setScoreLabel' .. idx]:setString(set_history)

    -- 그 경기를 몇 처치로 이겼는지
    local win_cnt = struct_league_item:getMatchWinCnt(match_number)
	vars['scoreLabel' .. idx]:setString(tostring(win_cnt))

    -- 클랜 정보 (레벨, 경험치, 참여인원)
    local clan_lv = struct_clan_rank:getClanLv() or ''
    local clan_lv_exp = string.format('Lv.%d (%.2f%%)', clan_lv, struct_clan_rank['exp']/10000)
    local max_member = struct_league_item:getPlayMemberCnt()
	vars['partLabel' .. idx]:setString(max_member)
	vars['clanLvLabel' .. idx]:setString(clan_lv_exp) 
	vars['clanCreationLabel' .. idx]:setString(struct_clan_rank['create_date'])

    -- 내 클랜 표시
    if (data['my_clan_id'] == struct_league_item:getClanId()) then
        vars['leagueMeNode']:setVisible(true)
    end
end

-------------------------------------
-- function setResult
-------------------------------------
function UI_ClanWarLeagueMatchListItem:setResult(result) -- A가 win : true,  lose : false
    local vars = self.vars
    if (result) then
        vars['defeatSprite1']:setVisible(false)
        vars['defeatSprite2']:setVisible(true)
    else
        vars['defeatSprite1']:setVisible(true)
        vars['defeatSprite2']:setVisible(false)
    end
end