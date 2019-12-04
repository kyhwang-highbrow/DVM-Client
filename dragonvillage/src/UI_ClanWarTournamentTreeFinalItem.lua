local PARENT = UI

local L_ROUND = {8, 4, 2}
local WIN_COLOR = cc.c3b(127, 255, 212)
-------------------------------------
-- class UI_ClanWarTournamentTreeFinalItem
-------------------------------------
UI_ClanWarTournamentTreeFinalItem = class(PARENT, {
		m_structTournament = 'StructClanWarTournament',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarTournamentTreeFinalItem:init(struct_tournament)
    local vars = self:load('clan_war_tournament_final_item.ui')
	self.m_structTournament = struct_tournament

	self:initUI(data)
	self:setTitle()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWarTournamentTreeFinalItem:initUI(data)
	local vars = self.vars
    local today_round = g_clanWarData:getTodayRound()
    local round_text = Str('결승전')

    -- 이긴 가지 sprite 켜줌
    -- ex) 지금 8강일 때에는 16강 가지 까지 켜쥼
    if (today_round <= 8) then
        vars['round16LineSprite1']:setColor(WIN_COLOR)
		vars['round16LineSprite1']:setVisible(true)
        vars['round16LineSprite2']:setColor(WIN_COLOR)
		vars['round16LineSprite2']:setVisible(true)
        vars['round16LineSprite3']:setColor(WIN_COLOR)
		vars['round16LineSprite3']:setVisible(true)
        vars['round16LineSprite4']:setColor(WIN_COLOR)
		vars['round16LineSprite4']:setVisible(true)
    end

    if (today_round <= 4) then
        vars['round8LineSprite1']:setColor(WIN_COLOR)
		vars['round8LineSprite1']:setVisible(true)
        vars['round8LineSprite2']:setColor(WIN_COLOR)
		vars['round8LineSprite2']:setVisible(true)
    end

    if (today_round <= 2) then
        vars['round4LineSprite']:setColor(WIN_COLOR)
		vars['round4LineSprite']:setVisible(true)
    end

    -- 진행중인 라운드에 표기
	if (today_round == 2) then
	    vars['todaySprite']:setVisible(true)
        vars['roundLabel']:setColor(COLOR['black'])
        if (g_clanWarData:getClanWarState() == ServerData_ClanWar.CLANWAR_STATE['OPEN']) then
            round_text = round_text .. ' - ' .. Str('진행중')
            vars['attackVisual']:setVisible(true)
            vars['normalIconSprite']:setVisible(false)
        end
	else
        vars['normalIconSprite']:setVisible(true)
        vars['attackVisual']:setVisible(false)
    end 


    -- 아직 진행하지 않은 곳(값이 없는)의 클랜 이름은 = {1}강 승리 클랜
    vars['roundLabel']:setString(round_text)
    if (today_round > 2) then
        vars['finalClanLabel1']:setString(Str('{1}강', 4) .. ' ' .. Str('승리 클랜'))
        vars['finalClanLabel2']:setString(Str('{1}강', 4) .. ' ' .. Str('승리 클랜'))
        vars['finalClanLabel1']:setColor(COLOR['gray'])
        vars['finalClanLabel2']:setColor(COLOR['gray'])
    else
        -- 결승전 생성
        local l_list = self.m_structTournament:getTournamentListByRound(2)
        local final_data = l_list[1]
        if (not final_data) then
            return
        end
        local struct_clan_rank_1 = g_clanWarData:getClanInfo(final_data['a_clan_id'])
        local struct_clan_rank_2 = g_clanWarData:getClanInfo(final_data['b_clan_id'])
        if (not struct_clan_rank_1) then
            struct_clan_rank_1 = StructClanRank()
        end

        if (not struct_clan_rank_2) then
            struct_clan_rank_2 = StructClanRank()
        end

        -- 이름, 이긴 클랜, 등등 세팅
		local round_text = Str('결승전')
        local final_name_1 = struct_clan_rank_1:getClanName()
        local final_name_2 = struct_clan_rank_2:getClanName()
        vars['finalClanLabel1']:setString(final_name_1)
        vars['finalClanLabel2']:setString(final_name_2)

 
        local clan_node1 = struct_clan_rank_1:makeClanMarkIcon()
        if (clan_node1) then
            vars['clanMarkNode1']:addChild(clan_node1)
        end

        local clan_node2 = struct_clan_rank_2:makeClanMarkIcon()
        if (clan_node2) then
            vars['clanMarkNode2']:addChild(clan_node2)
        end


        if (today_round == 1) then
            if (g_clanWarData:getClanWarState() == ServerData_ClanWar.CLANWAR_STATE['OPEN']) then
			    round_text = round_text .. '-' .. Str('진행중')
            end
			local label = 'round2_1TodaySprite'
			if (vars[label]) then
				vars[label]:setVisible(true)
			end
            vars['winVisual']:setVisible(true)
            vars['clanMarkNode']:setVisible(true)

            local is_clan_1_win = false
            if (final_data['win_clan']) then
                if (final_data['win_clan'] == final_data['a_clan_id']) then
                    is_clan_1_win = true
                end
            end
            local clan_win_1 = is_clan_1_win
            vars['defeatSprite1']:setVisible(not clan_win_1)
            vars['defeatSprite2']:setVisible(clan_win_1)

            local mark_icon = nil
			local win_clan_id
            if (clan_win_1) then
                mark_icon = struct_clan_rank_1:makeClanMarkIcon()
				win_clan_id = struct_clan_rank_1['id']
            else
                mark_icon = struct_clan_rank_2:makeClanMarkIcon()
				win_clan_id = struct_clan_rank_1['id']
            end
            if (mark_icon) then
                vars['clanMarkNode']:addChild(mark_icon)
            end
			vars['clanBtn']:registerScriptTapHandler(function() g_clanData:requestClanInfoDetailPopup(win_clan_id) end)
        end
    end

	local label_lua_name = 'round2_1Label'
	if (vars[label_lua_name]) then
		vars[label_lua_name]:setString(round_text)
	end

	if (today_round <= 2) then
		if (vars['finalInfoBtn']) then
			vars['finalInfoBtn']:registerScriptTapHandler(function() UI_ClanWarMatchInfoDetailPopup.createMatchInfoPopup(final_data) end)
		end
	else
		UIManager:toastNotificationRed(Str('아직 진행되지 않은 경기입니다.'))
	end
end

-------------------------------------
-- function setTitle
-------------------------------------
function UI_ClanWarTournamentTreeFinalItem:setTitle()
	local vars = self.vars

	for i, round in ipairs(L_ROUND) do
		for idx = 1,2 do
			local round_text = g_clanWarData:getRoundText(round)
			if (g_clanWarData:getClanWarState() == ServerData_ClanWar.CLANWAR_STATE['OPEN']) then
			    local today_round = g_clanWarData:getTodayRound()
			    if (round == today_round) then
			        round_text = round_text .. ' - ' .. Str('진행중')
					local label = 'round' .. round ..'_' .. idx .. 'TodaySprite'
					if (vars[label]) then
						vars[label]:setVisible(true)
					end
				end
			end
			local label_lua_name = 'round' .. round ..'_' .. idx .. 'Label'
			if (vars[label_lua_name]) then
				vars[label_lua_name]:setString(round_text)
			end
		end
	end
end