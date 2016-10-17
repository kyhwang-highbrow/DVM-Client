-------------------------------------
-- class UI_GamePause
-------------------------------------
UI_GamePause = class(UI, {
        m_startCB = 'function',
        m_endCB = 'function',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function UI_GamePause:init(start_cb, end_cb)
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

    self:doActionReset()
    self:doAction()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_continueButton() end, 'UI_GamePause')
end

-------------------------------------
-- function click_homeButton
-------------------------------------
function UI_GamePause:click_homeButton()
    SoundMgr:playEffect('EFFECT', 'ui_button')
    local scene = SceneAdventure()
    scene:runScene()
end

-------------------------------------
-- function click_retryButton
-------------------------------------
function UI_GamePause:click_retryButton()
    SoundMgr:playEffect('EFFECT', 'ui_button')
    -- 현재 g_currScene은 SceneGame이어야 한다
    local stage_name = g_currScene.m_stageName

    local scene = SceneGame(g_currScene.m_stageID, stage_name)
    scene:runScene()
end

-------------------------------------
-- function click_continueButton
-------------------------------------
function UI_GamePause:click_continueButton()
    SoundMgr:playEffect('EFFECT', 'ui_button')
    if self.m_endCB then
        self.m_endCB()
    end

    self:close()
end