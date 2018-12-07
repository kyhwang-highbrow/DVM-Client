local PARENT = UI_ReadySceneNew

-------------------------------------
-- class UI_GrandArenaDeckSettings
-------------------------------------
UI_GrandArenaDeckSettings = class(PARENT,{
        m_currTamerID = 'number',
    })






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
        self:replaceGameScene(game_key)
    end

    local deck_name = g_deckData:getSelectedDeckName()
    local combat_power = self.m_readySceneDeck:getDeckCombatPower()

    g_grandArena:request_grandArenaGetMatchList(false, finish_cb, nil) -- param : is_cash, finish_cb, fail_cb

    --finish_cb(game_key)
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