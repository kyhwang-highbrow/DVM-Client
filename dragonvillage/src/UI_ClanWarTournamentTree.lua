
-------------------------------------
-- class UI_ClanWarTournamentTree
-------------------------------------
UI_ClanWarTournamentTree = class({
        vars = 'vars',
        m_scrollMenu = 'ScrollMenu',
        m_lPosY = 'list',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarTournamentTree:init(vars)
    self.vars = vars

    self.m_lPosY = {}
	
    -- 초기화
    self:initUI()
    self:initButton()
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

    vars['tournamentMenu']:setVisible(true)
    vars['leagueMenu']:setVisible(false)

    self:initScroll()
    --[[
	local l_round = {64, 32, 16, 8}
	for idx, round in ipairs(l_round) do
        self:setTournament(idx, round)
    end
    --]]
end

-------------------------------------
-- function setTournament
-------------------------------------
function UI_ClanWarTournamentTree:initScroll()
    local vars = self.vars
    local scroll_node = self.vars['tournamentScrollNode']
    local scroll_menu = self.vars['tournamentScrollMenu']

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
    scroll_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    self.m_scrollMenu = scroll_menu
end

-------------------------------------
-- function setTournament
-------------------------------------
function UI_ClanWarTournamentTree:setTournament(idx, round)
    local vars = self.vars

    local struct_clanwar_tournament = g_clanWarData:request_clanWarTournamentTree()
    local total_team = round
    local l_tournament = struct_clanwar_tournament:getRoundInfo(round)
    local total_y = 300
    local term = 0
    for i, data in ipairs(l_tournament) do
        local ui = UI_ClanWarTournamentTreetLeafItem(round)
        ui.vars['clanNameLabel1']:setString(data['1_clanid'])
        ui.vars['clanNameLabel2']:setString(data['2_clanid'])
        local pos_x = -500 + (idx-1) * 350
        local idx_y = i
        if (i < total_team/2) then
            local pos_y = 0
            if (round ==  64) then
                total_y = total_y - 100 - term
                if (i%2 == 0) then
                    term = 30
                else
                    term = 0
                end             
            else
                local idx = i * 2
                total_y = (self.m_lPosY[idx] + self.m_lPosY[idx - 1])/2
            end
            
            self.m_lPosY[i] = total_y
            ui.root:setPosition(pos_x, total_y)    
            self.m_scrollMenu:addChild(ui.root)
        end
    end

    local ui_item = UI_ClanWarTournamentTreeListItem()
    ui_item.root:setPositionX(-450 + (idx-1) * 300 + 50)
    vars['tournamentMenu']:addChild(ui_item.root)
end






-------------------------------------
-- class UI_ClanWarTournamentTreetLeafItem
-------------------------------------
UI_ClanWarTournamentTreetLeafItem = class(UI, {
})

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarTournamentTreetLeafItem:init(round)
    local vars = self:load('clan_war_tournament_item_leaf.ui')
    if (not data) then
        return
    end
    
    vars['clanNameLabel1']:setString(data['clan_name1'])
    vars['clanNameLabel2']:setString(data['clan_name2'])

    self:setLine()
end

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarTournamentTreetLeafItem:setLine()
    local is_edge = false
    if (round == 32) then
        is_edge = true
    end
    vars['rightLineSprite']:setVisible(true)
    vars['leftLineSprite']:setVisible(not is_edge)
end








-------------------------------------
-- class UI_ClanWarTournamentTreeListItem
-------------------------------------
UI_ClanWarTournamentTreeListItem = class(UI, {
})

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarTournamentTreeListItem:init(data)
    local vars = self:load('clan_war_tournament_item_title.ui')
    if (not data) then
        return
    end
end