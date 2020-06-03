-------------------------------------
-- class UI_ClanWarLastGroupStagePopup
-------------------------------------
UI_ClanWarLastGroupStagePopup = class(UI,{
        m_structLeaguecache = 'table[group] = struct',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarLastGroupStagePopup:init(struct_league)
    local vars = self:load('clan_war_popup_all_rank.ui')
	UIManager:open(self, UIManager.POPUP)
    
    self.m_structLeaguecache = {}
    
    -- 초기화
    self:initUI()
    self:initButton()
    --self:refresh()

	-- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClanWarLastGroupStagePopup')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWarLastGroupStagePopup:initUI()
	local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanWarLastGroupStagePopup:initButton()
	local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanWarLastGroupStagePopup:refresh()
    local group = 99 --'all'

     -- 전체 랭킹만 받아서 출력
	local success_cb = function(ret)
		local struct_clan_war_league = StructClanWarLeague(ret)
        self.m_structLeaguecache[group] = struct_clan_war_league
        self:setAllGroupRankList()
	end

    g_clanWarData:request_clanWarLeagueInfo(group, success_cb)
end

-------------------------------------
-- function setAllGroupRankList
-- @brief 전체 보기(모든 그룹 순위)
-------------------------------------
function UI_ClanWarLastGroupStagePopup:setAllGroupRankList()
    local vars = self.vars
	local struct_clan_war = self.m_structLeaguecache[99]

	local l_team = struct_clan_war:getAllClanWarLeagueRankList()
    vars['listNode']:removeAllChildren()

	local create_cb = function(ui, data)
		ui.vars['teamLabel']:setColor(COLOR['white'])
	end
	
	-- 테이블 뷰 인스턴스 생성
    local table_view_td = UIC_TableViewTD(vars['listNode'])
    table_view_td.m_cellSize = cc.size(420, 316)
    table_view_td.m_nItemPerCell = 3
	table_view_td:setCellUIClass(UI_ListItem_ClanWarGroupStageRankInAll, create_cb)
	table_view_td:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view_td:setItemList(l_team)
end

-------------------------------------
-- function open
-------------------------------------
function UI_ClanWarLastGroupStagePopup.open()
    local group = 99 --'all'

     -- 전체 랭킹만 받아서 출력
	local success_cb = function(ret)
        local ui = UI_ClanWarLastGroupStagePopup()
		local struct_clan_war_league = StructClanWarLeague(ret)
        ui.m_structLeaguecache[group] = struct_clan_war_league
        ui:setAllGroupRankList()
	end

    g_clanWarData:request_clanWarLeagueInfo(group, success_cb)
end
