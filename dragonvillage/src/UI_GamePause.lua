-------------------------------------
-- class UI_GamePause
-------------------------------------
UI_GamePause = class(UI, {
    m_stageID = 'number',
    m_gameKey = 'number',
    m_startCB = 'function',
    m_endCB = 'function',

    m_buttons = 'List[UIC_Button]',
})

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function UI_GamePause:init(stage_id, gamekey, start_cb, end_cb)
    self.m_stageID = stage_id
    self.m_gameKey = gamekey
    self.m_startCB = start_cb
    self.m_endCB = end_cb

    if self.m_startCB then
        self.m_startCB()
    end

    local vars = self:load('ingame_pause_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    if g_dmgateData:isStageDimensionGate(self.m_stageID) then
        vars['quickStartBtn']:setVisible(true)
        vars['quickStartBtn']:setEnabled(true)
    end

    self.m_buttons = {}
    if vars['quickStartBtn'] and vars['quickStartBtn']:isVisible() then table.insert(self.m_buttons,
            vars['quickStartBtn']) end
    if vars['continueButton'] and vars['continueButton']:isVisible() then table.insert(self.m_buttons,
            vars['continueButton']) end
    if vars['retryButton'] and vars['retryButton']:isVisible() then table.insert(self.m_buttons, vars['retryButton']) end
    if vars['settingButton'] and vars['settingButton']:isVisible() then table.insert(self.m_buttons,
            vars['settingButton']) end

    local button_num = #self.m_buttons
    local interval = self.m_buttons[2]:getPositionX() - self.m_buttons[1]:getPositionX()
    local gap

    if (button_num % 2) then
        gap = -((button_num - 1) / 2)
    else
        gap = -((button_num / 2) - 0.5)
    end

    local start_pos_x = (gap * interval)

    for index, button in ipairs(self.m_buttons) do
        if (index <= button_num) then
            button:setPositionX(start_pos_x)
            start_pos_x = start_pos_x + interval
        else
            button:setVisible(false)
        end
    end

    vars['quickStartBtn']:registerScriptTapHandler(function() self:click_quickStartBtn() end)
    vars['retryButton']:registerScriptTapHandler(function() self:click_retryButton() end)
    vars['homeButton']:registerScriptTapHandler(function() self:click_homeButton() end)
    vars['contentsButton']:registerScriptTapHandler(function() self:click_homeButton() end)
    vars['continueButton']:registerScriptTapHandler(function() self:click_continueButton() end)
    vars['settingButton']:registerScriptTapHandler(function() self:click_settingButton() end)
    vars['infoBtn']:registerScriptTapHandler(function() self:click_statusInfoBtn() end)
    vars['infoBtn']:setVisible(true)

    -- 디버그용 버튼
    if (IS_TEST_MODE()) then
        vars['heroInfoButton']:setVisible(true)
        vars['enemyInfoButton']:setVisible(true)
        vars['heroInfoButton']:registerScriptTapHandler(function() self:click_debug_heroInfoButton() end)
        vars['enemyInfoButton']:registerScriptTapHandler(function() self:click_debug_enemyInfoButton() end)
    else
        vars['heroInfoButton']:setVisible(false)
        vars['enemyInfoButton']:setVisible(false)
    end

    -- 난이도
    do
        local difficulty, chapter, stage = parseAdventureID(stage_id)
        if (difficulty == 1) then
            vars['difficultyLabel']:setColor(COLOR['diff_normal'])
            vars['difficultyLabel']:setString(Str('보통'))
        elseif (difficulty == 2) then
            vars['difficultyLabel']:setColor(COLOR['diff_hard'])
            vars['difficultyLabel']:setString(Str('어려움'))
        elseif (difficulty == 3) then
            vars['difficultyLabel']:setColor(COLOR['diff_hell'])
            vars['difficultyLabel']:setString(Str('지옥'))
        elseif (difficulty == 4) then
            vars['difficultyLabel']:setColor(COLOR['diff_hellfire'])
            vars['difficultyLabel']:setString(Str('불지옥'))
        elseif (difficulty == 5) then
            vars['difficultyLabel']:setColor(COLOR['diff_abyss_0'])
            vars['difficultyLabel']:setString(Str('심연'))
        elseif (difficulty == 6) then
            vars['difficultyLabel']:setColor(COLOR['diff_abyss_1'])
            vars['difficultyLabel']:setString(Str('심연 1'))
        end
    end

    -- 스테이지 이름
    do
        local stage_name = g_stageData:getStageName(stage_id)
        vars['titleLabel']:setString(stage_name)
    end

    -- 획득한 별 표시 (모험 모드에서만)
    local game_mode = g_stageData:getGameMode(stage_id)
    if (game_mode == GAME_MODE_ADVENTURE) then
        -- 깜짝 출현 챕터 예외처리
        if (isAdventStageID(stage_id)) then
            vars['btnMenu']:setPositionY(0)
            vars['starMenu']:setVisible(false)
            -- 룬 축제 이벤트 예외처리
        elseif (g_stageData:isRuneFestivalStage(stage_id) == true) then
            vars['btnMenu']:setPositionY(0)
            vars['starMenu']:setVisible(false)
        else
            local stage_info = g_adventureData:getStageInfo(stage_id)
            local num_of_stars = stage_info:getNumberOfStars()
            for i = 1, 3 do
                local visible = stage_info['mission_' .. i]
                vars['starSprite' .. i]:setVisible(visible)
            end

            local desc_list = stage_info:getMissionDescList()
            for i = 1, 3 do
                vars['infoLabel' .. i]:setString(desc_list[i])
            end
        end
    else
        -- 차원문 시즌효과
        -- 상층이면 버튼들 이동 안하고 효과를 보여줌
        local is_dmgate_stage = game_mode == GAME_MODE_DIMENSION_GATE
        local chapter_id = is_dmgate_stage and g_dmgateData:getChapterID(tonumber(g_gameScene.m_gameWorld.m_stageID)) or
        -1
        local is_upper_floor = chapter_id > 1

        -- dmgate 스테이지가 아니면 is_upper_floor 이 값은 항상 false임
        if (is_upper_floor) then
            -- 추가된 시즌 효과가 아예 없으면 위로 떙김
            if (UI_DmgateBlessBtnPopup:addBlessTableView(vars['blessMenu']) == false) then
                vars['btnMenu']:setPositionY(0)
            end
        else
            vars['btnMenu']:setPositionY(0)
        end

        vars['starMenu']:setVisible(false)
        vars['difficultyLabel']:setVisible(false)
    end

    -- 모험 버튼 설정
    if (game_mode ~= GAME_MODE_ADVENTURE) then
        vars['homeButton']:setVisible(false)
        vars['contentsButton']:setVisible(true)

        if (stage_id == COLOSSEUM_STAGE_ID) then
            vars['contentsLabel']:setString(Str('콜로세움'))
        elseif (stage_id == ARENA_STAGE_ID) then
            vars['contentsLabel']:setString(Str('콜로세움'))
        elseif (stage_id == ARENA_NEW_STAGE_ID) then
            vars['contentsLabel']:setString(Str('콜로세움'))
        elseif (stage_id == CHALLENGE_MODE_STAGE_ID) then
            vars['contentsLabel']:setString(Str('그림자의 신전'))
        elseif (game_mode == GAME_MODE_CLAN_RAID) then
            vars['contentsLabel']:setString(Str('클랜 던전'))
        elseif (game_mode == GAME_MODE_ANCIENT_TOWER) then
            local attr_mode = g_ancientTowerData:isAttrChallengeMode()
            if (attr_mode) then
                vars['contentsLabel']:setString(Str('시험의 탑'))
            else
                vars['contentsLabel']:setString(Str('고대의 탑'))
            end
        elseif (stage_id == CLAN_WAR_STAGE_ID) then
            vars['contentsLabel']:setString(Str('클랜전'))
        else
            local table_drop = TableDrop()
            local t_drop = table_drop:get(stage_id)
            vars['contentsLabel']:setString(Str(t_drop['t_name']))
        end
    end

    self:doActionReset()
    self:doAction()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_continueButton() end, 'UI_GamePause')
end

-------------------------------------
-- function click_quickStartBtn
-------------------------------------
function UI_GamePause:click_quickStartBtn()
    local block_ui = UI_BlockPopup()

    local deck_name = g_deckData:getSelectedDeckName()

    local function finish_cb(game_key)
        local stage_name = 'stage_' .. self.m_stageID

        scene = SceneGame(game_key, self.m_stageID, stage_name, false)

        scene:runScene()
    end

    -- url : dmgate/start
    -- required params : user_id, stage_id, deck_name, token
    g_stageData:requestGameStart(self.m_stageID, deck_name, nil, finish_cb)
end

-------------------------------------
-- function click_homeButton
-------------------------------------
function UI_GamePause:click_homeButton()
    local function home_func()
        local game_mode = g_gameScene.m_gameMode
        local dungeon_mode = g_gameScene.m_dungeonMode
        local condition = self.m_stageID
        QuickLinkHelper.gameModeLink(game_mode, dungeon_mode, condition)
    end

    self:confirmExit(home_func)
end

-------------------------------------
-- function click_retryButton
-------------------------------------
function UI_GamePause:click_retryButton()
    local function retry_func()
        local stage_id = g_currScene.m_stageID
        UINavigator:goTo('adventure', stage_id)
    end

    self:confirmExit(retry_func)
end

-------------------------------------
-- function click_statusInfoBtn
-------------------------------------
function UI_GamePause:click_statusInfoBtn()
    UI_HelpStatus()
end

-------------------------------------
-- function click_continueButton
-------------------------------------
function UI_GamePause:click_continueButton()
    if self.m_endCB then
        self.m_endCB()
    end

    self:close()
end

-------------------------------------
-- function click_settingButton
-------------------------------------
function UI_GamePause:click_settingButton()
    UI_Setting()
end

-------------------------------------
-- function click_debug_heroInfoButton
-- @brief 아군 상세 정보를 표시
-------------------------------------
function UI_GamePause:click_debug_heroInfoButton()
    local world = g_gameScene.m_gameWorld
    local str = ''
    local list = {}

    for _, v in ipairs(world:getDragonList()) do
        table.insert(list, v)
    end

    -- 이름 순으로 정렬
    if (#list > 1) then
        table.sort(list, function(a, b)
            return a:getName() < b:getName()
        end)
    end

    for _, v in ipairs(list) do
        local str_info = v:getAllInfomationString()
        str = str .. str_info
    end

    self.root:setVisible(false)

    UI_GameDebug_InfoPopup(str, function()
        self.root:setVisible(true)
    end)
end

-------------------------------------
-- function click_debug_enemyInfoButton
-- @brief 적군 상세 정보를 표시
-------------------------------------
function UI_GamePause:click_debug_enemyInfoButton()
    local world = g_gameScene.m_gameWorld
    local str = ''
    local list = {}

    for _, v in ipairs(world:getEnemyList()) do
        table.insert(list, v)
    end

    -- 이름 순으로 정렬
    if (#list > 1) then
        table.sort(list, function(a, b)
            return a:getName() < b:getName()
        end)
    end

    for _, v in ipairs(list) do
        local str_info = v:getAllInfomationString()
        str = str .. str_info
    end

    self.root:setVisible(false)

    UI_GameDebug_InfoPopup(str, function()
        self.root:setVisible(true)
    end)
end

-------------------------------------
-- function confirmExit
-------------------------------------
function UI_GamePause:confirmExit(exit_cb)
    local msg = Str('지금 퇴장하면 {@RED}패배로 처리{@default}됩니다.\n그래도 나가시겠습니까?')

    local function ok_cb()
        -- 게임 도중 나기기 버튼 클릭시 오토플레이 종료
        g_autoPlaySetting:setAutoPlay(false)

        -- 아레나인 경우 강제 종료 로그 남김
        if (self.m_stageID == ARENA_STAGE_ID) then
            g_arenaData.m_tempLogData['force_exit'] = true
        end

        -- 아레나인 경우 강제 종료 로그 남김
        if (self.m_stageID == ARENA_NEW_STAGE_ID) then
            g_arenaData.m_tempLogData['force_exit'] = true
        end

        -- 아레나인 경우 강제 종료 로그 남김
        if (self.m_stageID == GRAND_ARENA_STAGE_ID) then
            g_grandArena.m_tempLogData['force_exit'] = true
        end

        -- 멈춘 상태에서 바로 종료될시 어색하므로 resume 시키고 종료
        local world = g_gameScene.m_gameWorld
        -- 할로윈 이벤트 던전
        if table.find({ 1119801, 1129801, 1139801, 1149801 }, self.m_stageID) then
            world.m_gameState:changeState(GAME_STATE_STOP)
        else
            world.m_gameState:changeState(GAME_STATE_FAILURE)
        end

        if self.m_endCB then
            self.m_endCB()
        end

        -- 터치는 안되게
        UI_BlockPopup()
        self.root:setVisible(false)
    end

    local game_mode = g_stageData:getGameMode(self.m_stageID)
    if (game_mode == GAME_MODE_LEAGUE_RAID) then
        msg = Str('현재 진행 상황을 포기하고 레이드 로비로 나가시겠습니까?\n(날개는 소비되지 않습니다.)')
    end

    MakeSimplePopup(POPUP_TYPE.YES_NO, msg, ok_cb)
end
