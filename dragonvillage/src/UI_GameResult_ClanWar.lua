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
function UI_GameResult_ClanWar:init(stage_id, is_success, time, gold, t_tamer_levelup_data, l_dragon_list, box_grade, l_drop_item_list, secret_dungeon, content_open, score_calc)
    local vars = self:load('event_illusion_result.ui')
    UIManager:open(self, UIManager.POPUP)
    
	self:initUI()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_homeBtn() end, 'UI_GameResult_ClanWar')
end

-------------------------------------
-- function click_homeBtn
-------------------------------------
function UI_GameResult_ClanWar:initUI()
	local vars = self.vars
	vars['resultMenu']:setVisible(true)
	vars['resultMenu']:setPositionY(420)

	vars['illusionBtn']:registerScriptTapHandler(function() UINavigatorDefinition:goTo('clan_war') end)
	vars['homeBtn']:registerScriptTapHandler(function() UINavigatorDefinition:goTo('lobby') end)
	vars['againBtn']:registerScriptTapHandler(function() self:click_againBtn(true) end)
	vars['quickBtn']:registerScriptTapHandler(function() self:click_quickBtn(true) end)
end

-------------------------------------
-- function click_againBtn
-------------------------------------
function UI_GameResult_ClanWar:click_againBtn()
   UI_MatchReadyClanWar()
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

