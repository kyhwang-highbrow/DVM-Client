local PARENT = UI

-------------------------------------
-- class UI_ClanWarMatchingWatching
-------------------------------------
UI_ClanWarMatchingWatching = class(PARENT,{
        m_myTableView = 'UIC_TableView',
        m_enemyTableView = 'UIC_TableView',

        m_structMatch = 'StructClanWarMatch',
        m_preRefreshTime = 'time', -- 새로고침 쿨타임 체크용
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarMatchingWatching:init(struct_match)
    local vars = self:load('clan_war_match_watch.ui')
    UIManager:open(self, UIManager.POPUP)

    self.m_structMatch = struct_match
    self.m_preRefreshTime = 0

    self:initUI()
    self:initButton()

	self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClanWarMatchingWatching')
end

-------------------------------------
-- function update
-------------------------------------
function UI_ClanWarMatchingWatching:update()
    local vars = self.vars
    local str = '-'

    -- 경기 진행 중 (경기 종료까지 남은 시간 표시)
    if (g_clanWarData:getClanWarState() == ServerData_ClanWar.CLANWAR_STATE['OPEN']) then
        local cur_time = ServerTime:getInstance():getCurrentTimestampMilliseconds()
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
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWarMatchingWatching:initUI()
    local vars = self.vars

    local struct_match = self.m_structMatch
    --local my_score, enemy_score = struct_match:getSetScore()
    --vars['clanScoreLabel1']:setString(tostring(my_score))
    --vars['clanScoreLabel2']:setString(tostring(enemy_score))
    local match_info = struct_match:getMatchInfo()
    local set_score_a = match_info['a_member_win_cnt']
    local set_score_b = match_info['b_member_win_cnt']
    vars['clanScoreLabel1']:setString(tostring(set_score_a))
    vars['clanScoreLabel2']:setString(tostring(set_score_b))

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
end

-------------------------------------
-- function setClanInfoUI
-------------------------------------
function UI_ClanWarMatchingWatching:setClanInfoUI()
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
                    vars['clanMarkNode'..idx]:removeAllChildren()
                    vars['clanMarkNode'..idx]:addChild(clan_icon)
                end
            end

            -- 클랜 레벨
            local clan_lv = struct_clan_rank:getClanLv() or ''
            local level_text = string.format('Lv.%d', clan_lv)
            vars['clanlLevelLabel'..idx]:setString(level_text)

            -- 클랜 상세 정보 팝업
            vars['clanBtn'..idx]:registerScriptTapHandler(function() g_clanData:requestClanInfoDetailPopup(clan_id) end)
        end
    end

    local a_clan = struct_match:getMyMatchData()
    local b_clan = struct_match:getEnemyMatchData()    
    local a_member_cnt, a_max_clan_member_cnt = struct_match:getAttackMemberCnt(a_clan)
    local b_member_cnt, b_max_clan_member_cnt = struct_match:getAttackMemberCnt(b_clan)

    local match_info = struct_match:getMatchInfo()
    a_member_cnt = match_info['a_play_member_cnt']
    b_member_cnt = match_info['b_play_member_cnt']
    
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
function UI_ClanWarMatchingWatching:memberListSort(user_a, user_b)
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
function UI_ClanWarMatchingWatching:setMemberTableView()
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
function UI_ClanWarMatchingWatching:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
    vars['refreshBtn']:registerScriptTapHandler(function() self:click_refreshBtn() end)
    vars['refreshBtn']:setVisible(true) -- 추가된 버튼으로 ui파일에서 visible이 false로 설정되어 있을 수 있다.
end

-------------------------------------
-- function setClanWarScore
-------------------------------------
function UI_ClanWarMatchingWatching:setClanWarScore(my_clanwar, enemy_clanwar)
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
function UI_ClanWarMatchingWatching:click_infoBtn()
    local vars = self.vars
    vars['infoBtn']:setVisible(false)
    vars['infoBtn']:setEnabled(false)

    local close_cb = function()
        vars['infoBtn']:setVisible(true)
        vars['infoBtn']:setEnabled(true)
    end

    local struct_match = self.m_structMatch
    local today_match_info = struct_match:getMatchInfo()
    local ui = UI_ClanWarMatchInfoDetailPopup.createMatchInfoMini(today_match_info)
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_refreshBtn
-- @brief 현재 화면을 최신으로 갱신
-------------------------------------
function UI_ClanWarMatchingWatching:click_refreshBtn()
    local func_check_cooldown -- 1. 쿨타임 체크
    local func_request_info -- 2. 통신
    local func_refresh -- 3. 갱신 (현재 페이지를 갱신)

    -- 1. 쿨타임 체크
    func_check_cooldown = function()
        -- 갱신 가능 시간인지 체크한다
	    local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()
        local RENEW_INTERVAL = 10
	    if (curr_time - self.m_preRefreshTime > RENEW_INTERVAL) then
		    self.m_preRefreshTime = curr_time
		    -- 일반적인 갱신
		    func_request_info()
	
	    -- 시간이 되지 않았다면 몇초 남았는지 토스트 메세지를 띄운다
	    else
		    local ramain_time = math_ceil(RENEW_INTERVAL - (curr_time - self.m_preRefreshTime) + 1)
		    UIManager:toastNotificationRed(Str('{1}초 후에 갱신 가능합니다.', ramain_time))
	    end
    end

    -- 2. 통신
    func_request_info = function()
        local struct_match = self.m_structMatch 
        local t_clan = struct_match:getMyMatchData()
        local struct_match_item = nil
        for _, v in pairs(t_clan) do
            struct_match_item = v
        end
        local clan_id = struct_match_item:getClanId()
        g_clanWarData:request_clanWarMatchInfo(func_refresh, clan_id)
    end

    -- 3. 갱신 (현재 페이지를 갱신)
    func_refresh = function(struct_match, match_info)
        -- 상대가 유령클랜이거나 클랜 정보가 없을 경
		if (match_info) then
            local no_clan_func = function()
                local msg = Str('대전 상대가 없어 부전승 처리되었습니다.')
                MakeSimplePopup(POPUP_TYPE.OK, msg)
            end
            
            local clan_id_a = match_info['a_clan_id']
            local clan_id_b = match_info['b_clan_id']
            if (clan_id_a == 'loser') then
                 no_clan_func()
                return               
            end
            
            if (clan_id_b == 'loser') then
                 no_clan_func()
                return               
            end

            local my_clan_info = g_clanWarData:getClanInfo(clan_id_a)
            if (not my_clan_info) then         
                no_clan_func()
                return
            end

            local enemy_clan_info = g_clanWarData:getClanInfo(clan_id_b)
            if (not enemy_clan_info) then
                no_clan_func()
                return
            end
        end
        
        --UI_ClanWarMatchingWatching(struct_match)
        self.m_structMatch = struct_match
        self:initUI()
    end


    -- 시작 함수 호출
    func_check_cooldown()
end

-------------------------------------
-- function OPEN
-- @param clan_id
-------------------------------------
function UI_ClanWarMatchingWatching.OPEN(clan_id)
    
    -- 마지막 날의 경우
    if (g_clanWarData.m_clanWarDay == 14) then
        local msg = Str('다음 시즌 오픈까지 {1}', g_clanWarData:getRemainNextSeasonTime())
        MakeSimplePopup(POPUP_TYPE.OK, msg)
        return
    end
    
    -- 오픈 여부 확인(조별리그)
    if (g_clanWarData:isGroupStage() == true) then
	    local is_open, msg = g_clanWarData:checkClanWarState_League()
	    if (not is_open) then
		    MakeSimplePopup(POPUP_TYPE.OK, msg)
		    return
	    end
    end

    -- 오픈 여부 확인(토너먼트)
    if (g_clanWarData:isTournament() == true) then
	    local is_open, msg = g_clanWarData:checkClanWarState_Tournament()
	    if (not is_open) then	
		    MakeSimplePopup(POPUP_TYPE.OK, msg)
		    return
	    end
    end

    local success_cb = function(struct_match, match_info)
        UI_ClanWarMatchingWatching(struct_match)
    end

    g_clanWarData:request_clanWarMatchInfo(success_cb, clan_id)
end