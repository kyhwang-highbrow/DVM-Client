local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ClanWarLeagueRankListItem
-------------------------------------
UI_ClanWarLeagueRankListItem = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarLeagueRankListItem:init(struct_league_item)
    local vars = self:load('clan_war_lobby_item_rank.ui')

	local struct_clan_rank = struct_league_item:getClanInfo()

    -- 전체 5일동안 이루어진 경기에서 얼마나 이겼는지
    local clan_id = struct_league_item:getClanId()
    local lose_cnt = struct_league_item:getLoseCount()
    local win_cnt = struct_league_item:getWinCount()
    vars['winRoundLabel']:setString(Str('{@green}{1}{@apricot}-{@red}{2}', win_cnt, lose_cnt))


    -- 세트 스코어 모두 더한 값
    local total_set_win_cnt = struct_league_item['total_score_win']
    local total_set_lose_cnt = struct_league_item['total_score_lose']
    local score_history = total_set_win_cnt .. '-' .. total_set_lose_cnt
    vars['setScoreLabel']:setString(score_history)

    -- 전체 처치수
    local total_kill_cnt = struct_league_item:getTotalWinCount()
    vars['killLabel']:setString(tostring(total_kill_cnt))
	
    -- 클랜 정보 (이름 랭크)
    local clan_name = struct_clan_rank:getClanName()
    local clan_rank = struct_league_item:getLeagueRank()
    vars['clanNameLabel']:setString(Str(clan_name))

	if (clan_rank == 0) then
		clan_rank = '-'
	end
    vars['rankLabel']:setString(tostring(clan_rank))

    -- 클랜 정보 (레벨, 경험치, 참여 인원, 생성일)
	local clan_lv = struct_clan_rank:getClanLv() or ''
    local clan_lv_exp = string.format('Lv.%d (%.2f%%)', clan_lv, struct_clan_rank['exp']/10000)
    vars['clanLvLabel']:setString(clan_lv_exp)

    local max_member = struct_league_item:getPlayMemberCnt()
    vars['partLabel']:setString(max_member)
    
    local create_at = struct_clan_rank['create_date'] or '-'
	vars['clanCreationLabel']:setString(create_at)


    -- 1, 2등은 토너먼트 진출 가능 표시
    if (clan_rank) then
        if (clan_rank == 2) or (clan_rank == 1) then
            vars['finalSprite']:setVisible(true)
            vars['finalSprite']:setVisible(true)
        end
    end

	-- 내 클랜은 강조 표시
    if (struct_league_item['my_clan_id'] == clan_id) then
        vars['rankMeSprite']:setVisible(true)
    end
end