-------------------------------------
-- class UI_ClanWarLeagueResultPopup
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
    local create_func = function(ui, data)
        ui:setClickEnabled(false)
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(vars['listNode'])
    table_view.m_defaultCellSize = cc.size(660, 75 + 0)
    table_view:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    table_view:setCellUIClass(UI_ListItem_ClanWarGroupStageRankInGroup)
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

	vars['teamLabel']:setString(Str('{1}조', struct_league_item:getLeague()))
	vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end
