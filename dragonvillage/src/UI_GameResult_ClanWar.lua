local PARENT = UI

-------------------------------------
-- class UI_GameResult_ClanWar
-------------------------------------
UI_GameResult_ClanWar = class(PARENT, {
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

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_homeBtn() end, 'UI_GameResult_ClanWar')
end

-------------------------------------
-- function click_homeBtn
-------------------------------------
function UI_GameResult_ClanWar:initUI(is_success)
	local vars = self.vars
	vars['clanWarMenu']:setVisible(true)

	local struct_user_info = g_clanWarData:getStructUserInfo_Enemy()
	local nick_name = struct_user_info:getNickname()
	vars['userNameLabel']:setString(Str('대전 상대 : {1}', nick_name))
	

	local struct_user_info = g_clanWarData:getStructUserInfo_Player()
	local struct_clan_war_match_item = struct_user_info:getClanWarStructMatchItem()
	struct_clan_war_match_item:setGameResult(is_success)
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
        end
    end

end

-------------------------------------
-- function initButton
-------------------------------------
function UI_GameResult_ClanWar:initButton()
	local vars = self.vars

	vars['homeBtn']:registerScriptTapHandler(function() UINavigatorDefinition:goTo('lobby') end)
	vars['okBtn']:registerScriptTapHandler(function() self:click_againBtn(true) end)
	--vars['quickBtn']:registerScriptTapHandler(function() self:click_quickBtn(true) end)
	vars['statsBtn']:registerScriptTapHandler(function() self:click_statsBtn(true) end)
end

-------------------------------------
-- function click_againBtn
-------------------------------------
function UI_GameResult_ClanWar:click_againBtn()
     UINavigatorDefinition:goTo('goTo_clan_war', true)
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

	-- 씬 전환을 두번 호출 하지 않도록 하기 위함
	local quick_btn = self.vars['quickBtn']
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
	local deck_name = 'clan_war'
    local combat_power = g_deckData:getDeckCombatPower(deck_name)
	local scene = SceneGameClanWar()
    scene:runScene()
	--[[
	local function finish_cb(game_key)
		-- 연속 전투일 경우 횟수 증가
		if (g_autoPlaySetting:isAutoPlay()) then
			g_autoPlaySetting.m_autoPlayCnt = (g_autoPlaySetting.m_autoPlayCnt + 1)
		end

		local stage_name = 'stage_' .. stage_id
		local scene = SceneGame(game_key, stage_id, stage_name, false)
		scene:runScene()
	end

    local game_mode = g_stageData:getGameMode(stage_id)

    g_stageData:requestGameStart(stage_id, deck_name, combat_power, finish_cb, fail_cb)
	--]]
end

