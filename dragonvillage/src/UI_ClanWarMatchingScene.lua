local PARENT = UI

-------------------------------------
-- class UI_ClanWarMatchingScene
-------------------------------------
UI_ClanWarMatchingScene = class(PARENT,{
        m_myTableView = 'UIC_TableView',
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

    -- 내 클랜(왼쪽 클랜 테이블 뷰)
    local struct_my_clan_match = self.m_myClanStructMatch
    local my_create_func = function(ui, data)
        local clan_member_uid = data['uid']
        local struct_clan_member_info = struct_my_clan_match:getClanMembersInfo(clan_member_uid)
        ui:setClanMemberInfo(struct_clan_member_info)
    end

    -- 테이블 뷰 인스턴스 생성
    local l_myClan = struct_my_clan_match:getDefendMembers()
    
    self.m_myTableView = UIC_TableView(vars['meClanListNode'])
    self.m_myTableView.m_defaultCellSize = cc.size(548, 80 + 5)
    self.m_myTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.m_myTableView:setCellUIClass(UI_ClanWarMatchingSceneListItem_My, my_create_func)
    self.m_myTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.m_myTableView:setItemList(l_myClan)


    -- 상대 클랜(오른쪽 클랜 테이블 뷰)
    local struct_enemy_clan_match = self.m_enemyClanStructMatch
    local enemy_create_func = function(ui, data)
        local clan_member_uid = data['uid']
        local struct_clan_member_info = struct_enemy_clan_match:getClanMembersInfo(clan_member_uid)
        ui:setClanMemberInfo(struct_clan_member_info)
    end

    -- 테이블 뷰 인스턴스 생성
    local l_enemyClan = self.m_enemyClanStructMatch:getDefendMembers()

    self.m_enemyTableView = UIC_TableView(vars['rivalClanMenu'])
    self.m_enemyTableView.m_defaultCellSize = cc.size(548, 80 + 5)
    self.m_enemyTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.m_enemyTableView:setCellUIClass(UI_ClanWarMatchingSceneListItem_Enemy, enemy_create_func)
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