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

	self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClanWarMatchingScene')
end

-------------------------------------
-- function update
-------------------------------------
function UI_ClanWarMatchingScene:update()
	self.vars['timeLabel']:setString(Str('{1} 남음', g_clanWarData:getRemainGameTime()))
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWarMatchingScene:initUI()
    local vars = self.vars

    local round_text = g_clanWarData:getTodayRoundText()
    if (round) then
        vars['roundLabel']:setString(round_text)
    else
        vars['roundLabel']:setString(Str('조별리그'))
    end
    vars['stateLabel']:setString(Str('진행중'))

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

    local create_func_common = function(ui, struct_match_item)
        local my_nick, enemy_nick = struct_match:getNickNameWithAttackingEnemy(struct_match_item)
		local struct_user_info_clan = struct_match_item:getUserInfo()
		local icon = struct_user_info_clan:getLastTierIcon('big')       

        if (enemy_nick) then
			ui.vars['userNameLabel1']:setVisible(true)
            ui.vars['userNameLabel2']:setVisible(true)
			ui.vars['arrowSprite']:setVisible(true)

			ui.vars['userNameLabel1']:setString(my_nick)
            ui.vars['userNameLabel2']:setString(enemy_nick)

			ui.vars['tierIconNode']:addChild(icon)
        else
			ui.vars['arrowSprite']:setVisible(false)
			ui.vars['userNameLabel1']:setVisible(false)
			ui.vars['noRivalNode']:setVisible(true)

			ui.vars['tierIconNode3']:addChild(icon)
			ui.vars['userNameLabel3']:setString(my_nick)
		end
	end

	local create_func_me = function(ui, struct_match_item)
		create_func_common(ui, struct_match_item)
		ui.vars['rivalFrameSprite']:setVisible(false)
		ui.vars['meFrameSprite']:setVisible(true)
    end

    local t_myClan = struct_match:getMyMatchData()
    local l_myClan = table.MapToList(t_myClan)
    local sort_func = function(a,b)
		a_user = a:getUserInfo()
		b_user = b:getUserInfo()
		if (not a_user) then
			return false
		end

		if (not b_user) then
			return true
		end
		return a_user:getTierOrder() > b_user:getTierOrder()
	end

    table.sort(l_myClan, sort_func)
    
    -- 테이블 뷰 인스턴스 생성    
    self.m_myTableView = UIC_TableView(vars['meClanListNode'])
    self.m_myTableView.m_defaultCellSize = cc.size(548, 80 + 5)
    self.m_myTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.m_myTableView:setCellUIClass(UI_ClanWarMatchingSceneListItem, create_func_me)
    self.m_myTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.m_myTableView:setItemList(l_myClan)

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


	local create_func_rival = function(ui, struct_match_item)
		create_func_common(ui, struct_match_item)

		ui.vars['rivalFrameSprite']:setVisible(true)
		ui.vars['meFrameSprite']:setVisible(false)
    end
    -- 테이블 뷰 인스턴스 생성
    local t_enemyClan = struct_match:getEnemyMatchData()
    local l_enemyClan = table.MapToList(t_enemyClan)
    table.sort(l_enemyClan, sort_func)

    self.m_enemyTableView = UIC_TableView(vars['rivalClanMenu'])
    self.m_enemyTableView.m_defaultCellSize = cc.size(548, 80 + 5)
    self.m_enemyTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.m_enemyTableView:setCellUIClass(UI_ClanWarMatchingSceneListItem, create_func_rival)
    self.m_enemyTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.m_enemyTableView:setItemList(l_enemyClan)
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

    local goto_select_scene_cb = function()
        UI_ClanWarSelectScene(self.m_structMatch)
    end

    local attacking_uid = my_struct_match_item:getAttackingUid()
    opponent_struct_match_item = self.m_structMatch:getMatchMemberDataByUid(attacking_uid)
    g_clanWarData:click_gotoBattle(my_struct_match_item, opponent_struct_match_item, goto_select_scene_cb)
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
