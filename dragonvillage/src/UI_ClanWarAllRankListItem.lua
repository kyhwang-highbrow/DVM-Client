local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ClanWarAllRankListItem
-------------------------------------
UI_ClanWarAllRankListItem = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarAllRankListItem:init(data)
    local vars = self:load('clan_war_lobby_item_all_rank_01.ui')

	-- 첫 번째 클랜의 조 이름을 가져옴
	local struct_league_item = data[1]
	local league = struct_league_item:getLeague()
	vars['teamLabel']:setString(Str('{1}조', league))

    -- 각 조마다 랭킹 정보 입력
	for i, struct_league_item in ipairs(data) do
		if (vars['itemNode' .. i]) then
			if (struct_league_item) then
				local ui_item = UI_ClanWarAllRankListItemOfItem(struct_league_item)
				vars['itemNode' .. i]:addChild(ui_item.root)
			end
		end
	end
end








local PARENT = UI

-------------------------------------
-- class UI_ClanWarAllRankListItemOfItem
-- @breif 전체랭킹 아이템의 테이블뷰 아이템
-------------------------------------
UI_ClanWarAllRankListItemOfItem = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarAllRankListItemOfItem:init(struct_league_item)
    local vars = self:load('clan_war_lobby_item_all_rank_02.ui')

    -- 클랜 정보
	local struct_clan_rank = struct_league_item:getClanInfo()
    local clan_name = struct_clan_rank:getClanName()
    local clan_rank = tostring(struct_league_item:getLeagueRank())
    vars['clanNameLabel']:setString(Str(clan_name))
    vars['rankLabel']:setString(clan_rank)

	-- 전체 5일동안 이루어진 경기에서 얼마나 이겼는지
    local clan_id = struct_league_item:getClanId()
    local lose_cnt = struct_league_item:getLoseCount()
    local win_cnt = struct_league_item:getWinCount()
    vars['scoreLabel']:setString(Str('{1}-{2}', win_cnt, lose_cnt))
end