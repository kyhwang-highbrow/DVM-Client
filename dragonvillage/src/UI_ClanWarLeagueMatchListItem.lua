local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ClanWarLeagueMatchListItem
-------------------------------------
UI_ClanWarLeagueMatchListItem = class(PARENT, {
     })


--[[
	"a_win_cnt":0,
	"b_play_member_cnt":0,
	"id":"5dd56886e8919372e1f01248",
	"b_member_win_cnt":0,
	"b_lose_cnt":0,
	"a_clan_id":"5ad9519fe891932d9abe6940",
	"a_member_win_cnt":0,
	"day":2,
	"league":1,
	"b_win_cnt":0,
	"season":201947,
	"a_lose_cnt":0,
	"a_play_member_cnt":0,
	"match_no":1,
	"b_clan_id":"5a167756e891934ac612c399"
--]]
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

    local match_number = data['day'] or 1

    -- 끝난 경기만 승/패 표시
    if (match_number < g_clanWarData.m_clanWarDay) then
        -- 어느쪽 클랜이 이겼는지 표시
		local win_clan_id = data['win_clan']
		if (win_clan_id) then
			self:setResult(win_clan_id == data['a_clan_id'])
		end
	end

	local clan_group_cnt = 4
	if (g_clanWarData:getGroupCnt() == 4) then
		clan_group_cnt = 3
	end

	local idx = data['idx']
	local is_header_idx = ((idx - 1)%clan_group_cnt == 0)
	-- 하루에 치뤄지는 3개의 경기 중 첫번째 경기에만 날짜 정보 표시하는 menu 활성화
	if (is_header_idx) then
		vars['dateMenu']:setVisible(true)
	else
		vars['dateMenu']:setVisible(false)   
		return
	end

	-- N차 경기
	-- 1,2,3 (4) 5,6,7
	local day_idx = math.floor((idx - 1)/clan_group_cnt) + 1

	-- 현재 날짜, N번째 경기 정보 표기
	local cur_time = Timer:getServerTime()
	local t_day = {'월', '화', '수', '목', '금', '토', '일'}
	local week_str = (tostring(day_idx)) .. '차 경기(' .. Str(t_day[tonumber(match_number)]) .. ')' -- 2차 경기 (수요일)

	-- 오늘 진행 여부
	if (match_number == g_clanWarData.m_clanWarDay) then
	    vars['todaySprite']:setVisible(true)
		if (g_clanWarData:getClanWarState() == ServerData_ClanWar.CLANWAR_STATE['OPEN']) then
			week_str = week_str .. ' - 경기 진행중'
		end
		vars['dateLabel']:setColor(COLOR['BLACK'])
	end
	-- 날짜 정보 라벨 세팅
	vars['dateLabel']:setString(week_str)
end

-------------------------------------
-- function setClanInfo
-------------------------------------
function UI_ClanWarLeagueMatchListItem:setClanInfo(idx, data)
     local vars = self.vars

	 local prefix = 'a_'
	 if (idx == 2) then
		prefix = 'b_'
	 end

     local blank_clan = function()
        if (vars['clanNameLabel'..idx]) then
            vars['clanNameLabel'..idx]:setString(Str('대전 상대 없음'))
        end

		-- 정보가 없다면 유령 클랜으로 패배 처리
        if (vars['defeatSprite'..idx]) then
            vars['defeatSprite'..idx]:setVisible(true)
        end

        if (vars['scoreLabel' .. idx]) then
            vars['scoreLabel' .. idx]:setString('')
        end

		-- 유령클랜 부전승 처리
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

	 -- 내 클랜 표시
	 local my_clan_id = g_clanWarData:getMyClanId()
     if (my_clan_id == clan_id) then
         vars['leagueMeNode']:setVisible(true)
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

    local match_number = data['day'] or 1
    local win, lose = data[prefix .. 'win_cnt'] or 0, data[prefix .. 'lose_cnt'] or 0
    local win_cnt = data[prefix .. 'member_win_cnt'] or 0

    vars['scoreLabel' .. idx]:setString(tostring(win_cnt))

    -- 미래 경기는 상세 팝업 보여주지 않음
    if (match_number <= tonumber(g_clanWarData.m_clanWarDay)) then
        vars['popupBtn']:registerScriptTapHandler(function() UI_ClanWarMatchInfoDetailPopup(data, true) end)
    else
        vars['popupBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed(Str('기록 없음')) end)
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

