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

	local clan_id = struct_league_item:getClanId()
	local struct_clan_rank = g_clanWarData:getClanInfo(clan_id)
	if (not struct_clan_rank) then
		return
	end

    -- 전체 5일동안 이루어진 경기에서 얼마나 이겼는지
    local clan_id = struct_league_item:getClanId()
    local lose_cnt = struct_league_item:getLoseCount()
    local win_cnt = struct_league_item:getWinCount()
    vars['winRoundLabel']:setString(Str('{@green}{1}{@apricot}-{@red}{2}', win_cnt, lose_cnt))
    
    -- 클랜 정보 (이름 랭크)
    local clan_name = struct_clan_rank:getClanName() or ''
    local clan_rank = struct_league_item:getLeagueRank()
    vars['clanNameLabel']:setString(Str(clan_name))

	if (clan_rank == 0) then
		clan_rank = '-'
	end
    vars['rankLabel']:setString(tostring(clan_rank))

    -- 클랜 마크
     local clan_icon = struct_clan_rank:makeClanMarkIcon()
     if (clan_icon) then
        if (vars['clanMarkNode']) then
            vars['clanMarkNode']:addChild(clan_icon)
        end
    end

    vars['finalSprite']:setVisible(false)
    -- 1, 2등은 토너먼트 진출 가능 표시
    if (clan_rank) then
        if (clan_rank == 2) or (clan_rank == 1) then
            vars['finalSprite']:setVisible(true)
        end
    end

	-- 내 클랜은 강조 표시
    local my_clan_id = g_clanWarData:getMyClanId()
    vars['rankMeSprite']:setVisible(my_clan_id == clan_id)
    if (clan_rank ~= '-') then
        vars['popupBtn']:registerScriptTapHandler(function() UI_ClanWarLeagueRankInfoPopup(struct_league_item) end)
    else
        vars['popupBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed(Str('아직 진행되지 않은 경기입니다.')) end)
    end
end



local PARENT = UI

-------------------------------------
-- class UI_ClanWarLeagueRankInfoPopup
-------------------------------------
UI_ClanWarLeagueRankInfoPopup = class(PARENT, {
     })


-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarLeagueRankInfoPopup:init(struct_league_item)
    local vars = self:load('clan_war_league_rank_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    self:initUI(struct_league_item)

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClanWarLeagueMatchInfoPopup')

    self.vars['closeBtn']:registerScriptTapHandler(function() self:close() end)

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWarLeagueRankInfoPopup:initUI(struct_league_item)
    local vars = self.vars

	local clan_id = struct_league_item:getClanId()
    local struct_clan_rank = g_clanWarData:getClanInfo(clan_id)

    local ui = UI_ClanWarLeagueRankListItem(struct_league_item)
    vars['rankItemNode']:addChild(ui.root)

    -- 게임 스코어 모두 더한 값
    local total_set_win_cnt = struct_league_item:getGameWin()
    vars['setScoreLabel']:setString(tostring(total_set_win_cnt))

    -- 세트 스코어 모두 더한 값
    local total_set_score = struct_league_item['member_win_cnt']
    vars['victoryLabel']:setString(tostring(total_set_score))

    -- 클랜 정보 (레벨, 경험치, 참여 인원, 생성일)
	local clan_lv = struct_clan_rank:getClanLv() or ''
    local clan_lv_exp = string.format('Lv.%d (%.2f%%)', clan_lv, struct_clan_rank['exp']/10000)
    vars['clanLvExpLabel']:setString(clan_lv_exp)

    local max_member = struct_league_item:getPlayMemberCnt()
    vars['matchNumLabel']:setString(tostring(max_member))

    local create_at = struct_clan_rank:getCreateAtText()
	vars['creationLabel']:setString(create_at)
    vars['roundLabel']:setString(Str('조별리그'))
end

