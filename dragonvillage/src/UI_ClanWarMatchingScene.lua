local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_ClanWarMatchingScene
-------------------------------------
UI_ClanWarMatchingScene = class(PARENT,{
        m_myTableView = 'UIC_TableView',
        m_enemyTableView = 'UIC_TableView',

        m_structMatch = 'StructClanWarMatch',
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

	self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClanWarMatchingScene')
end

-------------------------------------
-- function update
-------------------------------------
function UI_ClanWarMatchingScene:update()
    local vars = self.vars
    local str = '-'

    -- 경기 진행 중 (경기 종료까지 남은 시간 표시)
    if (g_clanWarData:getClanWarState() == ServerData_ClanWar.CLANWAR_STATE['OPEN']) then
        local cur_time = Timer:getServerTime_Milliseconds()
        local milliseconds = (g_clanWarData.today_end_time - cur_time)

        local hour = math.floor(milliseconds / 3600000)
        milliseconds = milliseconds - (hour * 3600000)

        local min = math.floor(milliseconds / 60000)
        milliseconds = milliseconds - (min * 60000)

        local sec = math.floor(milliseconds / 1000)
        milliseconds = milliseconds - (sec * 1000)

        str = string.format('%.2d:%.2d:%.2d',  hour, min, sec)
    end
    
    -- 중상단에 타이머
    --self.vars['timeLabel']:setString(Str('{1} 남음', g_clanWarData:getRemainGameTime()))
    vars['timeLabel']:setString(str)

    -- 공격 하기 버튼에 타이머    
    vars['btnTimeLabel']:setString(str) 
    vars['btnTimeLabel2']:setString(str)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWarMatchingScene:initUI()
    local vars = self.vars

    local struct_match = self.m_structMatch
    local my_score, enemy_score = struct_match:getSetScore()
    vars['clanScoreLabel1']:setString(tostring(my_score))
    vars['clanScoreLabel2']:setString(tostring(enemy_score))

    -- 조별리그, 토너먼트(64강, 32강, 16강, 8강, 4강, 결승전) 표기
    if (g_clanWarData:isGroupStage()) then
        vars['roundLabel']:setString(Str('조별리그'))
    else
        local round_text = g_clanWarData:getTodayRoundText()
        vars['roundLabel']:setString(round_text)
    end
        
    vars['stateLabel']:setString(Str('진행중'))

    self:setClanInfoUI()
    self:setMemberTableView()
    self:refreshStartBtn()
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
            vars['clanNameLabel'..idx]:setString('')
            vars['clanlLevelLabel'..idx]:setString('')
            vars['matchNumLabel'..idx]:setString('')
            return
        end
        local clan_id = struct_match_item:getClanId()
        local struct_clan_rank = g_clanWarData:getClanInfo(clan_id)

        if (not struct_clan_rank) then
            vars['clanNameLabel'..idx]:setString('')
            vars['clanlLevelLabel'..idx]:setString('')
            vars['matchNumLabel'..idx]:setString('')
            return        
        end
        
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
        end
    end

    local a_clan = struct_match:getMyMatchData()
    local b_clan = struct_match:getEnemyMatchData()    
    local a_member_cnt, a_max_clan_member_cnt = struct_match:getAttackMemberCnt(a_clan)
    local b_member_cnt, b_max_clan_member_cnt = struct_match:getAttackMemberCnt(b_clan)

    local match_info = struct_match:getMatchInfo()
    local my_clan_id = g_clanWarData:getMyClanId()
    if (match_info['a_clan_id'] == my_clan_id) then
        a_member_cnt = match_info['a_play_member_cnt']
        b_member_cnt = match_info['b_play_member_cnt']
    else
        a_member_cnt = match_info['b_play_member_cnt']
        b_member_cnt = match_info['a_play_member_cnt']               
    end
    
    vars['matchNumLabel1']:setString(Str('{1}/{2}', a_member_cnt, a_max_clan_member_cnt)) 
    vars['matchNumLabel2']:setString(Str('{1}/{2}', b_member_cnt, b_max_clan_member_cnt))  
end

-------------------------------------
-- function memberListSort
-- @brief
-- 1. 경기 중
-- 2. 경기 완료
-- 3. 티어 순
-- @param user_a StructUserInfoClanWar
-- @param user_b StructUserInfoClanWar
-- @return boolean
-------------------------------------
function UI_ClanWarMatchingScene:memberListSort(user_a, user_b)
    local struct_match = self.m_structMatch

    -- 0. 유저 정보가 없는 경우 (부전패
    local a_user = user_a:getUserInfo()
    local b_user = user_b:getUserInfo()
    if (not a_user) then
	    return false
    end
    if (not b_user) then
	    return true
    end

    -- 1. 경기 중인지 여부
    local struct_match_item_a = struct_match:getMatchMemberDataByUid(user_a['uid'])
    local struct_match_item_b = struct_match:getMatchMemberDataByUid(user_b['uid'])
    local attack_state_a = struct_match_item_a:getAttackState()
    local attack_state_b = struct_match_item_b:getAttackState()
    if (attack_state_a ~= attack_state_b) then
        if (attack_state_a == StructClanWarMatchItem.ATTACK_STATE['ATTACKING']) then
            -- a만 공격 중이니까
            return true
        elseif (attack_state_b == StructClanWarMatchItem.ATTACK_STATE['ATTACKING']) then
            -- b만 공격 중이니까
            return false
        end
    end


    -- 2. 경기 종료 여부
    if (attack_state_a ~= attack_state_b) then
        if (attack_state_b == StructClanWarMatchItem.ATTACK_STATE['ATTACK_POSSIBLE']) then
            -- b는 공격 전, a는 공격 후(승 or 패)
            return true
        elseif (attack_state_a == StructClanWarMatchItem.ATTACK_STATE['ATTACK_POSSIBLE']) then
            -- a는 공격 전, a는 공격 후(승 or 패)
            return false
        end
    end

    -- 3. 티어
    if (a_user:getTierOrder() ~= b_user:getTierOrder()) then
        return a_user:getTierOrder() > b_user:getTierOrder()
    end

    -- 4. 순위
    return a_user:getLastRank() < b_user:getLastRank()
end

-------------------------------------
-- function setMemberTableView
-------------------------------------
function UI_ClanWarMatchingScene:setMemberTableView()
    local vars = self.vars
    local struct_match = self.m_structMatch

    -- 티어 순으로 정렬 함수
    local sort_func = function(user_a, user_b)
        return self:memberListSort(user_a, user_b)
	end

    -- 나와 상대방 정보 세팅하는 생성 함수
    local create_func = function(ui, data)
        local uid = data['uid']
        local attack_uid = data['attack_uid']

        local my_struct_match_item = struct_match:getMatchMemberDataByUid(uid)
        local enemy_struct_match_item = struct_match:getMatchMemberDataByUid(attack_uid)
        
        ui:setStructMatchItem(my_struct_match_item, enemy_struct_match_item)
    end

    -- 나의 클랜원 테이블 아이템
    do
        local t_myClan = struct_match:getMyMatchData()
        local l_myClan = table.MapToList(t_myClan)
        table.sort(l_myClan, sort_func)

        vars['meClanListNode']:removeAllChildren()
        -- 테이블 뷰 인스턴스 생성    
        self.m_myTableView = UIC_TableView(vars['meClanListNode'])
        self.m_myTableView.m_defaultCellSize = cc.size(548, 70 + 5)
        self.m_myTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.m_myTableView:setCellUIClass(UI_ClanWarMatchingSceneListItem, create_func)
        self.m_myTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.m_myTableView:setItemList(l_myClan)

        -- 경기(매치) 화면에서는 진행 중인 경기가 상단에 표시되므로 내 위치를 보여주는 것보다
        -- 상단을 보여주는 것이 낫다고 판단되어 제거
        --[[
        -- 내 uid에 포커싱
        local my_uid = g_userData:get('uid')
        local idx = 1
        local i = 1
        for _, data in pairs(l_myClan) do
            if (data['uid'] == my_uid) then
                idx = i
            end
            i = i + 1
        end

        self.m_myTableView:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
        self.m_myTableView:relocateContainerFromIndex(idx)
        --]]
    end


    -- 상대방 클랜원 테이블 아이템    
    do
        local t_enemyClan = struct_match:getEnemyMatchData()
        local l_enemyClan = table.MapToList(t_enemyClan)
        table.sort(l_enemyClan, sort_func)
	    
        local defeat_member = 10 - #l_enemyClan
	    if (defeat_member>0) then
	    	for i=1, defeat_member do
	    		table.insert(l_enemyClan, {['clan_id'] = 'defeat', ['idx'] = i})
	    	end
	    end

        vars['rivalClanMenu']:removeAllChildren()
        
        -- 테이블 뷰 인스턴스 생성
        self.m_enemyTableView = UIC_TableView(vars['rivalClanMenu'])
        self.m_enemyTableView.m_defaultCellSize = cc.size(548, 70 + 5)
        self.m_enemyTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.m_enemyTableView:setCellUIClass(UI_ClanWarMatchingSceneListItem_enemy, create_func)
        self.m_enemyTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.m_enemyTableView:setItemList(l_enemyClan)
    end
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_ClanWarMatchingScene:initButton()
    local vars = self.vars
    vars['battleBtn']:registerScriptTapHandler(function() self:click_gotoBattle() end)
    vars['battleBtn2']:registerScriptTapHandler(function() self:click_gotoBattle() end)
    vars['setDeckBtn']:registerScriptTapHandler(function() self:click_myDeck() end)
    vars['helpBtn']:registerScriptTapHandler(function() UI_HelpClan('clan_war') end)
    vars['rewardBtn']:registerScriptTapHandler(function() UI_ClanwarRewardInfoPopup:OpneWiwthMyClanInfo() end)
    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
end

-------------------------------------
-- function click_gotoBattle
-------------------------------------
function UI_ClanWarMatchingScene:click_gotoBattle()
    local uid = g_userData:get('uid')
    local my_struct_match_item = self.m_structMatch:getMatchMemberDataByUid(uid)
    local opponent_struct_match_item = nil

    if (my_struct_match_item) then
        -- 1. 공격 기회 체크
        local is_do_all_game = my_struct_match_item:isDoAllGame()
        if (is_do_all_game) then
            UIManager:toastNotificationRed(Str('공격 기회를 모두 사용하였습니다.'))
            return
        end

        -- 2. 상대팀에 공격할 수 있는 방어 인원이 있는 지 체크
        local l_data = self.m_structMatch:getAttackableEnemyData()
        if (#l_data == 0) then
            UIManager:toastNotificationRed(Str('공격 상대가 없습니다.'))
            return
        end

        local attacking_uid = my_struct_match_item:getAttackingUid()
        opponent_struct_match_item = self.m_structMatch:getMatchMemberDataByUid(attacking_uid)
    end

    local goto_select_scene_cb = function()
        UI_ClanWarSelectScene(self.m_structMatch)
    end

    g_clanWarData:click_gotoBattle(my_struct_match_item, opponent_struct_match_item, goto_select_scene_cb)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanWarMatchingScene:refresh()
    local success_cb = function(struct_match)
        self.m_structMatch = struct_match
        self:initUI()
    end

    g_clanWarData:request_clanWarMatchInfo(success_cb)
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
-- function click_infoBtn
-------------------------------------
function UI_ClanWarMatchingScene:click_infoBtn()
    local vars = self.vars
    vars['infoBtn']:setVisible(false)
    vars['infoBtn']:setEnabled(false)

    local close_cb = function()
        vars['infoBtn']:setVisible(true)
        vars['infoBtn']:setEnabled(true)
    end

    local struct_match = self.m_structMatch
    local today_match_info = struct_match:getMatchInfo()
    UI_ClanWarMatchInfoDetailPopup.createMatchInfoMini(today_match_info)
end


-------------------------------------
-- function refreshStartBtn
-- @brief 시작 버튼 상태 갱신
-------------------------------------
function UI_ClanWarMatchingScene:refreshStartBtn()
    local vars = self.vars
    local use_primary_btn = true

    local uid = g_userData:get('uid')
    local my_struct_match_item = self.m_structMatch:getMatchMemberDataByUid(uid)

    if (my_struct_match_item) then
        -- 1. 공격 기회 체크
        local is_do_all_game = my_struct_match_item:isDoAllGame()
        if (is_do_all_game) then
            use_primary_btn = false
        end

        -- 2. 상대팀에 공격할 수 있는 방어 인원이 있는 지 체크
        local l_data = self.m_structMatch:getAttackableEnemyData()
        if (#l_data == 0) then
            use_primary_btn = false
        end
    end

    do -- 사용하는 버튼 설정
        vars['battleBtn']:setVisible(use_primary_btn)
        vars['battleBtn2']:setVisible(not use_primary_btn)
    end
end