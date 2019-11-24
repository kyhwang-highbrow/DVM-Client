local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_ClanWarSelectScene
-------------------------------------
UI_ClanWarSelectScene = class(PARENT,{
        m_tStructMatch = 'StructClanWarMatch',

        m_curSelectEnemyStructMatch = 'StructClanWarMatchItem',

        m_myTableView = '',
        m_enemyTableView = '',
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
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ClanWarSelectScene:click_exitBtn()
    self:close()
end

-------------------------------------
-- function init
-------------------------------------
function UI_ClanWarSelectScene:init(struct_match)
    local vars = self:load('clan_war_match_select_scene.ui')
    self.m_tStructMatch = struct_match or {}

    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ClanWarSelectScene')

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

    if (IS_TEST_MODE()) then
        --[[
        vars['testMenu']:setVisible(true)
        vars['testWinBtn']:registerScriptTapHandler(function() self:click_testBtn(true) end)
        vars['testLoseBtn']:registerScriptTapHandler(function() self:click_testBtn(false) end)
        --]]
    end

    self:setDefendHistoryTableView()

	for i=1,2 do
		vars['userNameLabel' .. i]:setString('')
		vars['powerLabel' .. i]:setString('')
	end
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

		return a_user:getTierOrder() > b_user:getTierOrder()
	end

	table.sort(l_enemy, sort_func)
    for i, data in ipairs(l_enemy) do
        if (i == 1) then
            self.m_curSelectEnemyStructMatch = data
            break
        end 
    end


	vars['defenseNumLavel']:setString(Str('방어인원 {1}', #l_enemy))
    local create_func = function(ui, struct_match_item)
        -- 클릭했을 때 
        ui.vars['selectBtn']:registerScriptTapHandler(function() 
            self.m_curSelectEnemyStructMatch = struct_match_item 
            self:refreshFocusUserInfo(true)
            self:selectItem()
        end)
        ui:setStructMatch(struct_match, false)
        if (self.m_curSelectEnemyStructMatch['uid'] == struct_match_item['uid']) then
            ui:setSelected(true)
        end
    end

    local table_view = UIC_TableView(vars['rivalClanListNode'])
    table_view.m_defaultCellSize = cc.size(548, 80 + 5)
    table_view:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    table_view:setCellUIClass(UI_ClanWarSelectSceneListItem, create_func)
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
            self.m_curSelectEnemyStructMatch = struct_match_item 
            self:refreshFocusUserInfo()
            self:selectItem()
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

    local table_view = UIC_TableView(vars['myClanListNode'])
    table_view.m_defaultCellSize = cc.size(548, 80 + 5)
    table_view:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    table_view:setCellUIClass(UI_ClanWarSelectSceneListItem_Me, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_my)

    self.m_myTableView = table_view
    self:selectItem()
end

-------------------------------------
-- function selectItem
-------------------------------------
function UI_ClanWarSelectScene:selectItem()
    if (not self.m_curSelectEnemyStructMatch) then
        return
    end

    local selected_uid = self.m_curSelectEnemyStructMatch['uid']
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
	vars['readyBtn']:registerScriptTapHandler(function() self:click_readyBtn(true) end)
end

-------------------------------------
-- function click_readyBtn
-------------------------------------
function UI_ClanWarSelectScene:click_readyBtn()
	local struct_match = self.m_tStructMatch
    if (not self.m_curSelectEnemyStructMatch) then
        return
    end


    local struct_match_item = self.m_curSelectEnemyStructMatch
	local defend_state = struct_match_item:getDefendState()
	local defend_state_text = struct_match_item:getDefendStateNotiText()
	if (defend_state ~= StructClanWarMatchItem.DEFEND_STATE['DEFEND_POSSIBLE']) then
		UIManager:toastNotificationGreen(Str(defend_state_text))
		return
	end

    if (not g_clanWarData:getEnemyUserInfo()) then
        UIManager:toastNotificationGreen(Str('설정된 덱이 없는 상대 클랜원입니다.'))
        return
    end

    local ok_btn_cb = function()
	    local my_uid = g_userData:get('uid')
	    local my_struct_match_item = struct_match:getMatchMemberDataByUid(my_uid)
	    UI_MatchReadyClanWar(struct_match_item, my_struct_match_item)
    end

    local msg = Str('선택한 대상을 공격 하시겠습니까?\n한 번 선택한 대상은 도중에 변경할 수 없습니다.')
    local lv = struct_match_item:getUserInfo():getLv() or ''
    local nick_name = struct_match_item:getMyNickName()
    local nick_str = 'Lv.' .. lv .. ' ' .. nick_name
    local submsg = Str('선택 대상: {1}', nick_str)
    UI_SimplePopup2(POPUP_TYPE.YES_NO, msg, submsg, ok_btn_cb)
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
    vars['readyBtn']:setVisible(is_enemy)
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
    local l_game_result = struct_match_item:getGameResult()
    for i, result in ipairs(l_game_result) do
        local color
        if (result == '0') then
            color = StructClanWarMatch.STATE_COLOR['LOSE']
        else
            color = StructClanWarMatch.STATE_COLOR['WIN']
        end
        if (vars['setResult'..i]) then
            vars['setResult'..i]:setColor(color)
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

    local comebat_power = struct_user_info:getDeckCombatPower()
    vars['powerLabel' .. ui_idx]:setString(tostring(comebat_power))
end
