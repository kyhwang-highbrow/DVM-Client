local PARENT = UI_ReadySceneNew

local NEED_CASH = 50 -- 유료 입장 다이아 개수

-------------------------------------
-- class UI_GrandArenaDeckSettings
-------------------------------------
UI_GrandArenaDeckSettings = class(PARENT,{
        m_currTamerID = 'number',
    })


-------------------------------------
-- function init
-------------------------------------
function UI_GrandArenaDeckSettings:init(stage_id, sub_info)
    local vars = self.vars

    --[[
    -- 유료 입장권
    local icon = IconHelper:getItemIcon(ITEM_ID_CASH)
    icon:setScale(0.5)
    vars['staminaExtNode']:addChild(icon)
    vars['actingPowerExtLabel']:setString(NEED_CASH)
    vars['itemMenu']:scheduleUpdateWithPriorityLua(function(dt) self:update_stamina(dt) end, 0.1)
    --]]
end

-------------------------------------
-- function networkGameStart
-- @breif
-- '전투 시작' 버튼을 클릭하고 각종 조건을 체크 후 최종적으로 버서와 통신하는 코드
--  (sgkim 2019.12.06 기준)
--  click_startBtn
--      checkChangeDeck
--      check_startCondition
--      checkPromoteAutoPick
--      startGame
--          networkGameStart <-----
--              replaceGameScene
-------------------------------------
function UI_GrandArenaDeckSettings:networkGameStart()
    local function finish_cb(game_key)
        --self:replaceGameScene(game_key)
        UI_GrandArenaMatchList()
    end

    local deck_name = g_deckData:getSelectedDeckName()
    local combat_power = self.m_readySceneDeck:getDeckCombatPower()

    g_grandArena:request_grandArenaGetMatchList(false, finish_cb, nil) -- param : is_cash, finish_cb, fail_cb
end

-------------------------------------
-- function getCurrTamerID
-------------------------------------
function UI_GrandArenaDeckSettings:getCurrTamerID()
    if (not self.m_currTamerID) then
        local l_deck, formation, deckname, leader, tamer_id = g_deckData:getDeck('grand_arena_up')
        self.m_currTamerID = tamer_id
    end
    return self.m_currTamerID
end

-------------------------------------
-- function click_tamerBtn
-- @breif
-------------------------------------
function UI_GrandArenaDeckSettings:click_tamerBtn()
    local tamer_id = self:getCurrTamerID()

    local ui = UI_TamerManagePopup_Colosseum(tamer_id)

    local function close_cb()
        self.m_currTamerID = ui.m_currTamerID
		self:refresh_tamer()
		self:refresh_buffInfo()
    end

	ui:setCloseCB(close_cb)
end

-------------------------------------
-- function update_stamina
-- @brief
-------------------------------------
function UI_GrandArenaDeckSettings:update_stamina(dt)
    local vars = self.vars
    local is_enough = g_staminasData:checkStageStamina(GRAND_ARENA_STAGE_ID)
    local is_enough_ext = g_staminasData:hasStaminaCount('grand_arena_ext', 1)

    -- 기본 입장권 없을 경우엔 유료 입장권 개수 보여줌
    vars['actingPowerNode']:setVisible(is_enough)
    vars['actingPowerExtNode']:setVisible(not is_enough)
    vars['timeLabel']:setVisible(not is_enough)
    vars['staminaExtLabel']:setVisible(not is_enough)

    if (not is_enough) then
        local stamina_type = 'grand_arena_ext'

        local time_str = g_staminasData:getChargeRemainText(stamina_type)
        vars['timeLabel']:setString(time_str)

        local st_ad = g_staminasData:getStaminaCount(stamina_type)
        local max_cnt = g_staminasData:getStaminaMaxCnt(stamina_type)
        local str = Str('{1}/{2}', comma_value(st_ad), comma_value(max_cnt))
        vars['staminaExtLabel']:setString(str)
    end

    -- 기본 입장권 & 유료 입장권 둘다 부족한 경우 - 시작 버튼 비활성화
    vars['startBtn']:setEnabled(is_enough or is_enough_ext)
end