local PARENT = UI

-------------------------------------
-- class UI_ClanWarMatchingScene
-------------------------------------
UI_ClanWarMatchingScene = class(PARENT,{
        m_myTableView = 'UIC_TableView',
        m_enemyTableView = 'UIC_TableView',

        m_tMyStructMatch = 'StructClanWarMatching',
        m_tEnemyStructMatch = 'StructClanWarMatching',
    })


-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarMatchingScene:init(t_my_struct_match, t_enemy_struct_match)
    local vars = self:load('clan_war_match_scene.ui')
    UIManager:open(self, UIManager.SCENE)

    self.m_tMyStructMatch = t_my_struct_match or {}
    self.m_tEnemyStructMatch = t_enemy_struct_match or {}

    self:initUI()
    self:initButton()

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClanWarMatchingScene')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWarMatchingScene:initUI()
    local vars = self.vars

    local round = g_clanWarData:getTodayRound()
    vars['roundLabel']:setString(Str('{1}강', round))
    vars['stateLabel']:setString(Str('진행중'))
    vars['timeLabel']:setString(Str('{1}남음', '10시간 10분'))

    self:setClanInfoUI()
    self:setMemberTableView()
end

-------------------------------------
-- function setClanInfoUI
-------------------------------------
function UI_ClanWarMatchingScene:setClanInfoUI()
    local vars = self.vars

    local struct_clan_match

    for idx = 1, 2 do
        local l_clan = {}
        if (idx == 1) then
            l_clan = self.m_tMyStructMatch
        else
            l_clan = self.m_tEnemyStructMatch            
        end
        
        
        for _, struct_match in pairs(l_clan) do
            struct_clan_match = struct_match
            break
        end

        local clan_id = struct_clan_match:getClanId()
        local struct_clan_rank = g_clanWarData:getClanInfo(clan_id)
        if (struct_clan_rank) then
            -- 클랜 이름
            local clan_name = struct_clan_rank:getClanName()
            vars['clanNameLabel'..idx]:setString(clan_name)

            -- 클랜 마크
            local clan_icon = struct_clan_rank:makeClanMarkIcon()
            if (clan_icon) then
                if (vars['clanMarkNode'..idx]) then
                    vars['clanMarkNode'..idx]:addChild(clan_icon)
                end
            end

            -- 클랜 레벨
            local clan_lv = struct_clan_rank:getClanLv() or ''
            local level_text = string.format('Lv.%d', clan_lv)
            vars['clanlLevelLabel'..idx]:setString(level_text)

            -- 처치 수
            --local win_cnt = struct_clan_match:getWinCnt()
            --vars['clanScoreLabel'..idx]:setString(win_cnt)

            -- 세트 스코어
            vars['matchNumLabel'..idx]:setString('10/10')
        end
    end
end

-------------------------------------
-- function setMemberTableView
-------------------------------------
function UI_ClanWarMatchingScene:setMemberTableView()
    local vars = self.vars

    local create_func = function(ui, struct_match)
        local nick_name = struct_match:getNameTextWithEnemy()
        local attack_state = struct_match:getAttackState()
        local attack_state_text = struct_match:getAttackStateText()

        ui.vars['userNameLabel']:setString(nick_name .. ' - ' .. attack_state_text)
    end

    -- 테이블 뷰 인스턴스 생성
    local l_myClan = self.m_tMyStructMatch
    
    self.m_myTableView = UIC_TableView(vars['meClanListNode'])
    self.m_myTableView.m_defaultCellSize = cc.size(548, 80 + 5)
    self.m_myTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.m_myTableView:setCellUIClass(UI_ClanWarMatchingSceneListItem, create_func)
    self.m_myTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.m_myTableView:setItemList(l_myClan)

    -- 테이블 뷰 인스턴스 생성
    local l_enemyClan = self.m_tEnemyStructMatch

    self.m_enemyTableView = UIC_TableView(vars['rivalClanMenu'])
    self.m_enemyTableView.m_defaultCellSize = cc.size(548, 80 + 5)
    self.m_enemyTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.m_enemyTableView:setCellUIClass(UI_ClanWarMatchingSceneListItem, create_func)
    self.m_enemyTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.m_enemyTableView:setItemList(l_enemyClan)
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_ClanWarMatchingScene:initButton()
    local vars = self.vars
    vars['battleBtn']:registerScriptTapHandler(function() UI_ClanWarSelectScene(self.m_tMyStructMatch, self.m_tEnemyStructMatch) end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanWarMatchingScene:refresh()
end
