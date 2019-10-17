local PARENT = UI

-------------------------------------
-- class UI_ClanWarTournamentTree
-------------------------------------
UI_ClanWarTournamentTree = class(PARENT, {

     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarTournamentTree:init()
    local vars = self:load('clan_war_tournament_tree.ui')
    UIManager:open(self, UIManager.POPUP)

    -- 씬 전환 효과
    self:sceneFadeInAction()

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClanWarTournamentTree')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

	-- 초기화
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanWarTournamentTree:initButton()
	local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanWarTournamentTree:initUI()
	local vars = self.vars
    
	local l_round = {64, 32, 16, 8, 4, 2}
	for idx, round in ipairs(l_round) do
        self:setTournament(idx, round)
    end
end

-------------------------------------
-- function setTournament
-------------------------------------
function UI_ClanWarTournamentTree:setTournament(idx, round)
    local scroll_node = self.vars['scrollNode']
    local scroll_menu = self.vars['scrollMenu']

    -- ScrollView 사이즈 설정 (ScrollNode 사이즈)
    local size = scroll_node:getContentSize()
    local scroll_view = cc.ScrollView:create()
    scroll_view:setNormalSize(size)
    scroll_node:setSwallowTouch(false)
    scroll_node:addChild(scroll_view)

    -- ScrollView 에 달아놓을 컨텐츠 사이즈(ScrollMenu)
    local target_size = scroll_menu:getContentSize()
    scroll_view:setDockPoint(cc.p(0.5, 1.0))
    scroll_view:setAnchorPoint(cc.p(0.5, 1.0))

    scroll_view:setContentSize(target_size)
    scroll_view:setPosition(ZERO_POINT)
    scroll_view:setTouchEnabled(true)

    -- ScrollMenu를 부모에서 분리하여 ScrollView에 연결
    -- 분리할 부모가 없을 때 에러 없음
    scroll_menu:removeFromParent()
    scroll_view:addChild(scroll_menu)

    local size_y = size.height - target_size.height
    scroll_view:setDirection(cc.SCROLLVIEW_DIRECTION_BOTH)
    local struct_clanwar_tournament = g_clanWarData:request_clanWarTournamentTree()
    local total_team = round
    local l_tournament = struct_clanwar_tournament:getRoundInfo(round)
    
    for i, data in ipairs(l_tournament) do
        local ui = UI_ClanWarTournamentTreeListItem()
        ui.vars['clanNameLabel1']:setString(data['1_clanid'])
        ui.vars['clanNameLabel2']:setString(data['2_clanid'])
        ui.vars['rankLabel']:setString(i)
        local pos_x = -500 + (idx-1) * 300
        local pos_y = 750
        local idx_y = i
        if (i > total_team/2) then
            pos_x = 1150 + (1150 - pos_x)
            idx_y = i - total_team/2
        end

        ui.root:setPosition(pos_x, pos_y - 100 * idx_y)
        scroll_menu:addChild(ui.root)
    end
end






local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ClanWarTournamentTreeListItem
-------------------------------------
UI_ClanWarTournamentTreeListItem = class(PARENT, {
})

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarTournamentTreeListItem:init(data)
    local vars = self:load('clan_war_rank_tournament_item_01.ui')
    if (not data) then
        return
    end
    
    vars['rankLabel']:setString(data['rank'])
    vars['clanNameLabel1']:setString(data['clan_name1'])
    vars['clanNameLabel2']:setString(data['clan_name2'])
end