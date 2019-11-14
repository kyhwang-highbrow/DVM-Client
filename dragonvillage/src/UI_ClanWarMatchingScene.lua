local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_ClanWarMatchingScene
-------------------------------------
UI_ClanWarMatchingScene = class(PARENT,{
        m_myTableView = 'UIC_TableView',
        m_enemyTableView = 'UIC_TableView',

        m_structMatch = 'StructClanWarMatch',
        m_todayMyMatchData = 'data',
    })

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_ClanWarMatchingScene:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ClanWarMatchingScene'
    self.m_titleStr = Str('클랜전')
	--self.m_staminaType = 'pvp'
    self.m_bVisible = true
    self.m_bUseExitBtn = true
    self.m_subCurrency = 'clancoin'
    self.m_uiBgm = 'bgm_lobby'
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ClanWarMatchingScene:click_exitBtn()
    self:close()
end

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarMatchingScene:init(struct_match)
    local vars = self:load('clan_war_match_scene.ui')
    UIManager:open(self, UIManager.SCENE)

    self.m_structMatch = struct_match

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
    if (round) then
        vars['roundLabel']:setString(Str('{1}강', round))
    else
        vars['roundLabel']:setString(Str('조별리그'))
    end
    vars['stateLabel']:setString(Str('진행중'))
    vars['timeLabel']:setString(Str('{1} 남음', '10시간 10분'))

    self:setClanInfoUI()
    self:setMemberTableView()
end

-------------------------------------
-- function setClanInfoUI
-------------------------------------
function UI_ClanWarMatchingScene:setClanInfoUI()
    local vars = self.vars
    local struct_match = self.m_structMatch 
    local struct_match_item

    for idx = 1, 2 do
        local t_clan = {}
        if (idx == 1) then
            t_clan = struct_match:getMyMatchData()
        else
            t_clan = struct_match:getEnemyMatchData()        
        end
        
        
        for _, v in pairs(t_clan) do
            struct_match_item = v
            break
        end

        if (not struct_match_item) then
            return
        end
        local clan_id = struct_match_item:getClanId()
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
            
            local attack_memeber_cnt, max_clan_member_cnt = struct_match:getAttackMemberCnt(t_clan)
            vars['matchNumLabel'..idx]:setString(Str('{1}/{2}', attack_memeber_cnt, max_clan_member_cnt))
        end
    end
    
    -- 처치수
    -- self:setClanWarScore(struct_match:getMyMatchData(), struct_match:getEnemyMatchData())    
end

-------------------------------------
-- function setMemberTableView
-------------------------------------
function UI_ClanWarMatchingScene:setMemberTableView()
    local vars = self.vars
    local struct_match = self.m_structMatch 

    local create_func = function(ui, struct_match_item)
        local my_nick, enemy_nick = struct_match:getNickNameWithAttackingEnemy(struct_match_item)
        ui.vars['userNameLabel1']:setString(my_nick)

        if (enemy_nick) then
            ui.vars['userNameLabel2']:setVisible(true)
            ui.vars['userNameLabel2']:setString(enemy_nick)
            ui.vars['arrowSprite']:setVisible(true)
        end
    end

    -- 테이블 뷰 인스턴스 생성
    local t_myClan = struct_match:getMyMatchData()
    
    self.m_myTableView = UIC_TableView(vars['meClanListNode'])
    self.m_myTableView.m_defaultCellSize = cc.size(548, 80 + 5)
    self.m_myTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.m_myTableView:setCellUIClass(UI_ClanWarMatchingSceneListItem, create_func)
    self.m_myTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.m_myTableView:setItemList(t_myClan)

    -- 테이블 뷰 인스턴스 생성
    local t_enemyClan = struct_match:getEnemyMatchData()

    self.m_enemyTableView = UIC_TableView(vars['rivalClanMenu'])
    self.m_enemyTableView.m_defaultCellSize = cc.size(548, 80 + 5)
    self.m_enemyTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.m_enemyTableView:setCellUIClass(UI_ClanWarMatchingSceneListItem, create_func)
    self.m_enemyTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.m_enemyTableView:setItemList(t_enemyClan)
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_ClanWarMatchingScene:initButton()
    local vars = self.vars
    vars['battleBtn']:registerScriptTapHandler(function() self:click_gotoBattle() end)
    vars['setDeckBtn']:registerScriptTapHandler(function() self:click_myDeck() end)
end

-------------------------------------
-- function click_gotoBattle
-------------------------------------
function UI_ClanWarMatchingScene:click_gotoBattle()
    local uid = g_userData:get('uid')
    local my_struct_match_item = self.m_structMatch:getMatchMemberDataByUid(uid)
    
    local is_do_all_game = my_struct_match_item:isDoAllGame()
    if (is_do_all_game) then
        UIManager:toastNotificationRed(Str('공격 기회를 모두 사용하였습니다.'))
        return
    end


    local attacking_uid = my_struct_match_item:getAttackingUid()
    -- 이미 공격한 상대가 있는 경우
    if (attacking_uid) then
        local finish_cb = function()
            if (not g_clanWarData:getEnemyUserInfo()) then
                UIManager:toastNotificationRed(Str('설정된 덱이 없는 상대 클랜원입니다.'))
                return
            end
            local struct_match_item = self.m_structMatch:getMatchMemberDataByUid(attacking_uid)
            UI_MatchReadyClanWar(struct_match_item, my_struct_match_item)
        end

        g_clanWarData:requestEnemyUserInfo(attacking_uid, finish_cb)
    else
        UI_ClanWarSelectScene(self.m_structMatch)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanWarMatchingScene:refresh()
end

-------------------------------------
-- function click_myDeck
-------------------------------------
function UI_ClanWarMatchingScene:click_myDeck()
    UI_ReadySceneNew(CLAN_WAR_STAGE_ID, true)
end

-------------------------------------
-- function setClanWarScore
-------------------------------------
function UI_ClanWarMatchingScene:setClanWarScore(my_clanwar, enemy_clanwar)
    local vars = self.vars
    local struct_match = self.m_structMatch
     -- 서버에서 받는 값 사용할 것 같은데 임시로 노가다로 이긴 맴버 선별
    
    local my_win_cnt, my_total_cnt = struct_match:getStateMemberCnt(my_clanwar, StructClanWarMatchItem.ATTACK_STATE['ATTACK_SUCCESS'])
    local enemy_win_cnt, enemy_total_cnt =struct_match:getStateMemberCnt(enemy_clanwar, StructClanWarMatchItem.ATTACK_STATE['ATTACK_SUCCESS'])

    local dist_cnt = my_total_cnt - enemy_total_cnt
    if (dist_cnt < 0) then
        my_win_cnt = my_win_cnt + math.abs(dist_cnt)
    elseif (dist_cnt > 0) then
        enemy_win_cnt = enemy_win_cnt + math.abs(dist_cnt)
    end

    vars['clanScoreLabel1']:setString(my_win_cnt)
    vars['clanScoreLabel2']:setString(enemy_win_cnt)       
end

-------------------------------------
-- function setScore
-------------------------------------
function UI_ClanWarMatchingScene:setScore(my_win_cnt, enemy_win_cnt)
    self.vars['clanScoreLabel1']:setString(my_win_cnt)
    self.vars['clanScoreLabel2']:setString(enemy_win_cnt)  
end
