
-------------------------------------
-- class UI_ClanWarTournamentTree
-------------------------------------
UI_ClanWarTournamentTree = class({
        vars = 'vars',
        m_scrollMenu = 'ScrollMenu',
        m_lPosY = 'list',

        m_structTournament = 'StructClanWarTournament',
        m_maxRound = 'number',
     })

local leaf_width = 260 
local L_ROUND = {64, 32, 16, 8, 4, 2}
-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarTournamentTree:init(vars)
    self.vars = vars
    self.m_maxRound = 32
    
    self.m_lPosY = {1,1,1,1,1,1,1,1,1}
	
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
    self:initScroll()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanWarTournamentTree:refresh()
    local success_cb = function(ret)
        self:setTournamentData(ret)
	end

    g_clanWarData:request_clanWarLeagueInfo(nil ,success_cb) --team 을 nil로 요청하면 자신 클랜이 속한 조 정보가 내려옴
end

-------------------------------------
-- function setTournamentData
-------------------------------------
function UI_ClanWarTournamentTree:setTournamentData(ret)
	self.m_structTournament = StructClanWarTournament(ret)
    
    local l_round = {32, 16, 8}
	for round_idx, round in ipairs(l_round) do
        self:setTournament(round_idx, round)
    end


    local l_round = {32, 16, 8}
	for round_idx, round in ipairs(l_round) do
        self:setReverseTournament(round_idx, round)
    end

    self:setFinal()
end

-------------------------------------
-- function setFinal
-------------------------------------
function UI_ClanWarTournamentTree:setFinal()
    
    local y = (self.m_lPosY[1] + self.m_lPosY[2])/2
    local pos_y = { y - 50, y + 50, y}
    local pos_x = {200, 200 + leaf_width*2, 200 + leaf_width}
    local vars = self.vars
    local struct_clan_war_tournament = self.m_structTournament

    local l_list = struct_clan_war_tournament:getTournamentListByRound(4)
    local total_y = 300
    local term = 0
    
    local clan1 = {}
    local clan2 = {}
    local item_idx = 1
    for idx, data in ipairs(l_list) do
        if (idx%2 == 1) then
            clan1 = data
        else
            clan2 = data

                local ui = self:makeTournamentLeaf(4, item_idx, clan1, clan2)
                if (ui) then
                    ui.root:setPosition(pos_x[item_idx], pos_y[item_idx])
                    self.m_scrollMenu:addChild(ui.root)
                    item_idx = item_idx + 1
                end

        end
    end

    local l_list = struct_clan_war_tournament:getTournamentListByRound(2)
    local total_y = 300
    local term = 0
    
    local clan1 = {}
    local clan2 = {}
    local item_idx = 1
    for idx, data in ipairs(l_list) do
        if (idx%2 == 1) then
            clan1 = data
        else
            clan2 = data

                local ui = self:makeTournamentLeaf(2, item_idx, clan1, clan2)
                if (ui) then
                    ui.root:setPosition(pos_x[3], pos_y[3])
                    self.m_scrollMenu:addChild(ui.root)
                    item_idx = item_idx + 1
                end

        end
    end

end

-------------------------------------
-- function setTournament
-------------------------------------
function UI_ClanWarTournamentTree:setTournament(round_idx, round)
    local vars = self.vars
    local struct_clan_war_tournament = self.m_structTournament

    local l_list = struct_clan_war_tournament:getTournamentListByRound(round)
    local total_y = 300
    local term = 0
    
    local clan1 = {}
    local clan2 = {}
    local item_idx = 1
    for idx, data in ipairs(l_list) do
        if (idx%2 == 1) then
            clan1 = data
        else
            clan2 = data
            if (idx <= (#l_list)/2) then
                local ui = self:makeTournamentLeaf(round, item_idx, clan1, clan2)
                if (ui) then
                    ui.root:setPositionX(-500 + (round_idx-1) * leaf_width)
                    self.m_scrollMenu:addChild(ui.root)
                    item_idx = item_idx + 1
                end
            end
        end
    end
end

-------------------------------------
-- function setReverseTournament
-------------------------------------
function UI_ClanWarTournamentTree:setReverseTournament(round_idx, round)
    local vars = self.vars
    local struct_clan_war_tournament = self.m_structTournament

    local l_list = struct_clan_war_tournament:getTournamentListByRound(round)
    local total_y = 300
    local term = 0
    
    local clan1 = {}
    local clan2 = {}
    local item_idx = 1
    for idx, data in ipairs(l_list) do
        if (idx%2 == 1) then
            clan1 = data
        else
            clan2 = data
            if (idx > (#l_list)/2) then
                local ui = self:makeTournamentLeaf(round, item_idx, clan1, clan2)
                if (ui) then
                    ui.root:setPositionX(900 - (-500 + (round_idx-1) * leaf_width))
                    self.m_scrollMenu:addChild(ui.root)
                    item_idx = item_idx + 1
                end
            end
        end
    end
end

-------------------------------------
-- function makeTournamentLeaf
-------------------------------------
function UI_ClanWarTournamentTree:makeTournamentLeaf(round, item_idx, clan1, clan2)
    local vars = self.vars
    local term = 30
    local width = 100

    local struct_clan_war_tournament = self.m_structTournament
    local clan1_id = clan1['clan_id']
    local clan2_id = clan2['clan_id']

    local struct_clan_rank_1 = struct_clan_war_tournament:getClanInfo(clan1_id)
    local struct_clan_rank_2 = struct_clan_war_tournament:getClanInfo(clan2_id)

    local ui = UI_ClanWarTournamentTreetLeafItem(round)
    local clan_name1 = ''
    local clan_name2 = ''
    
    if (struct_clan_rank_1) then
        clan_name1 = struct_clan_rank_1:getClanName() .. clan1['group_stage_no']
    end
    ui.vars['clanNameLabel1']:setString(clan_name1)
    
    if (struct_clan_rank_2) then
        clan_name2 = struct_clan_rank_2:getClanName().. clan2['group_stage_no']
    end
    ui.vars['clanNameLabel2']:setString(clan_name2)

    local pos_y = 0
    -- 첫 경기일 경우
    if (round == self.m_maxRound) then
        pos_y = 400 + -math.ceil(item_idx/2 - 1) * term + -(item_idx - 1) * width  
        self.m_lPosY[item_idx] = pos_y
        ui.root:setPositionY(pos_y)
        return ui
    end

    local idx = item_idx * 2
    pos_y = (self.m_lPosY[idx] + self.m_lPosY[idx - 1])/2
        
    self.m_lPosY[item_idx] = pos_y
    ui.root:setPositionY(pos_y)    
    return ui
end


-------------------------------------
-- function initScroll
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
    scroll_menu:retain()
    scroll_menu:removeFromParent()
    scroll_view:addChild(scroll_menu)
    scroll_menu:release()

    local size_y = size.height - target_size.height
    scroll_view:setDirection(cc.SCROLLVIEW_DIRECTION_BOTH)

    self.m_scrollMenu = scroll_menu
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