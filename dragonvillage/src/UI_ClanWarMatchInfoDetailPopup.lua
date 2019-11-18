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
end

------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWarMatchInfoDetailPopup:initUI(data, is_league)
    local vars = self.vars

    for i = 1, 2 do    
        -- 초기화
        if (vars['clanNameLabel'..i]) then
            vars['clanNameLabel'..i]:setString('-')
        end

        local l_label = {'resultScore', 'creationLabel', 'clanLvExpLabel', 'matchNumLabel', 'setScoreLabel', 'victoryLabel'}
        for idx, label in ipairs(l_label) do
            if (vars[label .. idx]) then
                vars[label .. idx]:setString('-')
            end
        end


        self:setClanInfoPopup(i, data, is_league)
        if (is_league) then
            self:setClanInfoPopup_league(i, data)
        else
            self:setClanInfoPopup_tournament(i, data)
        end
    end
end

-------------------------------------
-- function setClanInfoPopup
-------------------------------------
function UI_ClanWarMatchInfoDetailPopup:setClanInfoPopup(idx, data, is_league)
     local vars = self.vars
     local struct_league_item = data['clan' .. idx]

     local round = g_clanWarData:getTodayRound()
     if (round) then
         vars['roundLabel']:setString(Str('{1}강', round))
     else
         vars['roundLabel']:setString(Str('조별리그'))
     end

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

     local key = 'league_clan_info'
     if (not is_league) then
        key = 'tournament_clan_info'
     end

     -- 서버에서 임의로 추가한 유령 클랜의 경우
     if (not struct_league_item[key]) then
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

    -- 클랜 정보 (레벨, 경험치, 참여인원)
    local clan_lv = struct_clan_rank:getClanLv() or ''
    local clan_lv_exp = string.format('Lv.%d (%.2f%%)', clan_lv, struct_clan_rank['exp']/10000)
    local max_member = struct_league_item:getPlayMemberCnt()
	vars['matchNumLabel' .. idx]:setString(max_member)
	vars['clanLvExpLabel' .. idx]:setString(clan_lv_exp) 
	vars['creationLabel' .. idx]:setString(struct_clan_rank['create_date'] or '')
end

-------------------------------------
-- function setClanInfoPopup_league
-------------------------------------
function UI_ClanWarMatchInfoDetailPopup:setClanInfoPopup_league(idx, data)
    local vars = self.vars
    local struct_league_item = data['clan' .. idx]
    
    -- 서버에서 임의로 추가한 유령 클랜의 경우
    if (not struct_league_item['league_clan_info']) then
       return
    end

    if (struct_league_item:isGoastClan()) then
       return
    end

    local match_number = data['day'] + 1
    
    local set_history
    local win, lose
    local win_cnt 
    if (match_number - 1 <= tonumber(data['match_day'])) then
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

    -- 끝난 경기만 승/패 표시
    if (match_number < tonumber(data['match_day'])) then
        -- 왼쪽, 오른쪽 클랜중 어느쪽 클랜이 이겼는지 표시
		local struct_league_item = data['clan1']
        if (struct_league_item['league_clan_info']) then
	        local is_win = struct_league_item:isMatchWin(match_number) -- 첫 번째 클랜 기준
            local pos_x_1 = vars['resultNode1']:getPositionX()
            local pos_x_2 = vars['resultNode2']:getPositionX()

            if (not is_win) then
                vars['resultNode1']:setPositionX(pos_x_2)
                vars['resultNode2']:setPositionX(pos_x_1)
            end	        
        end
    else
        vars['resultNode1']:setVisible(false)
        vars['resultNode2']:setVisible(false)
    end
end

-------------------------------------
-- function setClanInfoPopup_tournament
-------------------------------------
function UI_ClanWarMatchInfoDetailPopup:setClanInfoPopup_tournament(idx, data)
    local vars = self.vars
    local struct_league_item = data['clan' .. idx]

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
     if (not struct_league_item['tournament_clan_info']) then
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
end