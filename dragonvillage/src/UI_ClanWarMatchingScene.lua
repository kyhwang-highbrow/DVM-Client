local PARENT = UI

-------------------------------------
-- class UI_ClanWarMatchingScene
-------------------------------------
UI_ClanWarMatchingScene = class(PARENT,{
        m_meTableView = 'UIC_TableView',
        m_enemyTableView = 'UIC_TableView',

        m_myClanStructMatch = 'StructClanWarMatching',
        m_enemyClanStructMatch = 'StructClanWarMatching',
    })


-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarMatchingScene:init(struct_match_my_clan, struct_match_enemy_clan)
    local vars = self:load('clan_war_match_scene.ui')
    UIManager:open(self, UIManager.SCENE)

    self:setMatchingData(struct_match_my_clan, struct_match_enemy_clan)

    self:initUI()
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClanWarMatchingScene')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWarMatchingScene:initUI()
    local vars = self.vars
    local l_myClan = self.m_myClanStructMatch:getDefendMembers()

    -- 테이블 뷰 인스턴스 생성
    self.m_meTableView = UIC_TableView(vars['meClanListNode'])
    self.m_meTableView.m_defaultCellSize = cc.size(548, 80)
    self.m_meTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.m_meTableView:setCellUIClass(UI_ClanWarMatchingSceneListItem)
    self.m_meTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.m_meTableView:setItemList(l_myClan)

    local l_enemyClan = self.m_enemyClanStructMatch:getDefendMembers()

    -- 테이블 뷰 인스턴스 생성
    self.m_enemyTableView = UIC_TableView(vars['rivalClanMenu'])
    self.m_enemyTableView.m_defaultCellSize = cc.size(548, 80)
    self.m_enemyTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.m_enemyTableView:setCellUIClass(UI_ClanWarMatchingSceneListItem)
    self.m_enemyTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.m_enemyTableView:setItemList(l_enemyClan)
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_ClanWarMatchingScene:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanWarMatchingScene:refresh()
end

-------------------------------------
-- function setMatchingData
-------------------------------------
function UI_ClanWarMatchingScene:setMatchingData(struct_match_my_clan, struct_match_enemy_clan)
    self.m_myClanStructMatch = struct_match_my_clan
    self.m_enemyClanStructMatch = struct_match_enemy_clan
end