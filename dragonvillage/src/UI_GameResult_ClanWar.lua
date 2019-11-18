local PARENT = UI

-------------------------------------
-- class UI_GameResult_ClanWar
-------------------------------------
UI_GameResult_ClanWar = class(PARENT, {
        m_endDate = 'number',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function UI_GameResult_ClanWar:init(is_success)
    local vars = self:load('arena_result.ui')
    UIManager:open(self, UIManager.POPUP)
    
	self:initUI(is_success)
	self:initButton()

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_homeBtn() end, 'UI_GameResult_ClanWar')
end

-------------------------------------
-- function click_homeBtn
-------------------------------------
function UI_GameResult_ClanWar:initUI(is_success)
	local vars = self.vars
	vars['clanWarMenu']:setVisible(true)
    vars['normalBtnMenu']:setVisible(false)

	local struct_user_info = g_clanWarData:getEnemyUserInfo()
	local nick_name = struct_user_info:getNickname()
	vars['userNameLabel']:setString(Str('대전 상대 : {1}', nick_name))
	

	local struct_user_info = g_clanWarData:getStructUserInfo_Player()
	local struct_clan_war_match_item = struct_user_info:getClanWarStructMatchItem()
	struct_clan_war_match_item:setGameResult(is_success)
    -- 처음에는 통신으로 endDate 받지 않기 때문에 하드코딩
    if (not self.m_endDate) then
        local cur_time = Timer:getServerTime_Milliseconds()
        self.m_endDate = cur_time + 60*60*2*1000
    end


	-- 승/패/승 세팅
    local l_game_result = struct_clan_war_match_item:getGameResult()

    for i, result in ipairs(l_game_result) do
        local color
        if (result == '0') then
            color = StructClanWarMatch.STATE_COLOR['LOSE']
        else
            color = StructClanWarMatch.STATE_COLOR['WIN']
        end
        if (vars['setResult'..i]) then
            vars['setResult'..i]:setColor(color)
            vars['setResult'..i]:setVisible(true)
        end
    end

    if (is_success) then
		vars['resultVisual']:changeAni('victory_appear', false)
		vars['resultVisual']:addAniHandler(function()
		    vars['resultVisual']:changeAni('victory_idle', true)
		end)
	else
		vars['resultVisual']:changeAni('defeat_appear', false)
		vars['resultVisual']:addAniHandler(function()
		    vars['resultVisual']:changeAni('defeat_idle', true)
		end)		
	end

end

-------------------------------------
-- function update
-------------------------------------
function UI_GameResult_ClanWar:update()

    local end_time = self.m_endDate or 0

    local cur_time = Timer:getServerTime_Milliseconds()
    local remain_time = (end_time - cur_time)/1000
    if (remain_time > 0) then
        local hour = math.floor(remain_time / 3600)
        local min = math.floor(remain_time / 60) % 60
		self.vars['lastTimeLabel']:setString(Str('남은 공격 시간 {1}:{2}', hour, min))
	else
		self.vars['lastTimeLabel']:setString('')
	end
	
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_GameResult_ClanWar:initButton()
	local vars = self.vars

	vars['lobbyBtn']:registerScriptTapHandler(function() UINavigatorDefinition:goTo('lobby') end)
	vars['quickStartBtn']:registerScriptTapHandler(function() self:click_quickBtn(true) end)
	vars['statsBtn2']:registerScriptTapHandler(function() self:click_statsBtn(true) end)
	vars['clanWarLobbyBtn']:registerScriptTapHandler(function() self:click_againBtn() end)
	vars['readyBtn']:registerScriptTapHandler(function() self:click_readyBtn() end)
end

-------------------------------------
-- function click_readyBtn
-------------------------------------
function UI_GameResult_ClanWar:click_readyBtn()
     local is_possible = self:checkAttackCnt()
     if (not is_possible) then
        return
     end

     local success_cb = function(struct_match)
		local my_uid = g_userData:get('uid')
        local my_struct_match_item = struct_match:getMatchMemberDataByUid(my_uid)
		local attack_uid = my_struct_match_item:getAttackingUid()
		local attacking_struct_match = struct_match:getMatchMemberDataByUid(attack_uid)

		g_clanWarData:click_gotoBattle(my_struct_match_item, attacking_struct_match, goto_select_scene_cb)
	 end

	 g_clanWarData:readyMatch(success_cb)
end

-------------------------------------
-- function checkAttackCnt
-------------------------------------
function UI_GameResult_ClanWar:checkAttackCnt()
     local struct_user_info = g_clanWarData:getStructUserInfo_Player()
	 local struct_clan_war_match_item = struct_user_info:getClanWarStructMatchItem()
     local l_game_result = struct_clan_war_match_item:getGameResult()
     if (#l_game_result == 3) then
        UIManager:toastNotificationRed(Str('공격 기회를 모두 사용하였습니다.'))
        return false
     end

     return true
end

-------------------------------------
-- function click_againBtn
-------------------------------------
function UI_GameResult_ClanWar:click_againBtn()
     local is_possible = self:checkAttackCnt()
     if (not is_possible) then
        return
     end     
     UINavigatorDefinition:goTo('clan_war', true)
end

-------------------------------------
-- function click_statsBtn
-------------------------------------
function UI_GameResult_ClanWar:click_statsBtn()
	-- @TODO g_gameScene.m_gameWorld 사용안하여야 한다.
	UI_StatisticsPopup(g_gameScene.m_gameWorld)
end

-------------------------------------
-- function click_quickBtn
-------------------------------------
function UI_GameResult_ClanWar:click_quickBtn()
     local is_possible = self:checkAttackCnt()
     if (not is_possible) then
        return
     end
	-- 씬 전환을 두번 호출 하지 않도록 하기 위함
	local quick_btn = self.vars['quickStartBtn']
	quick_btn:setEnabled(false)

	-- 게임 시작 실패시 동작
	local function fail_cb()
		quick_btn:setEnabled(true)
	end

    local stage_id = CLAN_WAR_STAGE_ID
	local check_stamina
    local check_dragon_inven
    local check_item_inven
    local start_game
	
	-- 활동력도 체크 (준비화면에 가는게 아니므로)
	check_stamina = function()
		if (g_staminasData:checkStageStamina(stage_id)) then
			check_dragon_inven()
		else
			fail_cb()

			-- 스태미나 충전
			local function finish_cb()
				self:show_staminaInfo()
			end
			g_staminasData:staminaCharge(stage_id, finish_cb)
		end
	end

    -- 드래곤 가방 확인(최대 갯수 초과 시 획득 못함)
    check_dragon_inven = function()
        local function manage_func()
            self:click_manageBtn()
			fail_cb()
        end
        g_dragonsData:checkMaximumDragons(check_item_inven, manage_func)
    end

    -- 아이템 가방 확인(최대 갯수 초과 시 획득 못함)
    check_item_inven = function()
        local function manage_func()
            UI_Inventory()
			fail_cb()
        end
        g_inventoryData:checkMaximumItems(start_game, manage_func)
    end

    start_game = function()
        -- 빠른 재시작
        self:startGame()
    end

    check_stamina()
end

-------------------------------------
-- function click_homeBtn
-------------------------------------
function UI_GameResult_ClanWar:click_homeBtn()
	local is_use_loading = true
    local scene = SceneLobby(is_use_loading)
    scene:runScene()
end

-------------------------------------
-- function startGame
-------------------------------------
function UI_GameResult_ClanWar:startGame()
    local stage_id = CLAN_WAR_STAGE_ID
	local deck_name = g_deckData:getSelectedDeckName()
    local combat_power = g_deckData:getDeckCombatPower(deck_name)

	local function finish_cb(ret)
		local stage_name = 'stage_' .. stage_id
		local scene = SceneGameClanWar(ret['gamekey'], stage_id, stage_name, false)
		scene:runScene()
	end

    local enemy_user_info = g_clanWarData:getEnemyUserInfo()
    local enemy_uid = enemy_user_info:getUid()

    ServerData_ClanWar:request_clanWarStart(enemy_uid, finish_cb)
end

