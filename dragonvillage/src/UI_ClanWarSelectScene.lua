local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_ClanWarSelectScene
-------------------------------------
UI_ClanWarSelectScene = class(PARENT,{
        m_tStructMatch = 'StructClanWarMatch',

        m_curSelectEnemyStructMatch = 'StructClanWarMatchItem',

        m_myTableView = '',
        m_enemyTableView = '',
        m_bFirstEntrance = 'boolean', -- UI생성 후 첫번째 진입인지 여부
})

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_ClanWarSelectScene:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ClanWarSelectScene'
    self.m_titleStr = Str('클랜전')
	--self.m_staminaType = 'pvp'
    self.m_bVisible = true
    self.m_bUseExitBtn = true
    self.m_subCurrency = 'clancoin'
    self.m_uiBgm = 'bgm_lobby'


    self.m_bFirstEntrance = true
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ClanWarSelectScene:click_exitBtn()
    self:close()
end

-------------------------------------
-- function onFocus
-------------------------------------
function UI_ClanWarSelectScene:onFocus()
    if (not self.m_bFirstEntrance) then
        self:refresh()
    end

    self.m_bFirstEntrance = false
end

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarSelectScene:init(struct_match)
    local vars = self:load('clan_war_match_select_scene_new.ui')
    self.m_tStructMatch = struct_match or {}

    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClanWarSelectScene')

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)

    self:initUI()
	self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWarSelectScene:initUI()
	local vars = self.vars
	self:initEnemyTableView()
	self:initMyTableView()

    self:setDefendHistoryTableView()

	for i=1,2 do
		vars['userNameLabel' .. i]:setString('')
		vars['powerLabel' .. i]:setString('')
	end

    --vars['myClanListNode']:setVisible(true)

    -- 개발용 UI off
    vars['testMenu']:setVisible(false)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanWarSelectScene:refresh()
    local finish_cb = function(struct_match)
        self.m_tStructMatch = struct_match
        
        self:initEnemyTableView()
	    self:initMyTableView()

        self:setDefendHistoryTableView()
    end
    
    g_clanWarData:readyMatch(finish_cb)
end

-------------------------------------
-- function setDefendHistoryTableView
-------------------------------------
function UI_ClanWarSelectScene:setDefendHistoryTableView()
    local vars = self.vars
    if (not self.m_curSelectEnemyStructMatch) then
        return
    end

    local cur_struct_match = self.m_curSelectEnemyStructMatch
    local l_history = cur_struct_match:getDefendHistoryList()
    l_history = table.reverse(l_history)

    local idx = 1
    local create_func = function(ui, data)
        local is_odd = idx/2 ~= 0
        ui.vars['itemSprite1']:setVisible(is_odd)
        ui.vars['itemSprite1']:setVisible(not is_odd)
        idx = idx + 1
    end

    vars['defenseListNode']:removeAllChildren()
    local table_view = UIC_TableView(vars['defenseListNode'])
    table_view.m_defaultCellSize = cc.size(445, 35)
    table_view:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    table_view:setCellUIClass(UI_ClanWarSelectSceneDefendHistoryItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_history)

	vars['notHistoryLabel']:setVisible(#l_history == 0)
end

-------------------------------------
-- function initEnemyTableView
-------------------------------------
function UI_ClanWarSelectScene:initEnemyTableView()
    local vars = self.vars
    local struct_match = self.m_tStructMatch
    local l_enemy = struct_match:getAttackableEnemyData()
    
    local sort_func = function(a,b)
		a_user = a:getUserInfo()
		b_user = b:getUserInfo()

		if (not a_user) then
			return false
		end

		if (not b_user) then
			return true
		end

        -- 1. 티어
        if (a_user:getTierOrder() ~= b_user:getTierOrder()) then
            return a_user:getTierOrder() > b_user:getTierOrder()
        end

		-- 2. 순위
        return a_user:getLastRank() < b_user:getLastRank()
	end

	table.sort(l_enemy, sort_func)

    -- 첫 상대를 선택
    --[[
    for i, data in ipairs(l_enemy) do
        if (i == 1) then
            self.m_curSelectEnemyStructMatch = data
            break
        end 
    end
    --]]


	vars['defenseNumLavel']:setString(Str('방어인원 {1}', #l_enemy))
    local create_func = function(ui, struct_match_item)
        -- 클릭했을 때 
        ui.vars['selectBtn']:registerScriptTapHandler(function() 
            self:setSelectStructMatch(struct_match_item, true) -- param : struct_match_item, is_enemy

        end)
        ui:setStructMatch(struct_match, false)
        if self.m_curSelectEnemyStructMatch then
            if (self.m_curSelectEnemyStructMatch['uid'] == struct_match_item['uid']) then
                ui:setSelected(true)
            end
        end
    end

    vars['rivalClanListNode']:removeAllChildren()
    local table_view = UIC_TableView(vars['rivalClanListNode'])
    table_view.m_defaultCellSize = cc.size(548, 80 + 5)
    table_view:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    table_view:setCellUIClass(UI_ClanWarSelect_RivalListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_enemy)
    self.m_enemyTableView = table_view

    self:refreshFocusUserInfo(true)
    self:selectItem()
end

-------------------------------------
-- function initMyTableView
-------------------------------------
function UI_ClanWarSelectScene:initMyTableView()
    local vars = self.vars
    local struct_match = self.m_tStructMatch
    local t_my = struct_match:getMyMatchData()
    local l_my = {}

    for _, struct_match_item in pairs(t_my) do
        if (struct_match_item:getAttackState() == StructClanWarMatchItem.ATTACK_STATE['ATTACKING']) or (struct_match_item:getAttackState() == StructClanWarMatchItem.ATTACK_STATE['ATTACK_POSSIBLE']) then
            table.insert(l_my, struct_match_item)
        end
    end

	vars['attackNumLavel']:setString(Str('공격인원 {1}', #l_my))
    local create_func = function(ui, struct_match_item)
        -- 클릭했을 때 
        ui.vars['selectBtn']:registerScriptTapHandler(function() 
            self:setSelectStructMatch(struct_match_item, false) -- param : struct_match_item, is_enemy
        end)
    end

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

	table.sort(l_my, sort_func)

    vars['myClanListNode']:removeAllChildren()
    local table_view = UIC_TableView(vars['myClanListNode'])
    table_view.m_defaultCellSize = cc.size(548, 80 + 5)
    table_view:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    table_view:setCellUIClass(UI_ClanWarSelectSceneListItem_Me, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_my)
    
    local my_uid = g_userData:get('uid')
    local idx = 0
    for i, data in ipairs(l_my) do
        if (data['uid'] == my_uid) then
            idx = i
            break
        end
    end

    table_view:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
    table_view:relocateContainerFromIndex(idx)
    self.m_myTableView = table_view
    self:selectItem()
end

-------------------------------------
-- function selectItem
-- @param deselect_all boolean true일 경우 모든 리스트 아이템을 미선택으로 처리
-------------------------------------
function UI_ClanWarSelectScene:selectItem(deselect_all)
    local selected_uid
    if (deselect_all == true) then
        selected_uid = nil
    else
        if self.m_curSelectEnemyStructMatch then
            selected_uid = self.m_curSelectEnemyStructMatch['uid']
        else
            return
        end
    end

    if (self.m_enemyTableView) then
        local l_enemy = self.m_enemyTableView.m_itemList
	    for _, data in ipairs(l_enemy) do
	    	if (data['ui']) then
	    		local is_selected = (data['ui'].m_structMatchItem['uid'] == selected_uid)
                data['ui']:setSelected(is_selected)
            end
        end
    end

    if (self.m_myTableView) then
        local l_my = self.m_myTableView.m_itemList
	    for _, data in ipairs(l_my) do
	    	if (data['ui']) then
	    		local is_selected = (data['ui'].m_structMatchItem['uid'] == selected_uid)
                data['ui']:setSelected(is_selected)
            end
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanWarSelectScene:initButton()
	local vars = self.vars
    vars['helpBtn']:registerScriptTapHandler(function() UI_HelpClan('clan_war') end)
    vars['rewardBtn']:registerScriptTapHandler(function() UI_ClanwarRewardInfoPopup:OpneWithMyClanInfo() end)
    vars['setDeckBtn']:registerScriptTapHandler(function() UI_ClanWarDeckSettings(CLAN_WAR_STAGE_ID) end)
	vars['startBtn']:registerScriptTapHandler(function() self:click_readyBtn(true) end)
    vars['startBtn2']:registerScriptTapHandler(function() self:click_readyBtn(true) end)

    -- 아군 리스트 표시 여부
    vars['myClanBtn'] = UIC_CheckBox(vars['myClanBtn'].m_node, vars['myClanCheckSprite'], false)
    --vars['myClanBtn']:setChecked(false)
    local function on_change_cb(checked)
        vars['myClanListNode']:setVisible(checked)

        vars['middleInfoMenu']:stopAllActions()
        vars['rivalClanListNode']:stopAllActions()
        if checked then
            vars['middleInfoMenu']:runAction(cc.EaseInOut:create(cc.MoveTo:create(0.3, cc.p(120, 0)), 2))
            vars['rivalClanListNode']:runAction(cc.EaseInOut:create(cc.MoveTo:create(0.3, cc.p(396, 92)), 2))
        else
            vars['middleInfoMenu']:runAction(cc.EaseInOut:create(cc.MoveTo:create(0.3, cc.p(0, 0)), 2))
            vars['rivalClanListNode']:runAction(cc.EaseInOut:create(cc.MoveTo:create(0.3, cc.p(276, 92)), 2))
        end
    end
    vars['myClanBtn']:setChangeCB(on_change_cb)

    self:refreshStartBtn()
end

-------------------------------------
-- function click_readyBtn
-------------------------------------
function UI_ClanWarSelectScene:click_readyBtn()
	local struct_match = self.m_tStructMatch
    if (not self.m_curSelectEnemyStructMatch) then
        UIManager:toastNotificationRed(Str('공격할 대상을 선택하세요.'))
        return
    end

    -- 1.공격 가능한 상대가 아니라면 return
    local select_struct_match_item = self.m_curSelectEnemyStructMatch
	local defend_state = select_struct_match_item:getDefendState()
	local defend_state_text = select_struct_match_item:getDefendStateNotiText()
	if (defend_state ~= StructClanWarMatchItem.DEFEND_STATE['DEFEND_POSSIBLE']) then
		UIManager:toastNotificationRed(Str(defend_state_text))
		return
	end

    -- 2.아예 유저 정보가 없는 상대라면 return
    if (not g_clanWarData:getEnemyUserInfo()) then
        UIManager:toastNotificationRed(Str('설정된 덱이 없는 상대 클랜원입니다.'))
        return
    end

    local ok_cb = function()
        self:requestSelect()
    end

    local my_uid = g_userData:get('uid')
    local my_struct_match_item = struct_match:getMatchMemberDataByUid(my_uid)
    
    UI_ClanWarShowSelectInfo(select_struct_match_item, ok_cb)
end

-------------------------------------
-- function requestSelect
-------------------------------------
function UI_ClanWarSelectScene:requestSelect()
    local select_struct_match_item = self.m_curSelectEnemyStructMatch
    local struct_match = self.m_tStructMatch

    local finish_cb = function()
	    local my_uid = g_userData:get('uid')
    	local my_struct_match_item = struct_match:getMatchMemberDataByUid(my_uid)
	    UI_MatchReadyClanWar(select_struct_match_item, my_struct_match_item)
    end

    -- select 통신했는데 이미 전투 중인 상대였다면 선택하지 않고 화면 갱신 처리
    local refresh_cb = function()
        self:refresh()
    end
    
    g_clanWarData:request_clanWarSelect(select_struct_match_item['uid'], finish_cb, refresh_cb)
end

-------------------------------------
-- function click_testBtn
-------------------------------------
function UI_ClanWarSelectScene:click_testBtn(is_win)
    local select_enemy_uid = self.m_curSelectEnemyStructMatch['uid']
    
    local start_cb = function()
        local finish_cb = function()
            
        end 
        g_clanWarData:request_clanWarFinish(is_win, finish_cb)
    end
    g_clanWarData:request_clanWarStart(select_enemy_uid, nil, start_cb)
end

-------------------------------------
-- function refreshFocusUserInfo
-- @brief
-------------------------------------
function UI_ClanWarSelectScene:refreshFocusUserInfo(is_enemy)
    local struct_match_item = self.m_curSelectEnemyStructMatch
    
    if (not struct_match_item) then
        return
    end

    local finish_cb = function(data)
        self:refreshCenterUI(is_enemy)
    end
    g_clanWarData:requestEnemyUserInfo(struct_match_item['uid'], finish_cb)
    self:setDefendHistoryTableView()
end

-------------------------------------
-- function refreshCenterUI
-- @brief
-------------------------------------
function UI_ClanWarSelectScene:refreshCenterUI(is_enemy)
    local vars = self.vars
    local struct_match = self.m_tStructMatch
    local struct_match_item = self.m_curSelectEnemyStructMatch

    local ui_idx = 2
    local ui_result_str = 'rivlaSetResult'

    if (not is_enemy) then
        ui_idx = 1
        ui_result_str = 'setResult'
    end    
    vars['meClanMenu']:setVisible(not is_enemy)
    vars['rivalClanMenu']:setVisible(is_enemy)
    
    -- 내 클랜원일 경우 공격 불가능
    --vars['startBtn']:setVisible(is_enemy)
	local struct_clan_info = struct_match_item:getUserInfo()
    -- 리더 드래곤
	--[[
    local dragon_icon = struct_clan_info:getLeaderDragonCard()
    if (dragon_icon) then
        vars['dragonNode' .. ui_idx]:addChild(dragon_icon.root)
        vars['dragonNode' .. ui_idx]:setScale(0.5)
    end
	--]]
	local icon = struct_clan_info:getLastTierIcon()  
    if (icon) then
        vars['tierIconNode' .. ui_idx]:removeAllChildren()
        vars['tierIconNode' .. ui_idx]:addChild(icon)
    end

    local enemy_nick = struct_match_item:getMyNickName() or ''
    local enemy_lv = struct_clan_info:getLv() or ''
    local str_nick = 'Lv.' .. enemy_lv .. ' ' .. enemy_nick
    vars['userNameLabel' .. ui_idx]:setString(str_nick)
    vars['dragonDeckNode']:removeAllChildren()
    vars['tamerNode']:removeAllChildren()

    for i = 1,3 do
        if (vars[ui_result_str..i]) then
            vars[ui_result_str..i]:setColor(StructClanWarMatch.STATE_COLOR['DEFAULT'])
            vars[ui_result_str..i]:setVisible(true)
        end
    end

	-- 승/패/승 세팅
    local l_result = struct_match_item:getGameResult()
    for i, result in ipairs(l_result) do
        local color
        local sprite
        if (result == '0') then
            color = StructClanWarMatch.STATE_COLOR['LOSE']
        elseif (result == '1') then
            color = StructClanWarMatch.STATE_COLOR['WIN']
        elseif (result == '-1') then
            sprite = cc.Sprite:create('res/ui/icons/clan_war_score_no_game.png')
            sprite:setAnchorPoint(CENTER_POINT)
            sprite:setDockPoint(CENTER_POINT)
            sprite:setRotation(-45)
        end

        if (vars['setResult'..i]) then
            if (color) then
                vars['setResult'..i]:setVisible(true)
                vars['setResult'..i]:setColor(color)
            end

            if (sprite) then
                vars['setResult'..i]:setVisible(true)
                vars['setResult'..i]:setOpacity(0)
                vars['setResult'..i]:addChild(sprite)
            end
        end
    end


    local struct_user_info = g_clanWarData:getEnemyUserInfo()
    if (not struct_user_info) then
        return
    end

    local l_dragon_obj = struct_user_info:getDeck_dragonList()
    local leader = struct_user_info.m_pvpDeck['leader']
    local formation = struct_user_info.m_pvpDeck['formation']

    local player_2d_deck = UI_2DDeck(true, true)
    player_2d_deck:setDirection('right')
    vars['dragonDeckNode']:addChild(player_2d_deck.root)
    player_2d_deck:initUI()

    -- 드래곤 생성 (리더도 함께)
    player_2d_deck:setDragonObjectList(l_dragon_obj, leader)
        
    -- 진형 설정
    player_2d_deck:setFormation(formation)
    player_2d_deck:runAction()

    -- 테이머
    local animator = struct_user_info:getDeckTamerSDAnimator()

    vars['tamerNode']:addChild(animator.m_node)

    
    if (struct_user_info.m_lastTier == 'legend') then
        -- Ranker Animator 생성
        local ranker_animator = MakeAnimator('res/effect/effect_tamer_ranker_01/effect_tamer_ranker_01.vrp')--AnimatorHelper:makeTamerAnimator(file_name)
        if ranker_animator.m_node then
		    vars['tamerNode']:addChild(ranker_animator.m_node, -1)
            ranker_animator.m_node:setPositionX(55)
            ranker_animator.m_node:setPositionY(0)
            ranker_animator.m_node:setScale(1)
        end
    end


    -- 전투력
    local comebat_power = struct_user_info:getDeckCombatPower()
    comebat_power = comma_value(comebat_power)
    vars['powerLabel' .. ui_idx]:setString(tostring(comebat_power))
end

-------------------------------------
-- function setSelectStructMatch
-- @brief 왼쪽 아군 리스트, 오른쪽 적군 리스트 중 하나를 선택했을 때
-- @param struct_match_item StructClanWarMatchItem
-- @param is_enemy boolean 
-------------------------------------
function UI_ClanWarSelectScene:setSelectStructMatch(struct_match_item, is_enemy)

    local deselect_all = false

    -- 같은 것을 선택했을 때에는 선택 해제로 처리
    if (self.m_curSelectEnemyStructMatch == struct_match_item) then
        struct_match_item = nil
        deselect_all = true
    end

    self.m_curSelectEnemyStructMatch = struct_match_item
    self:refreshFocusUserInfo(is_enemy)
    self:selectItem(deselect_all)

    -- 선택 상태에 따라 정보 표시 변경
    local vars = self.vars
    local is_selected = (self.m_curSelectEnemyStructMatch ~= nil)
    vars['selectMenu']:setVisible(is_selected)
    vars['noSelectMenu']:setVisible(not is_selected)

    -- 선택 대상에 따라 버튼 상태 갱신
    self:refreshStartBtn()
end

-------------------------------------
-- function update
-------------------------------------
function UI_ClanWarSelectScene:update(dt)
	local vars = self.vars

    local cur_time = Timer:getServerTime_Milliseconds()
    local str = '-'
    -- 경기 진행 중 (경기 종료까지 남은 시간 표시)
    if (g_clanWarData:getClanWarState() == ServerData_ClanWar.CLANWAR_STATE['OPEN']) then
        local milliseconds = (g_clanWarData.today_end_time - cur_time)

        local hour = math.floor(milliseconds / 3600000)
        milliseconds = milliseconds - (hour * 3600000)

        local min = math.floor(milliseconds / 60000)
        milliseconds = milliseconds - (min * 60000)

        local sec = math.floor(milliseconds / 1000)
        milliseconds = milliseconds - (sec * 1000)

        str = string.format('%.2d:%.2d:%.2d',  hour, min, sec)
        
    -- 경기 진행 중이 아닌 경우 (시간을 표기하지 않음)
    else
        str = '-'
    end

    vars['timeLabel']:setString(str)
    vars['timeLabel2']:setString(str)
end

-------------------------------------
-- function refreshStartBtn
-- @brief 시작 버튼 상태 갱신
-------------------------------------
function UI_ClanWarSelectScene:refreshStartBtn()
    local vars = self.vars
    local use_primary_btn = true

    -- 선택한 대상이 없으면
	local struct_match = self.m_tStructMatch
    if (not self.m_curSelectEnemyStructMatch) then
        use_primary_btn = false
    end

    -- 공격 가능한 상대가 아니라면 return
    if (self.m_curSelectEnemyStructMatch) then
        local select_struct_match_item = self.m_curSelectEnemyStructMatch
	    local defend_state = select_struct_match_item:getDefendState()
	    local defend_state_text = select_struct_match_item:getDefendStateNotiText()
	    if (defend_state ~= StructClanWarMatchItem.DEFEND_STATE['DEFEND_POSSIBLE']) then
		    use_primary_btn = false
	    end
    end

    do -- 사용하는 버튼 설정
        vars['startBtn']:setVisible(use_primary_btn)
        vars['startBtn2']:setVisible(not use_primary_btn)
    end
end













local PARENT = UI

-------------------------------------
-- class UI_ClanWarShowSelectInfo
-------------------------------------
UI_ClanWarShowSelectInfo = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarShowSelectInfo:init(enemy_data, ok_cb)
    local vars = self:load('clan_war_popup_battle_info.ui')
    UIManager:open(self, UIManager.POPUP)
    g_currScene:pushBackKeyListener(ui, function() self:close() end, 'clan_war_popup_rival')
	
   	-- @UI_ACTION
	self:doActionReset()
	self:doAction(nil, false) 
    
    self:initUI(enemy_data, ok_cb)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanWarShowSelectInfo:initUI(enemy_data, ok_cb)
    local attacking_struct_match = enemy_data

    local nick_name = attacking_struct_match:getMyNickName() or ''
    self.vars['userNameLabel']:setString(nick_name)
    self.vars['timeLabel']:setString('02:00:00')
    
    local struct_user_info_clan = attacking_struct_match:getUserInfo()
    local icon = struct_user_info_clan:getLastTierIcon() 
    if (icon) then
        self.vars['tierNode']:addChild(icon)
    end
    self.vars['cancelBtn']:registerScriptTapHandler(function() self:close() end)
    self.vars['okBtn']:registerScriptTapHandler(function() self:close() ok_cb()  end)
    self.vars['closBtn']:registerScriptTapHandler(function() self:close() end)
end