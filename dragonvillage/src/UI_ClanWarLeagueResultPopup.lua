-------------------------------------
-- class UI_ClanWarLeague
-------------------------------------
UI_ClanWarLeagueResultPopup = class(UI,{
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarLeagueResultPopup:init(struct_league)
    local vars = self:load('clan_war_league_result_popup.ui')
	UIManager:open(self, UIManager.POPUP)
    -- 초기화
    self:initRankUI(struct_league)

	-- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClanWarLeagueResultPopup')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWarLeagueResultPopup:initRankUI(struct_league)
	local vars = self.vars

	local l_rank = struct_league:getClanWarLeagueRankList()
    -- 세트 점수는 더해서  struct_league에 강제로 넣어줌
    for i, data in ipairs(l_rank) do
        local clan_id = data['clan_id']
        data['total_win_cnt'] = struct_league:getTotalSetScore(clan_id) or 0
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(vars['listNode'])
    table_view.m_defaultCellSize = cc.size(660, 60 + 5)
    table_view:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    table_view:setCellUIClass(UI_ClanWarLeagueRankListItem)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_rank, false)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWarLeagueResultPopup:initDetailRankUI(struct_league_item)
	local vars = self.vars
	local clan_id = struct_league_item:getClanId()
    local struct_clan_rank = g_clanWarData:getClanInfo(clan_id)

	vars['titleLabel']:setString(Str('{@yellow}{1}조{@default} 순위', struct_league_item:getLeague()))

    local ui = UI_ClanWarLeagueRankListItem(struct_league_item)
    vars['rankItemNode']:addChild(ui.root)

    -- 게임 스코어 모두 더한 값
    local total_set_win_cnt, total_set_lose_cnt = struct_league_item:getGameWin(), struct_league_item:getGameLose()
    local score_history = total_set_win_cnt .. '-' .. total_set_lose_cnt
    vars['setScoreLabel']:setString(score_history)

    -- 세트 스코어 모두 더한 값
    local total_set_score = struct_league_item['total_win_cnt']
    vars['victoryLabel']:setString(tostring(total_set_score))

    -- 클랜 정보 (레벨, 경험치, 참여 인원, 생성일)
	local clan_lv = struct_clan_rank:getClanLv() or ''
    local clan_lv_exp = string.format('Lv.%d (%.2f%%)', clan_lv, struct_clan_rank['exp']/10000)
    vars['clanLvExpLabel']:setString(clan_lv_exp)

    local create_at = struct_clan_rank:getCreateAtText()
	vars['creationLabel']:setString(create_at)

	vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end
