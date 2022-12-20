local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ListItem_ClanWarGroupStageRankInAll
-- @brief 클랜전 조별리그에서 "전체 보기"에서 사용되는 리스트 아이템
-------------------------------------
UI_ListItem_ClanWarGroupStageRankInAll = class(PARENT, {
        m_leagueNumber = 'number',
     })

        -------------------------------------
        -- function init
        -------------------------------------
        function UI_ListItem_ClanWarGroupStageRankInAll:init(data)
            local vars = self:load('clan_war_lobby_item_all_rank_01_new.ui')

	        -- 첫 번째 클랜의 조 이름을 가져옴
	        local struct_league_item = data[1]
	        local league = struct_league_item:getLeague()
            self.m_leagueNumber = league
	        vars['teamLabel']:setString(Str('{1}조', league))

            -- 각 조마다 랭킹 정보 입력
	        for i, struct_league_item in ipairs(data) do
		        if (vars['itemNode' .. i]) then
			        if (struct_league_item) then
				        local ui_item = self:makeClanItem(struct_league_item)
				        vars['itemNode' .. i]:addChild(ui_item.root)
			        end
		        end
	        end
        end

        -------------------------------------
        -- function makeClanItem
        -------------------------------------
        function UI_ListItem_ClanWarGroupStageRankInAll:makeClanItem(struct_league_item)
            local ui = UI()
            ui:load('clan_war_lobby_item_all_rank_02_new.ui')

            local vars = ui.vars

            if (not struct_league_item) then
                vars['clanNameLabel']:setString(Str('대전 상대 없음'))
                vars['rankLabel']:setString('')
                vars['scoreLabel']:setString('')
                return ui
            end

            if (struct_league_item:isGoastClan()) then
                vars['clanNameLabel']:setString(Str('대전 상대 없음'))
                vars['rankLabel']:setString('')
                vars['scoreLabel']:setString('')
                return ui
            end

            -- 클랜 정보
            local clan_id = struct_league_item:getClanId()
	        local struct_clan_rank = g_clanWarData:getClanInfo(clan_id)
            local clan_name = struct_clan_rank:getClanName() or ''
            local clan_rank = struct_league_item:getLeagueRank() -- 클랜 순위 (조 내에서)
            local is_pass = (1 <= clan_rank) and (clan_rank <= 2) -- 조별리그 통과 여부
            local font_color_tag = conditionalOperator(is_pass, '{@MUSTARD}', '')

            -- 클랜 정보 (이름 랭크)
            vars['clanNameLabel']:setString(font_color_tag .. clan_name)

            -- 클랜 마크
             local clan_icon = struct_clan_rank:makeClanMarkIcon()
             if (clan_icon) then
                if (vars['clanMarkNode']) then
                    vars['clanMarkNode']:addChild(clan_icon)
                end
            end

	        if (clan_rank <= 0) then
		        clan_rank = '-'
	        end
            vars['rankLabel']:setString(font_color_tag .. tostring(clan_rank))

            -- 토너먼트 진출 가능 표시
            vars['resultNode']:setVisible(is_pass)

	        -- 전체 5일동안 이루어진 경기에서 얼마나 이겼는지
            local clan_id = struct_league_item:getClanId()
            local lose_cnt = struct_league_item:getLoseCount()
            local win_cnt = struct_league_item:getWinCount()
            vars['scoreLabel']:setString(font_color_tag .. Str('{1}-{2}', win_cnt, lose_cnt))

	        local my_clan_id = g_clanWarData:getMyClanId()
	        vars['meSprite']:setVisible(clan_id == my_clan_id)

            return ui 
        end





--------------------------------
local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ListItem_ClanWarGroupStageMatch
-- @brief 클랜전 조별리그에서 조별 경기 일정/결과에 사용되는 리스트 아이템
-------------------------------------
UI_ListItem_ClanWarGroupStageMatch = class(PARENT, {
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
        function UI_ListItem_ClanWarGroupStageMatch:init(data)
            local vars = self:load('clan_war_lobby_item_league_new.ui')
            if (not data) then
                return
            end
    
            -- 날짜 사이마다 간격이 있는 것 처럼 보여주기위해  더미 UI를 하나 찍음
            if (data['my_clan_id'] == 'blank') then
                vars['entireMenu']:setVisible(false)

                -- blak셀은 높이를 조정 80->20
		        self:setCellSize(cc.size(0, 20))
                return
            end

            -- 클랜 상세 정보 입력
            for idx = 1, 2 do
                self:setClanInfo(idx, data)
            end

            local match_number = data['day'] or 1

            do -- 버튼 처리
                local clan1_id = data['a_clan_id']
                local clan2_id = data['b_clan_id']
                local my_clan_id = g_clanWarData:getMyClanId()
                local include_my_clan = false
                if (clan1_id == my_clan_id) or (clan2_id == my_clan_id) then
                    include_my_clan = true
                end

                -- 미래 경기는 상세 팝업 보여주지 않음
                local today_match_number = tonumber(g_clanWarData.m_clanWarDay)
                if (today_match_number < match_number) then
                    vars['popupBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed(Str('아직 진행되지 않은 경기입니다.')) end)
                    vars['scoreLabel1']:setString('')
                    vars['scoreLabel2']:setString('')
                elseif (today_match_number == match_number) then
                    vars['popupBtn']:registerScriptTapHandler(function() 
                        if include_my_clan then
                            self:click_gotoMatch()
                        else
                            require('UI_ClanWarMatchingWatching')
                            UI_ClanWarMatchingWatching.OPEN(clan1_id)                
                        end
                    end)
                else
                    vars['popupBtn']:registerScriptTapHandler(function() 
				        UI_ClanWarMatchInfoDetailPopup.createMatchInfoPopup(data) -- data, ui_res, set_my_clan_left 
			        end)
                end
            end

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

                -- 해더 셀은 size를 달리 사용
		        self:setCellSize(cc.size(0, 67))
	        else
		        vars['dateMenu']:setVisible(false)

                -- 해더가 아닌 셀은 해더 영역이 off되므로 세로정렬을 다시 해줌
                vars['entireMenu']:setPositionY(25/2)
		        return
	        end

	        -- N차 경기
	        -- 1,2,3 (4) 5,6,7
	        local day_idx = math.floor((idx - 1)/clan_group_cnt) + 1

	        -- 요일 표기
            local week_str = g_clanWarData:getDayOfWeekString(match_number)

	        -- 오늘 진행 여부
	        if (match_number == g_clanWarData.m_clanWarDay) then
	            vars['todaySprite']:setVisible(true)
		        if (g_clanWarData:getClanWarState() == ServerData_ClanWar.CLANWAR_STATE['OPEN']) then
			        week_str = week_str .. ' - ' .. Str('오늘의 경기')
		        end
		        --vars['dateLabel']:setColor(COLOR['BLACK'])
	        end
	        -- 날짜 정보 라벨 세팅
	        vars['dateLabel']:setString(week_str)
        end

        -------------------------------------
        -- function setClanInfo
        -------------------------------------
        function UI_ListItem_ClanWarGroupStageMatch:setClanInfo(idx, data)
             local vars = self.vars

	         local prefix = 'a_'
	         if (idx == 2) then
		        prefix = 'b_'
	         end

             local match_number = data['day'] or 1
             local is_today = (match_number == g_clanWarData.m_clanWarDay)

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
                    --vars['winSprite2']:setVisible(true)
                else
                    vars['defeatSprite2']:setVisible(true)
                    --vars['winSprite1']:setVisible(true)
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

	         -- 내 클랜 표시 (오늘 경기만)
	         local my_clan_id = g_clanWarData:getMyClanId()    
             if (my_clan_id == clan_id) and (is_today == true) then
                vars['leagueMeNode']:setVisible(true)
             end

             -- 오늘 경기 강조
             vars['attackVisual']:setVisible(is_today)
             vars['normalIconNode']:setVisible(not is_today)

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
                local node = vars['clanMarkNode'..idx]
                if (node) then
                    node:setVisible(true)
                    node:addChild(clan_icon)
                end
            end

            local win, lose = data[prefix .. 'win_cnt'] or 0, data[prefix .. 'lose_cnt'] or 0
            local win_cnt = data[prefix .. 'member_win_cnt'] or 0

            vars['scoreLabel' .. idx]:setString(tostring(win_cnt))
        end

        -------------------------------------
        -- function setResult
        -------------------------------------
        function UI_ListItem_ClanWarGroupStageMatch:setResult(result) -- A가 win : true,  lose : false
            local vars = self.vars

            vars['defeatSprite1']:setVisible(not result)
            vars['defeatSprite2']:setVisible(result)
            --vars['winSprite2']:setVisible(not result)
            --vars['winSprite1']:setVisible(result)
        end

        -------------------------------------
        -- function click_gotoMatch
        -------------------------------------
        function UI_ListItem_ClanWarGroupStageMatch:click_gotoMatch()

            -- 클랜전에 참여중이지 않은 유저 (조별리그에서는 참여를 했는데 탈락하는 경우는 없다)
            if (g_clanWarData:getMyClanState() == ServerData_ClanWar.CLANWAR_CLAN_STATE['NOT_PARTICIPATING']) then
                local msg = Str('소속된 클랜이 클랜전에 참가하지 못했습니다.')
                local sub_msg = Str('각종 클랜 활동 기록으로 참가 클랜이 결정됩니다.\n꾸준한 클랜 활동을 이어가 주시기 바랍니다.')
                MakeSimplePopup2(POPUP_TYPE.OK, msg, sub_msg)
                return
            end
    
            -- 1.오픈 여부 확인
	        local is_open, msg = g_clanWarData:checkClanWarState_League()
	        if (not is_open) then
		        MakeSimplePopup(POPUP_TYPE.OK, msg)
		        return
	        end

            local success_cb = function(struct_match, match_info)
                -- 상대가 유령클랜이거나 클랜정보가 없는 경우
		        if (match_info) then
                    local no_clan_func = function()
                        local msg = Str('대전 상대가 없어 부전승 처리되었습니다.')
                        MakeSimplePopup(POPUP_TYPE.OK, msg)
                    end
            
                    local clan_id_a = match_info['a_clan_id']
                    local clan_id_b = match_info['b_clan_id']
                    if (clan_id_a == 'loser') then
                         no_clan_func()
                        return               
                    end
            
                    if (clan_id_b == 'loser') then
                         no_clan_func()
                        return               
                    end

                    local my_clan_info = g_clanWarData:getClanInfo(clan_id_a)
                    if (not my_clan_info) then         
                        no_clan_func()
                        return
                    end

                    local enemy_clan_info = g_clanWarData:getClanInfo(clan_id_b)
                    if (not enemy_clan_info) then
                        no_clan_func()
                        return
                    end
                end

                local ui_clan_war_matching = UI_ClanWarMatchingScene(struct_match)
            end

            g_clanWarData:request_clanWarMatchInfo(success_cb)
        end




local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ListItem_ClanWarGroupStageRankInGroup
-- @brief 클랜전 조별리그에서 조별 클랜 순위 리스트 아이템
-------------------------------------
UI_ListItem_ClanWarGroupStageRankInGroup = class(PARENT, {
     })

        -------------------------------------
        -- function init
        -- @param struct_league_item StructClanWarLeagueItem
        -------------------------------------
        function UI_ListItem_ClanWarGroupStageRankInGroup:init(struct_league_item)
            local vars = self:load('clan_war_lobby_item_rank_new.ui')

	        local clan_id = struct_league_item:getClanId()
	        local struct_clan_rank = g_clanWarData:getClanInfo(clan_id)
	        if (not struct_clan_rank) then
		        return
	        end

            -- 전체 5일동안 이루어진 경기에서 얼마나 이겼는지
            local clan_id = struct_league_item:getClanId()

            -- 클랜 순위 (조 내에서)
            local clan_rank = struct_league_item:getLeagueRank()
            local is_pass = (1 <= clan_rank) and (clan_rank <= 2) -- 조별리그 통과 여부
            local font_color_tag = conditionalOperator(is_pass, '{@MUSTARD}', '')

            do -- 승, 패, 세트, 게임, 보상
                -- 매치 승리 수
                local win_cnt = struct_league_item:getWinCount()
                vars['winRoundLabel']:setString(font_color_tag .. tostring(win_cnt))

                -- 매치 패배 수
                local lose_cnt = struct_league_item:getLoseCount()
                vars['loseRoundLabel']:setString(font_color_tag .. tostring(lose_cnt))

                -- 세트 승리 수
                local set_score = struct_league_item:getSetScore()
                vars['setScoreLabel']:setString(font_color_tag .. tostring(set_score))

                -- 게임 승리 수
                local game_score = struct_league_item:getGameWin()
                vars['gameScoreLabel']:setString(font_color_tag .. tostring(game_score))

                -- 보상 (클랜코인 수)
                local clancoin = g_clanWarData:getClancoinRewardCount_atGroupStage(clan_rank)
                vars['clanCionLabel']:setString(clancoin or '')
            end

            -- 클랜 정보 (이름 랭크)
            local clan_name = struct_clan_rank:getClanName() or ''
            vars['clanNameLabel']:setString(font_color_tag .. clan_name)

	        if (clan_rank <= 0) then
		        clan_rank = '-'
	        end
            vars['rankLabel']:setString(font_color_tag .. tostring(clan_rank))

            -- 클랜 마크
             local clan_icon = struct_clan_rank:makeClanMarkIcon()
             if (clan_icon) then
                if (vars['clanMarkNode']) then
                    vars['clanMarkNode']:addChild(clan_icon)
                end
            end

            -- 토너먼트 진출 가능 표시
            vars['finalSprite']:setVisible(is_pass)

	        -- 내 클랜은 강조 표시
            local my_clan_id = g_clanWarData:getMyClanId()
            vars['rankMeSprite']:setVisible(my_clan_id == clan_id)
            vars['popupBtn']:registerScriptTapHandler(function() UI_ClanWarLeagueRankInfoPopup(struct_league_item) end)
        end


        -------------------------------------
        -- function setClickEnabled
        -------------------------------------
        function UI_ListItem_ClanWarGroupStageRankInGroup:setClickEnabled(enabled)
            local vars = self.vars
            vars['popupBtn']:setEnabled(enabled)
        end