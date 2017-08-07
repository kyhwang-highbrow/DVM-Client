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
    vars['continueButton']:registerScriptTapHandler(function() self:click_continueButton() end)

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
        local is_use_loading = true
        local scene = SceneLobby(is_use_loading)
        scene:runScene()
    end
    
    self:confirmExit(home_func)
end

-------------------------------------
-- function click_retryButton
-------------------------------------
function UI_GamePause:click_retryButton()
    local function retry_func()
        local stage_id = g_currScene.m_stageID
        g_adventureData:goToAdventureScene(stage_id)
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
-- function click_debug_heroInfoButton
-- @brief 아군 상세 정보를 표시
-------------------------------------
function UI_GamePause:click_debug_heroInfoButton()
    local world = g_gameScene.m_gameWorld
    local str = ''

    for _, v in ipairs(world:getDragonList()) do
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
