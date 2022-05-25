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
-- function initUI
-------------------------------------
function UI_GameResult_ClanWar:initUI(is_success)
	local vars = self.vars
	vars['clanWarMenu']:setVisible(true)
    vars['normalBtnMenu']:setVisible(true)

	local struct_user_info = g_clanWarData:getEnemyUserInfo()
	local nick_name = struct_user_info:getNickname()
	vars['userNameLabel']:setString(Str('대전 상대 : {1}', nick_name))
	

	local struct_user_info = g_clanWarData:getStructUserInfo_Player()
	local struct_clan_war_match_item = struct_user_info:getClanWarStructMatchItem()
    self.m_endDate = struct_clan_war_match_item:getEndDate()

	-- 승/패/승 세팅
    local l_result = struct_clan_war_match_item:getGameResult()
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

    local end_time = self.m_endDate
    if (not end_time) then
        self.vars['lastTimeLabel']:setString('')
        return
    end

    local cur_time = ServerTime:getInstance():getCurrentTimestampMilliseconds()
    local remain_time = (end_time - cur_time)
    if (remain_time > 0) then
        local text = datetime.makeTimeDesc_timer_filledByZero(remain_time) or ''
		self.vars['lastTimeLabel']:setString(text)
	else    
		self.vars['lastTimeLabel']:setString('')	
	end 
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_GameResult_ClanWar:initButton()
	local vars = self.vars

	vars['homeBtn']:registerScriptTapHandler(function() UINavigatorDefinition:goTo('lobby') end)
	--vars['quickStartBtn']:registerScriptTapHandler(function() self:click_quickBtn(true) end)
	vars['statsBtn']:registerScriptTapHandler(function() self:click_statsBtn(true) end)
	vars['okBtn']:registerScriptTapHandler(function() self:click_againBtn() end)
	--vars['readyBtn']:registerScriptTapHandler(function() self:click_readyBtn() end)
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
     if (not struct_clan_war_match_item) then
        UIManager:toastNotificationRed(Str('공격 기회를 모두 사용하였습니다.'))
        return false
     end

     if (struct_clan_war_match_item:isDoAllGame()) then
        UIManager:toastNotificationRed(Str('공격 기회를 모두 사용하였습니다.'))
        return false
     end
     
     return true
end

-------------------------------------
-- function click_againBtn
-------------------------------------
function UI_GameResult_ClanWar:click_againBtn() 
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
            -- UI_Inventory() @kwkang 룬 업데이트로 룬 관리쪽으로 이동하게 변경 
            UI_RuneForge('manage')
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
    -- 씬 전환을 두번 호출 하지 않도록 하기 위함
    local block_ui = UI_BlockPopup()

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
        -- 씬 전환을 두번 호출 하지 않도록 하기 위함
	    local block_ui = UI_BlockPopup()

		local stage_name = 'stage_' .. stage_id
		local scene = SceneGameClanWar(ret['gamekey'], stage_id, stage_name, false)
		scene:runScene()
	end

    local enemy_user_info = g_clanWarData:getEnemyUserInfo()
    local enemy_uid = enemy_user_info:getUid()

    ServerData_ClanWar:request_clanWarStart(enemy_uid, finish_cb)
end

