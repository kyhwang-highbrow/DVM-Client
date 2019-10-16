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
    
	local l_round = {2, 4 ,8, 16, 32, 64}
	for _, round in ipairs(l_round) do
        self:setTournament(round)
    end
end

-------------------------------------
-- function setTournament
-------------------------------------
function UI_ClanWarTournamentTree:setTournament(round)
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

    -- 결승
    for i, data in ipairs(l_tournament) do
        local ui = UI()
        ui:load('clan_war_tournament_tree_item.ui')
        local pos_x = -500 + (round-1) * 150
        local pos_y = 750
        local idx_y = i
        if (i > total_team/2) then
            pos_x = 350 + (350 - pos_x)
            idx_y = i - total_team/2
        end

        ui.root:setPosition(pos_x, pos_y - 50 * idx_y)
        scroll_menu:addChild(ui.root)
    end
end
