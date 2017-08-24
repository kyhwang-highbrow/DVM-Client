-------------------------------------
-- class UI_GamePause
-------------------------------------
UI_GamePause = class(UI, {
        m_stageID = 'number',
        m_startCB = 'function',
        m_endCB = 'function',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function UI_GamePause:init(stage_id, start_cb, end_cb)
    self.m_stageID = stage_id
    self.m_startCB = start_cb
    self.m_endCB = end_cb

    if self.m_startCB then
        self.m_startCB()
    end

    local vars = self:load('ingame_pause_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    vars['retryButton']:registerScriptTapHandler(function() self:click_retryButton() end)
    vars['homeButton']:registerScriptTapHandler(function() self:click_homeButton() end)
    vars['contentsButton']:registerScriptTapHandler(function() self:click_homeButton() end)
    vars['continueButton']:registerScriptTapHandler(function() self:click_continueButton() end)
    vars['settingButton']:registerScriptTapHandler(function() self:click_settingButton() end)

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
            vars['difficultyLabel']:setColor(cc.c3b(121, 186, 58))
            vars['difficultyLabel']:setString(Str('보통'))

        elseif (difficulty == 2) then
            vars['difficultyLabel']:setColor(cc.c3b(46, 162, 196))
            vars['difficultyLabel']:setString(Str('어려움'))

        elseif (difficulty == 3) then
            vars['difficultyLabel']:setColor(cc.c3b(196, 74, 46))
            vars['difficultyLabel']:setString(Str('지옥'))
    
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
        local stage_info = g_adventureData:getStageInfo(stage_id)
        local num_of_stars = stage_info:getNumberOfStars()
        for i=1, 3 do
            local visible = stage_info['mission_' .. i]
            vars['starSprite' .. i]:setVisible(visible)
        end

        local desc_list = stage_info:getMissionDescList()
        for i=1, 3 do
            vars['infoLabel' .. i]:setString(desc_list[i])
        end
    else
        vars['btnMenu']:setPositionY(0)
        vars['starMenu']:setVisible(false)
        vars['difficultyLabel']:setVisible(false)
    end

    -- 모험 버튼 설정
    if (game_mode ~= GAME_MODE_ADVENTURE) then
        vars['homeButton']:setVisible(false)
        vars['contentsButton']:setVisible(true)

        local table_drop = TableDrop()
        local t_drop = table_drop:get(stage_id)
        vars['contentsLabel']:setString(Str(t_drop['t_name']))
    end
    
    self:doActionReset()
    self:doAction()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_continueButton() end, 'UI_GamePause')
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
-- function click_debug_enemyInfoButton
-- @brief 적군 상세 정보를 표시
-------------------------------------
function UI_GamePause:click_debug_enemyInfoButton()
    local world = g_gameScene.m_gameWorld
    local str = ''

    for _, v in ipairs(world:getEnemyList()) do
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

    for _, v in ipairs(world:getEnemyList()) do
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
    local msg = Str('지금 종료하면 드래곤 경험치와 보상을 받을 수 없습니다.\n그래도 나가시겠습니까?')
    MakeSimplePopup(POPUP_TYPE.YES_NO, msg, exit_cb)
end
